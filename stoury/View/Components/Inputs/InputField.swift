//
//  InputField.swift
//  stoury
//
//  Created by Muhammad Arfian Praniza on 10/03/26.
//

import SwiftUI

struct InputField: View {
    let title: String
    let systemImage: String
    @Binding var text: String
    let isSecure: Bool
    let keyboardType: UIKeyboardType

    @State private var isPasswordVisible = false

    init(
        title: String,
        systemImage: String,
        text: Binding<String>,
        isSecure: Bool = false,
        keyboardType: UIKeyboardType = .default
    ) {
        self.title = title
        self.systemImage = systemImage
        self._text = text
        self.isSecure = isSecure
        self.keyboardType = keyboardType
    }

    private var primaryOrange: Color {
        Color("PrimaryOrange")
    }

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: systemImage)
                .frame(width: 30)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(primaryOrange)

            fieldView
                .frame(maxWidth: .infinity, alignment: .center)

            if isSecure {
                Button {
                    isPasswordVisible.toggle()
                } label: {
                    Image(systemName: isPasswordVisible ? "eye.slash" : "eye")
                        .frame(width: 24)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(primaryOrange)
                }
            } else {
                Spacer()
                    .frame(width: 24)
            }
        }
        .padding(.horizontal, 16)
        .frame(height: 56)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(primaryOrange, lineWidth: 1.5)
        )
    }

    @ViewBuilder
    private var fieldView: some View {
        if isSecure {
            if isPasswordVisible {
                TextField(title, text: $text)
                    .foregroundColor(primaryOrange)
                    .multilineTextAlignment(.center)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled(true)
            } else {
                SecureField(title, text: $text)
                    .foregroundColor(primaryOrange)
                    .multilineTextAlignment(.center)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled(true)
            }
        } else {
            TextField(title, text: $text)
                .foregroundColor(primaryOrange)
                .multilineTextAlignment(.center)
                .keyboardType(keyboardType)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled(true)
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        InputField(title: "Nama akun", systemImage: "person", text: .constant(""))
        InputField(title: "E-mail", systemImage: "envelope", text: .constant(""), keyboardType: .emailAddress)
        InputField(title: "Kata sandi", systemImage: "lock", text: .constant(""), isSecure: true)
    }
    .padding()
}
