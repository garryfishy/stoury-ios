import Foundation

extension APIService {
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

        do {
            request.httpBody = try JSONEncoder().encode(body)
        } catch {
            throw APIError.encodingError
        }

        printRequestBody(request)

        let data = try await authorizedData(for: request)
        return try decodeEnvelope([Preference].self, from: data, context: "update preferences")
    }
}
