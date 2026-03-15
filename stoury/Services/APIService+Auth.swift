import Foundation

extension APIService {
    func refreshSession() async throws {
        if let refreshTask {
            AppLogger.info("API refresh already in progress, awaiting existing task")
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

    func performRefreshSession() async throws {
        guard let refreshToken = sessionStore.refreshToken else {
            AppLogger.info("API refresh failed: missing refresh token")
            sessionStore.clearSession()
            throw APIError.serverErrorWithMessage(statusCode: 401, message: "Session expired. Please log in again.")
        }

        guard let url = URL(string: "\(baseURL)/auth/refresh") else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            request.httpBody = try JSONEncoder().encode(RefreshTokenRequest(refreshToken: refreshToken))
        } catch {
            throw APIError.encodingError
        }

        printRequestBody(request)

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await URLSession.shared.data(for: request)
        } catch {
            AppLogger.error("API refresh request failed", error: error)
            sessionStore.clearSession()
            throw error
        }

        do {
            try validateSuccessfulResponse(data: data, response: response)
        } catch {
            AppLogger.error("API refresh validation failed", error: error)
            sessionStore.clearSession()
            throw error
        }

        do {
            let decoded = try JSONDecoder().decode(APIResponse<RefreshTokenResponse>.self, from: data)
            let refreshedUser = decoded.data.user ?? sessionStore.currentUser

            guard let refreshedUser else {
                AppLogger.info("API refresh failed: missing refreshed user and no existing session user")
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
            AppLogger.info("API refresh succeeded")
        } catch {
            AppLogger.error("API refresh decoding failed", error: error)
            AppLogger.response(data, label: "API refresh raw response")
            sessionStore.clearSession()
            throw APIError.decodingError
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

        do {
            request.httpBody = try JSONEncoder().encode(loginRequest)
        } catch {
            throw APIError.encodingError
        }

        printRequestBody(request)

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await URLSession.shared.data(for: request)
        } catch {
            AppLogger.error("API login request failed", error: error)
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

        do {
            request.httpBody = try JSONEncoder().encode(registerRequest)
        } catch {
            throw APIError.encodingError
        }

        printRequestBody(request)

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await URLSession.shared.data(for: request)
        } catch {
            AppLogger.error("API register request failed", error: error)
            throw error
        }

        try validateSuccessfulResponse(data: data, response: response)
        return try decodeEnvelope(AuthSession.self, from: data, context: "register")
    }

    func logout(refreshToken: String) async throws {
        guard let url = URL(string: "\(baseURL)/auth/logout") else {
            throw APIError.invalidURL
        }

        let body = LogoutRequest(refreshToken: refreshToken)

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            request.httpBody = try JSONEncoder().encode(body)
        } catch {
            throw APIError.encodingError
        }

        printRequestBody(request)

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await URLSession.shared.data(for: request)
        } catch {
            AppLogger.error("API logout request failed", error: error)
            throw error
        }

        try validateSuccessfulResponse(data: data, response: response)
    }
}

private struct RefreshTokenRequest: Encodable {
    let refreshToken: String
}

private struct RefreshTokenResponse: Decodable {
    let accessToken: String
    let refreshToken: String?
    let user: User?
}
