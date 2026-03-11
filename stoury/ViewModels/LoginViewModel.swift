//
//  LoginViewModel.swift
//  stoury
//
//  Created by Muhammad Arfian Praniza on 10/03/26.
//

import Foundation
import Combine

@MainActor
final class LoginViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var loggedInUser: User?
    
    private let apiService: APIService

      init(apiService: APIService? = nil) {
          self.apiService = apiService ?? APIService()
      }

    func login() async {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Email and password cannot be empty."
            return
        }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            let login = try await apiService.login(email: email, password: password)
            loggedInUser = login
        } catch {
            errorMessage = errorMessage ?? "Failed to login. Please try again later."
        }
    }
    
    
}
