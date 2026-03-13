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

    private var primaryOrange: Color {
        Color("PrimaryOrange")
    }

    var body: some View {
        ZStack {
            primaryOrange
                .ignoresSafeArea()

            VStack {
                Spacer()

                VStack(spacing: 16) {
                    VStack(spacing: 6) {
                        Text("Masuk")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.black)

                        Text("Masuk ke akun Anda untuk melanjutkan")
                            .font(.system(size: 12, weight: .regular))
                            .foregroundColor(.gray)
                    }

                    VStack(spacing: 10) {
                        InputField(
                            title: "E-mail",
                            systemImage: "envelope",
                            text: $viewModel.email,
                            keyboardType: .emailAddress
                        )

                        InputField(
                            title: "Kata sandi",
                            systemImage: "lock",
                            text: $viewModel.password,
                            isSecure: true
                        )
                    }

                    HStack {
                        Spacer()
                        Button("Lupa sandi?") {
                            // TODO: navigate to forgot password
                        }
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.blue)
                    }

                    if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .font(.system(size: 12, weight: .regular))
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    Button {
                        Task {
                            await viewModel.login()
                        }
                    } label: {
                        Text(viewModel.isLoading ? "MEMUAT..." : "LANJUTKAN")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 44)
                            .background(Color.blue)
                            .clipShape(Capsule())
                    }
                    .disabled(viewModel.isLoading)

                    HStack(spacing: 4) {
                        Text("Belum memiliki akun?")
                            .font(.system(size: 11, weight: .regular))
                            .foregroundColor(.gray)

                        Button("Buat akun") {
                            // TODO: navigate to register
                        }
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(primaryOrange)
                    }

                    Text("Dengan menekan Lanjutkan,\nAnda menyetujui Syarat & Ketentuan serta Kebijakan Privasi kami.")
                        .font(.system(size: 10, weight: .regular))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                }
                .padding(20)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                .padding(.horizontal, 24)

                Spacer()
            }
        }
    }
}

#Preview {
    LoginView(sessionStore: SessionStore())
        .environmentObject(SessionStore())
}
