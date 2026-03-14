//
//  APIService.swift
//  stoury
//
//  Created by Muhammad Arfian Praniza on 10/03/26.
//

import Foundation

enum APIError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case serverError(statusCode: Int)
    case serverErrorWithMessage(statusCode: Int, message: String)
    case decodingError
    case encodingError
    case unknown

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The URL is invalid."
        case .invalidResponse:
            return "The server response was invalid."
        case .serverError(let statusCode):
            switch statusCode {
            case 401, 422:
                return "Email atau kata sandi salah."
            case 409:
                return "Email sudah terdaftar."
            default:
                return "Terjadi kesalahan pada server."
            }
        case .serverErrorWithMessage(_, let message):
            return message
        case .decodingError:
            return "Failed to read server data."
        case .encodingError:
            return "Failed to encode request data."
        case .unknown:
            return "Something went wrong."
        }
    }
}

final class APIService {
    private let baseURL = "https://stoury-api.oceandigital.id/api"
    private let sessionStore: SessionStore
    private var refreshTask: Task<Void, Error>?

    init(sessionStore: SessionStore) {
        self.sessionStore = sessionStore
    }

    private func printRequestBody(_ request: URLRequest) {
        guard let httpBody = request.httpBody,
              let bodyString = String(data: httpBody, encoding: .utf8) else {
            return
        }

        print("API request body:", bodyString)
    }

    private func requestLabel(for request: URLRequest) -> String {
        let method = request.httpMethod ?? "REQUEST"
        let url = request.url?.absoluteString ?? "unknown-url"
        return "\(method) \(url)"
    }

    private func printError(_ prefix: String, error: Error) {
        print("\(prefix):", error.localizedDescription)
        print("Raw error:", error)
    }

    private func printRawResponse(_ data: Data, prefix: String) {
        guard let rawResponse = String(data: data, encoding: .utf8), !rawResponse.isEmpty else {
            return
        }

        print("\(prefix):", rawResponse)
    }

    private func decodeEnvelope<T: Decodable>(
        _ type: T.Type,
        from data: Data,
        context: String
    ) throws -> T {
        do {
            let decoded = try JSONDecoder().decode(APIResponse<T>.self, from: data)
            return decoded.data
        } catch {
            printError("API decoding failed for \(context)", error: error)
            printRawResponse(data, prefix: "API raw response for \(context)")
            throw APIError.decodingError
        }
    }

    private func applyAuthorization(to request: inout URLRequest) {
        guard let token = sessionStore.accessToken else { return }
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
    }

    private func cacheResponseIfNeeded(data: Data, response: URLResponse, for request: URLRequest) {
        guard request.httpMethod == "GET",
              let httpResponse = response as? HTTPURLResponse,
              200...299 ~= httpResponse.statusCode,
              !data.isEmpty else {
            return
        }

        let cachedResponse = CachedURLResponse(response: response, data: data)
        URLCache.shared.storeCachedResponse(cachedResponse, for: request)
    }

    private func resolvedResponseData(
        for request: URLRequest,
        data: Data,
        response: URLResponse
    ) throws -> Data {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        if httpResponse.statusCode == 304 {
            if let cachedResponse = URLCache.shared.cachedResponse(for: request) {
                print("API cache hit for 304 response:", request.url?.absoluteString ?? "")
                return cachedResponse.data
            }

            print("API received 304 without cached response for:", request.url?.absoluteString ?? "")
            throw APIError.serverErrorWithMessage(
                statusCode: 304,
                message: "Resource not modified, but no cached response was available."
            )
        }

        try validateSuccessfulResponse(data: data, response: response)
        cacheResponseIfNeeded(data: data, response: response, for: request)
        return data
    }

    private func authorizedData(for request: URLRequest) async throws -> Data {
        var request = request
        applyAuthorization(to: &request)

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await URLSession.shared.data(for: request)
        } catch {
            printError("API request failed for \(requestLabel(for: request))", error: error)
            throw error
        }

        if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 401 {
            print("API received 401 for:", requestLabel(for: request))
            do {
                try await refreshSession()
            } catch {
                printError("API refresh failed after 401 for \(requestLabel(for: request))", error: error)
                throw error
            }

            var retryRequest = request
            applyAuthorization(to: &retryRequest)

            let retryData: Data
            let retryResponse: URLResponse
            do {
                (retryData, retryResponse) = try await URLSession.shared.data(for: retryRequest)
            } catch {
                printError("API retry failed for \(requestLabel(for: retryRequest))", error: error)
                throw error
            }
            if let retryHTTPResponse = retryResponse as? HTTPURLResponse, retryHTTPResponse.statusCode == 401 {
                print("API retry still unauthorized, clearing session for:", requestLabel(for: retryRequest))
                sessionStore.clearSession()
            }
            return try resolvedResponseData(for: retryRequest, data: retryData, response: retryResponse)
        }

        return try resolvedResponseData(for: request, data: data, response: response)
    }

    private func refreshSession() async throws {
        if let refreshTask {
            print("API refresh already in progress, awaiting existing task")
            try await refreshTask.value
            return
        }

        let task = Task {
            try await performRefreshSession()
        }
        refreshTask = task

        defer {
            refreshTask = nil
        }

        try await task.value
    }

    private func performRefreshSession() async throws {
        guard let refreshToken = sessionStore.refreshToken else {
            print("API refresh failed: missing refresh token")
            sessionStore.clearSession()
            throw APIError.serverErrorWithMessage(statusCode: 401, message: "Session expired. Please log in again.")
        }

        guard let url = URL(string: "\(baseURL)/auth/refresh") else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(RefreshTokenRequest(refreshToken: refreshToken))
        printRequestBody(request)

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await URLSession.shared.data(for: request)
        } catch {
            printError("API refresh request failed", error: error)
            sessionStore.clearSession()
            throw error
        }

        do {
            try validateSuccessfulResponse(data: data, response: response)
        } catch {
            printError("API refresh validation failed", error: error)
            sessionStore.clearSession()
            throw error
        }

        do {
            let decoded = try JSONDecoder().decode(APIResponse<RefreshTokenResponse>.self, from: data)
            let refreshedUser = decoded.data.user ?? sessionStore.currentUser

            guard let refreshedUser else {
                print("API refresh failed: missing refreshed user and no existing session user")
                sessionStore.clearSession()
                throw APIError.decodingError
            }

            sessionStore.setSession(
                AuthSession(
                    accessToken: decoded.data.accessToken,
                    refreshToken: decoded.data.refreshToken ?? refreshToken,
                    user: refreshedUser
                )
            )
            print("API refresh succeeded")
        } catch {
            printError("API refresh decoding failed", error: error)
            printRawResponse(data, prefix: "API refresh raw response")
            sessionStore.clearSession()
            throw APIError.decodingError
        }
    }

    private func validateSuccessfulResponse(data: Data, response: URLResponse) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        guard 200...299 ~= httpResponse.statusCode else {
            if let serverError = try? JSONDecoder().decode(ServerErrorResponse.self, from: data) {
                print("API server error message:", serverError.message)
                throw APIError.serverErrorWithMessage(
                    statusCode: httpResponse.statusCode,
                    message: serverError.message
                )
            }

            if let rawBody = String(data: data, encoding: .utf8), !rawBody.isEmpty {
                print("API server error raw body:", rawBody)
            }

            throw APIError.serverError(statusCode: httpResponse.statusCode)
        }
    }

    func login(email: String, password: String) async throws -> AuthSession {
        guard let url = URL(string: "\(baseURL)/auth/login") else {
            throw APIError.invalidURL
        }

        let loginRequest = LoginRequest(email: email, password: password)

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(loginRequest)
        printRequestBody(request)

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await URLSession.shared.data(for: request)
        } catch {
            printError("API login request failed", error: error)
            throw error
        }
        try validateSuccessfulResponse(data: data, response: response)
        return try decodeEnvelope(AuthSession.self, from: data, context: "login")
    }

    func register(name: String, email: String, password: String) async throws -> AuthSession {
        guard let url = URL(string: "\(baseURL)/auth/register") else {
            throw APIError.invalidURL
        }

        let registerRequest = RegisterRequest(name: name, email: email, password: password)

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(registerRequest)
        printRequestBody(request)

        let (data, response) = try await URLSession.shared.data(for: request)
        try validateSuccessfulResponse(data: data, response: response)

        do {
            let decoded = try JSONDecoder().decode(APIResponse<AuthSession>.self, from: data)
            return decoded.data
        } catch {
            throw APIError.decodingError
        }
    }

    func getDashboard() async throws -> DashboardHome {
        guard let url = URL(string: "\(baseURL)/dashboard/home") else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let data = try await authorizedData(for: request)

        return try decodeEnvelope(DashboardHome.self, from: data, context: "dashboard")
    }

    func searchDashboard(
        query: String,
        page: Int = 1,
        limit: Int = 10
    ) async throws -> DashboardSearchPayload {
        guard var components = URLComponents(string: "\(baseURL)/dashboard/search") else {
            throw APIError.invalidURL
        }

        components.queryItems = [
            URLQueryItem(name: "q", value: query),
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "limit", value: "\(limit)")
        ]

        guard let url = components.url else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let data = try await authorizedData(for: request)

        return try decodeEnvelope(DashboardSearchPayload.self, from: data, context: "dashboard search")
    }

    func getTrips() async throws -> [Trip] {
        guard let url = URL(string: "\(baseURL)/trips") else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let data = try await authorizedData(for: request)

        return try decodeEnvelope([Trip].self, from: data, context: "trips")
    }

    func getTrip(tripId: UUID) async throws -> Trip {
        guard let url = URL(string: "\(baseURL)/trips/\(tripId.uuidString)") else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let data = try await authorizedData(for: request)

        return try decodeEnvelope(Trip.self, from: data, context: "trip detail")
    }

    func getTripItinerary(tripId: UUID) async throws -> TripItinerary {
        guard let url = URL(string: "\(baseURL)/trips/\(tripId.uuidString)/itinerary") else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let data = try await authorizedData(for: request)

        return try decodeEnvelope(TripItinerary.self, from: data, context: "trip itinerary")
    }

    func getAttraction(attractionId: UUID) async throws -> AttractionDetail {
        guard let url = URL(string: "\(baseURL)/attractions/\(attractionId.uuidString)") else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let data = try await authorizedData(for: request)

        return try decodeEnvelope(AttractionDetail.self, from: data, context: "attraction detail")
    }

    func getMyPreferences() async throws -> [Preference] {
        guard let url = URL(string: "\(baseURL)/preferences/me") else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let data = try await authorizedData(for: request)

        return try decodeEnvelope([Preference].self, from: data, context: "account preferences")
    }

    func getPreferences() async throws -> [Preference] {
        guard let url = URL(string: "\(baseURL)/preferences") else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let data = try await authorizedData(for: request)

        return try decodeEnvelope([Preference].self, from: data, context: "master preferences")
    }

    func updatePreferences(categoryIds: [UUID]) async throws -> [Preference] {
        guard let url = URL(string: "\(baseURL)/preferences/me") else {
            throw APIError.invalidURL
        }

        let body = PreferencesUpdateRequest(categoryIds: categoryIds)

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(body)
        printRequestBody(request)

        let data = try await authorizedData(for: request)

        do {
            let decoded = try JSONDecoder().decode(APIResponse<[Preference]>.self, from: data)
            return decoded.data
        } catch {
            throw APIError.decodingError
        }
    }

    func logout(refreshToken: String) async throws {
        guard let url = URL(string: "\(baseURL)/auth/logout") else {
            throw APIError.invalidURL
        }

        let body = LogoutRequest(refreshToken: refreshToken)

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(body)
        printRequestBody(request)

        let (data, response) = try await URLSession.shared.data(for: request)
        try validateSuccessfulResponse(data: data, response: response)
    }

    func getDestinations(page: Int = 1, limit: Int = 100) async throws -> [DashboardDestination] {
        guard var components = URLComponents(string: "\(baseURL)/destinations") else {
            throw APIError.invalidURL
        }

        components.queryItems = [
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "limit", value: "\(limit)")
        ]

        guard let url = components.url else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let data = try await authorizedData(for: request)

        return try decodeEnvelope([DashboardDestination].self, from: data, context: "destinations")
    }

    func getAttractionsByDestination(
        destinationSlug: String,
        page: Int = 1,
        limit: Int = 20
    ) async throws -> DestinationAttractionsPayload {
        guard var components = URLComponents(string: "\(baseURL)/destinations/\(destinationSlug)/attractions") else {
            throw APIError.invalidURL
        }

        components.queryItems = [
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "limit", value: "\(limit)")
        ]

        guard let url = components.url else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let data = try await authorizedData(for: request)

        return try decodeEnvelope(DestinationAttractionsPayload.self, from: data, context: "destination attractions")
    }

    func createTrip(_ body: CreateTripRequest) async throws -> CreatedTrip {
        guard let url = URL(string: "\(baseURL)/trips") else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(body)
        printRequestBody(request)
        let data = try await authorizedData(for: request)

        return try decodeEnvelope(CreatedTrip.self, from: data, context: "create trip")
    }

    func generateAITripPreview(tripId: UUID) async throws -> GeneratedItineraryPreview {
        guard let url = URL(string: "\(baseURL)/trips/\(tripId.uuidString)/ai-generate") else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let data = try await authorizedData(for: request)

        return try decodeEnvelope(GeneratedItineraryPreview.self, from: data, context: "ai generate preview")
    }

    func saveTripItinerary(tripId: UUID, body: SaveItineraryRequest) async throws {
        guard let url = URL(string: "\(baseURL)/trips/\(tripId.uuidString.lowercased())/itinerary") else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(body)
        printRequestBody(request)
        _ = try await authorizedData(for: request)
    }
}

private struct ServerErrorResponse: Decodable {
    let message: String
}

private struct RefreshTokenRequest: Encodable {
    let refreshToken: String
}

private struct RefreshTokenResponse: Decodable {
    let accessToken: String
    let refreshToken: String?
    let user: User?
}
