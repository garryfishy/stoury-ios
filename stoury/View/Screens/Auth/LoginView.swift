//
//  LoginView.swift
//  stoury
//
//  Created by Muhammad Arfian Praniza on 10/03/26.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject private var sessionStore: SessionStore
    @StateObject private var viewModel: LoginViewModel

    init(sessionStore: SessionStore? = nil) {
        let store = sessionStore ?? SessionStore()
        _viewModel = StateObject(
            wrappedValue: LoginViewModel(sessionStore: store)
        )
    }

    var body: some View {
        VStack(spacing: 20) {
            Text("Login")
                .font(.title)
                .fontWeight(.semibold)

            TextField("Email", text: $viewModel.email)
                .textInputAutocapitalization(.never)
                .keyboardType(.emailAddress)
                .autocorrectionDisabled()
                .padding()
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 12))

            SecureField("Password", text: $viewModel.password)
                .padding()
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 12))

            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundStyle(.red)
                    .font(.footnote)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            Button {
                Task {
                    await viewModel.login()
                }
            } label: {
                Text(viewModel.isLoading ? "Logging in..." : "Login")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.orange)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .disabled(viewModel.isLoading)

            Button("Mock Login") {
                sessionStore.setSession(
                    AuthSession(
                        accessToken: "debug-access-token",
                        refreshToken: "debug-refresh-token",
                        user: User(
                            id: UUID(),
                            name: "Preview User",
                            email: "preview@stoury.co",
                            roles: ["user"]
                        )
                    )
                )
            }
            .font(.footnote)
        }
        .padding(24)
    }
}

#Preview {
    LoginView(sessionStore: SessionStore())
        .environmentObject(SessionStore())
}
