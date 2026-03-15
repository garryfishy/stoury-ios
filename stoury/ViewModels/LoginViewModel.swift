import Foundation
import Combine

@MainActor
final class LoginViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let apiService: APIService
    private let sessionStore: SessionStore

    init(sessionStore: SessionStore, apiService: APIService? = nil) {
        self.sessionStore = sessionStore
        self.apiService = apiService ?? APIService(sessionStore: sessionStore)
    }

    func login() async {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Email and password cannot be empty."
            AppLogger.info("LoginViewModel.login validation failed: empty email or password")
            return
        }

        errorMessage = nil
        isLoading = true
        defer { isLoading = false }

        do {
            let session = try await apiService.login(email: email, password: password)
            sessionStore.setSession(session)
        } catch {
            errorMessage = error.localizedDescription
            AppLogger.error("LoginViewModel.login failed", error: error)
        }
    }
}
