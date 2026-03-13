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
            if statusCode == 401 || statusCode == 422 {
                return "Server returned status code \(statusCode)."
            }
            return "Server returned status code \(statusCode)."
        case .serverErrorWithMessage(let statusCode, let message):
            return "Server returned status code \(statusCode): \(message)"
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

    private func applyAuthorization(to request: inout URLRequest) {
        guard let token = sessionStore.accessToken else { return }
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
    }

    private func authorizedData(for request: URLRequest) async throws -> Data {
        var request = request
        applyAuthorization(to: &request)

        let (data, response) = try await URLSession.shared.data(for: request)

        if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 401 {
            try await refreshSession()

            var retryRequest = request
            applyAuthorization(to: &retryRequest)

            let (retryData, retryResponse) = try await URLSession.shared.data(for: retryRequest)
            if let retryHTTPResponse = retryResponse as? HTTPURLResponse, retryHTTPResponse.statusCode == 401 {
                sessionStore.clearSession()
            }
            try validateSuccessfulResponse(data: retryData, response: retryResponse)
            return retryData
        }

        try validateSuccessfulResponse(data: data, response: response)
        return data
    }

    private func refreshSession() async throws {
        if let refreshTask {
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

        let (data, response) = try await URLSession.shared.data(for: request)

        do {
            try validateSuccessfulResponse(data: data, response: response)
        } catch {
            sessionStore.clearSession()
            throw error
        }

        do {
            let decoded = try JSONDecoder().decode(APIResponse<RefreshTokenResponse>.self, from: data)
            let refreshedUser = decoded.data.user ?? sessionStore.currentUser

            guard let refreshedUser else {
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
        } catch {
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

        do {
            let decoded = try JSONDecoder().decode(APIResponse<DashboardHome>.self, from: data)
            return decoded.data
        } catch {
            print("Raw JSON:")
            print(String(data: data, encoding: .utf8) ?? "Unable to print JSON")
            print("Actual decoding error:", error)
            throw error
        }
    }

    func getTrips() async throws -> [Trip] {
        guard let url = URL(string: "\(baseURL)/trips") else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let data = try await authorizedData(for: request)

        do {
            let decoded = try JSONDecoder().decode(APIResponse<[Trip]>.self, from: data)
            return decoded.data
        } catch {
            throw APIError.decodingError
        }
    }

    func getTrip(tripId: UUID) async throws -> Trip {
        guard let url = URL(string: "\(baseURL)/trips/\(tripId.uuidString)") else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let data = try await authorizedData(for: request)

        do {
            let decoded = try JSONDecoder().decode(APIResponse<Trip>.self, from: data)
            return decoded.data
        } catch {
            throw APIError.decodingError
        }
    }

    func getTripItinerary(tripId: UUID) async throws -> TripItinerary {
        guard let url = URL(string: "\(baseURL)/trips/\(tripId.uuidString)/itinerary") else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let data = try await authorizedData(for: request)

        do {
            let decoded = try JSONDecoder().decode(APIResponse<TripItinerary>.self, from: data)
            return decoded.data
        } catch {
            throw APIError.decodingError
        }
    }

    func getMyPreferences() async throws -> [Preference] {
        guard let url = URL(string: "\(baseURL)/preferences/me") else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let data = try await authorizedData(for: request)

        do {
            let decoded = try JSONDecoder().decode(APIResponse<[Preference]>.self, from: data)
            return decoded.data
        } catch {
            throw APIError.decodingError
        }
    }

    func getPreferences() async throws -> [Preference] {
        guard let url = URL(string: "\(baseURL)/preferences") else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let data = try await authorizedData(for: request)

        do {
            let decoded = try JSONDecoder().decode(APIResponse<[Preference]>.self, from: data)
            return decoded.data
        } catch {
            throw APIError.decodingError
        }
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

        do {
            let decoded = try JSONDecoder().decode(APIResponse<[DashboardDestination]>.self, from: data)
            return decoded.data
        } catch {
            throw APIError.decodingError
        }
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

        do {
            let decoded = try JSONDecoder().decode(APIResponse<CreatedTrip>.self, from: data)
            return decoded.data
        } catch {
            throw APIError.decodingError
        }
    }

    func generateAITripPreview(tripId: UUID) async throws -> GeneratedItineraryPreview {
        guard let url = URL(string: "\(baseURL)/trips/\(tripId.uuidString)/ai-generate") else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let data = try await authorizedData(for: request)

        do {
            let decoded = try JSONDecoder().decode(APIResponse<GeneratedItineraryPreview>.self, from: data)
            return decoded.data
        } catch {
            throw APIError.decodingError
        }
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
