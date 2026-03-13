//
//  RegisterView.swift
//  stoury
//
//  Created by Muhammad Arfian Praniza on 10/03/26.
//

import SwiftUI
struct RegisterView: View {
    @Binding var isPresented: Bool
    @StateObject private var viewModel: RegisterViewModel
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage: String? = nil

    init(isPresented: Binding<Bool> = .constant(true), viewModel: RegisterViewModel? = nil) {
        self._isPresented = isPresented
        _viewModel = StateObject(wrappedValue: viewModel ?? RegisterViewModel())
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
                        Text("Daftar")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.black)

                        Text("Silakan daftar untuk masuk")
                            .font(.system(size: 12, weight: .regular))
                            .foregroundColor(.gray)
                    }

                    VStack(spacing: 10) {
                        InputFieldAuth(
                            title: "Nama akun",
                            systemImage: "person",
                            text: $name
                        )

                        InputFieldAuth(
                            title: "E-mail",
                            systemImage: "envelope",
                            text: $email,
                            keyboardType: .emailAddress
                        )

                        InputFieldAuth(
                            title: "Kata sandi",
                            systemImage: "lock",
                            text: $password,
                            isSecure: true
                        )
                    }
                    .onChange(of: name) { _, _ in
                        errorMessage = nil
                        viewModel.errorMessage = nil
                    }
                    .onChange(of: email) { _, _ in
                        errorMessage = nil
                        viewModel.errorMessage = nil
                    }
                    .onChange(of: password) { _, _ in
                        errorMessage = nil
                        viewModel.errorMessage = nil
                    }

                    if let errorMessage = viewModel.errorMessage ?? errorMessage {
                        Text(errorMessage)
                            .font(.system(size: 12, weight: .regular))
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    if viewModel.isSuccess {
                        VStack(spacing: 8) {
                            Text("Akun berhasil dibuat.")
                                .font(.system(size: 12, weight: .regular))
                                .foregroundColor(.green)
                                .frame(maxWidth: .infinity, alignment: .leading)

                            Button {
                                isPresented = false
                            } label: {
                                Text("LOGIN")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 44)
                                    .background(Color.blue)
                                    .clipShape(Capsule())
                            }
                        }
                    } else {
                        Button {
                            let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
                            let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
                            let trimmedPassword = password.trimmingCharacters(in: .whitespacesAndNewlines)

                            if trimmedName.isEmpty || trimmedEmail.isEmpty || trimmedPassword.isEmpty {
                                errorMessage = "Semua field wajib diisi."
                                return
                            }

                            if !trimmedEmail.contains("@gmail.com") {
                                errorMessage = "Format email tidak sesuai."
                                return
                            }

                            let hasUppercase = trimmedPassword.rangeOfCharacter(
                                from: .uppercaseLetters
                            ) != nil
                            let hasLowercase = trimmedPassword.rangeOfCharacter(
                                from: .lowercaseLetters
                            ) != nil
                            let hasMinLength = trimmedPassword.count >= 8
                            let hasSymbol = trimmedPassword.rangeOfCharacter(
                                from: CharacterSet.alphanumerics.inverted
                            ) != nil
                            let hasNumber = trimmedPassword.rangeOfCharacter(
                                from: CharacterSet.decimalDigits
                            ) != nil

                            if !hasUppercase || !hasLowercase || !hasMinLength || !hasSymbol || !hasNumber {
                                errorMessage = "Pastikan password mengandung huruf besar, huruf kecil, angka, dan simbol."
                                return
                            }

                            errorMessage = nil
                            Task {
                                await viewModel.register(
                                    name: trimmedName,
                                    email: trimmedEmail,
                                    password: trimmedPassword
                                )
                            }
                        } label: {
                            Text(viewModel.isLoading ? "MEMUAT..." : "DAFTAR")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 44)
                                .background(Color.blue)
                                .clipShape(Capsule())
                        }
                        .disabled(viewModel.isLoading)

                        HStack(spacing: 4) {
                            Text("Sudah memiliki akun?")
                                .font(.system(size: 11, weight: .regular))
                                .foregroundColor(.gray)

                            Button("Masuk") {
                                isPresented = false
                            }
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(primaryOrange)
                        }
                    }
                }
                .padding(20)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                .padding(.horizontal, 24)

                Spacer()
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    RegisterView(isPresented: .constant(true), viewModel: RegisterViewModel())
}

