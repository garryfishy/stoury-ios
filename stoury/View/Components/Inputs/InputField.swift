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

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: systemImage)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.orange)

            if isSecure {
                SecureField(title, text: $text)
                    .foregroundColor(.orange)
            } else {
                TextField(title, text: $text)
                    .textInputAutocapitalization(.never)
                    .foregroundColor(.orange)
                    .keyboardType(keyboardType)
            }
        }
        .padding(.horizontal, 16)
        .frame(height: 56)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(Color.orange, lineWidth: 1.5)
        )
    }
}
#Preview {
    VStack(spacing: 16) {
        InputField(title: "Nama akun", systemImage: "person", text: .constant(""))
        InputField(title: "Nomor telpon", systemImage: "phone", text: .constant(""), keyboardType: .phonePad)
        InputField(title: "Kata sandi", systemImage: "lock", text: .constant(""), isSecure: true)
    }
    .padding()
}
