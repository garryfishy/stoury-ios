//
//  StouryButton.swift
//  stoury
//
//  Created by Muhammad Arfian Praniza on 12/03/26.
//

import SwiftUI
struct StouryButton: View {
    let title: String
    let systemImage: String?
    let style: Style
    let isDisabled: Bool
    let action: () -> Void

    enum Style {
        case secondary
        case primary
    }

    init(
        title: String,
        systemImage: String? = nil,
        style: Style = .secondary,
        isDisabled: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.systemImage = systemImage
        self.style = style
        self.isDisabled = isDisabled
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                if let systemImage {
                    Image(systemName: systemImage)
                        .font(.system(size: 16, weight: .semibold))
                }

                Text(title)
                    .font(.system(size: 16, weight: .semibold))
            }
            .frame(maxWidth: 263)
            .frame(height: 52)
        }
        .foregroundColor(foregroundColor)
        .background(backgroundColor)
        .overlay(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .stroke(borderColor, lineWidth: 1.5)
        )
        .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
        .disabled(isDisabled)
        .opacity(isDisabled ? 0.6 : 1.0)
    }

    private var primaryColor: Color {
        Color("PrimaryOrange")
    }
    
    private var foregroundColor: Color {
        switch style {
        case .secondary:
            return .gray
        case .primary:
            return .white
        }
    }

    private var backgroundColor: Color {
        switch style {
        case .secondary:
            return .clear
        case .primary:
            return primaryColor
        }
    }

    private var borderColor: Color {
        switch style {
        case .secondary:
            return .black
        case .primary:
            return .black
        }
    }
}

#Preview {
    VStack(spacing: 12) {
        StouryButton(title: "Tentukan sendiri", style: .secondary) {}
        StouryButton(title: "Buat rencana dengan AI", systemImage: "sparkles", style: .primary) {}
    }
    .padding()
}
