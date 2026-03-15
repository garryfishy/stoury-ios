import Foundation

extension APIService {
    func printRequestBody(_ request: URLRequest) {
        guard let httpBody = request.httpBody,
              let bodyString = String(data: httpBody, encoding: .utf8) else {
            return
        }

        AppLogger.info("API request body: \(bodyString)")
    }

    func requestLabel(for request: URLRequest) -> String {
        let method = request.httpMethod ?? "REQUEST"
        let url = request.url?.absoluteString ?? "unknown-url"
        return "\(method) \(url)"
    }

    func decodeEnvelope<T: Decodable>(
        _ type: T.Type,
        from data: Data,
        context: String
    ) throws -> T {
        do {
            let decoded = try JSONDecoder().decode(APIResponse<T>.self, from: data)
            return decoded.data
        } catch {
            AppLogger.error("API decoding failed for \(context)", error: error)
            AppLogger.response(data, label: "API raw response for \(context)")
            throw APIError.decodingError
        }
    }

    func applyAuthorization(to request: inout URLRequest) {
        guard let token = sessionStore.accessToken else { return }
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
    }

    func cacheResponseIfNeeded(data: Data, response: URLResponse, for request: URLRequest) {
        guard request.httpMethod == "GET",
              let httpResponse = response as? HTTPURLResponse,
              200...299 ~= httpResponse.statusCode,
              !data.isEmpty else {
            return
        }

        let cachedResponse = CachedURLResponse(response: response, data: data)
        URLCache.shared.storeCachedResponse(cachedResponse, for: request)
    }

    func resolvedResponseData(
        for request: URLRequest,
        data: Data,
        response: URLResponse
    ) throws -> Data {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        if httpResponse.statusCode == 304 {
            if let cachedResponse = URLCache.shared.cachedResponse(for: request) {
                AppLogger.info("API cache hit for 304 response: \(request.url?.absoluteString ?? "")")
                return cachedResponse.data
            }

            AppLogger.info("API received 304 without cached response for: \(request.url?.absoluteString ?? "")")
            throw APIError.serverErrorWithMessage(
                statusCode: 304,
                message: "Resource not modified, but no cached response was available."
            )
        }

        try validateSuccessfulResponse(data: data, response: response)
        cacheResponseIfNeeded(data: data, response: response, for: request)
        return data
    }

    func authorizedData(for request: URLRequest) async throws -> Data {
        var authorizedRequest = request
        applyAuthorization(to: &authorizedRequest)

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await URLSession.shared.data(for: authorizedRequest)
        } catch {
            AppLogger.error("API request failed for \(requestLabel(for: authorizedRequest))", error: error)
            throw error
        }

        if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 401 {
            AppLogger.info("API received 401 for: \(requestLabel(for: authorizedRequest))")

            do {
                try await refreshSession()
            } catch {
                AppLogger.error("API refresh failed after 401 for \(requestLabel(for: authorizedRequest))", error: error)
                throw error
            }

            var retryRequest = request
            applyAuthorization(to: &retryRequest)

            let retryData: Data
            let retryResponse: URLResponse
            do {
                (retryData, retryResponse) = try await URLSession.shared.data(for: retryRequest)
            } catch {
                AppLogger.error("API retry failed for \(requestLabel(for: retryRequest))", error: error)
                throw error
            }

            if let retryHTTPResponse = retryResponse as? HTTPURLResponse, retryHTTPResponse.statusCode == 401 {
                AppLogger.info("API retry still unauthorized, clearing session for: \(requestLabel(for: retryRequest))")
                sessionStore.clearSession()
            }

            return try resolvedResponseData(for: retryRequest, data: retryData, response: retryResponse)
        }

        return try resolvedResponseData(for: authorizedRequest, data: data, response: response)
    }

    func validateSuccessfulResponse(data: Data, response: URLResponse) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        guard 200...299 ~= httpResponse.statusCode else {
            if let serverError = try? JSONDecoder().decode(ServerErrorResponse.self, from: data) {
                AppLogger.info("API server error message: \(serverError.message)")
                throw APIError.serverErrorWithMessage(
                    statusCode: httpResponse.statusCode,
                    message: serverError.message
                )
            }

            AppLogger.response(data, label: "API server error raw body")
            throw APIError.serverError(statusCode: httpResponse.statusCode)
        }
    }
}

private struct ServerErrorResponse: Decodable {
    let message: String
}
