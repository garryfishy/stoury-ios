import Foundation

extension APIService {
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
}
