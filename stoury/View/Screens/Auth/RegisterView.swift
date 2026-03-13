//
//  RegisterView.swift
//  stoury
//
//  Created by Muhammad Arfian Praniza on 10/03/26.
//

import SwiftUI
struct RegisterView: View {
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""

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
                        InputField(
                            title: "Nama akun",
                            systemImage: "person",
                            text: $name
                        )

                        InputField(
                            title: "E-mail",
                            systemImage: "envelope",
                            text: $email,
                            keyboardType: .emailAddress
                        )

                        InputField(
                            title: "Kata sandi",
                            systemImage: "lock",
                            text: $password,
                            isSecure: true
                        )
                    }

                    Button {
                        // TODO: register action
                    } label: {
                        Text("DAFTAR")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 44)
                            .background(Color.blue)
                            .clipShape(Capsule())
                    }

                    HStack(spacing: 4) {
                        Text("Sudah memiliki akun?")
                            .font(.system(size: 11, weight: .regular))
                            .foregroundColor(.gray)

                        Button("Masuk") {
                            // TODO: navigate to login
                        }
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(primaryOrange)
                    }
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
    RegisterView()
}

