import Foundation
import Combine

@MainActor
final class RegisterViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isSuccess = false

    private let apiService: APIService

    init(apiService: APIService? = nil, sessionStore: SessionStore? = nil) {
        if let apiService {
            self.apiService = apiService
        } else {
            let store = sessionStore ?? SessionStore()
            self.apiService = APIService(sessionStore: store)
        }
    }

    func register(name: String, email: String, password: String) async {
        errorMessage = nil
        isLoading = true
        defer { isLoading = false }

        do {
            _ = try await apiService.register(name: name, email: email, password: password)
            isSuccess = true
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
