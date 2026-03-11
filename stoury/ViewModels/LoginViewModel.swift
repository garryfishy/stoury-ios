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
        self.apiService = apiService ?? APIService()
    }

    func login() async {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Email and password cannot be empty."
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
        }
    }
    
   
}
