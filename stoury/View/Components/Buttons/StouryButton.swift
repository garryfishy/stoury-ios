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
        case tertiary
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
            ZStack {
                HStack {
                    if let systemImage {
                        Image(systemName: systemImage)
                            .font(.system(size: 18, weight: .semibold))
                    }

                    Spacer(minLength: 0)
                }

                Text(title)
                    .font(.system(size: 18, weight: .semibold))
            }
            .padding(.horizontal, 20)
            .frame(maxWidth: .infinity)
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
    }

    private var primaryColor: Color {
        Color("PrimaryOrange")
    }

    private var disabledBackgroundColor: Color {
        Color(.systemGray5)
    }

    private var disabledForegroundColor: Color {
        Color(.systemGray)
    }

    private var disabledBorderColor: Color {
        Color.clear
    }

    private var tertiaryBackgroundColor: Color {
        Color(red: 1.0, green: 0.97, blue: 0.94)
    }

    private var foregroundColor: Color {
        if isDisabled {
            return disabledForegroundColor
        }

        switch style {
        case .secondary:
            return .gray
        case .primary:
            return .white
        case .tertiary:
            return primaryColor
        }
    }

    private var backgroundColor: Color {
        if isDisabled {
            return disabledBackgroundColor
        }

        switch style {
        case .secondary:
            return .clear
        case .primary:
            return primaryColor
        case .tertiary:
            return tertiaryBackgroundColor
        }
    }

    private var borderColor: Color {
        if isDisabled {
            return disabledBorderColor
        }

        switch style {
        case .secondary:
            return .black
        case .primary:
            return .black
        case .tertiary:
            return primaryColor
        }
    }
}

#Preview {
    VStack(spacing: 12) {
        StouryButton(title: "Tentukan sendiri", style: .secondary) {}
        StouryButton(title: "Buat rencana dengan AI", systemImage: "sparkles", style: .primary) {}
        StouryButton(title: "Profil", systemImage: "person", style: .tertiary) {}
        StouryButton(title: "Disabled", systemImage: "sparkles", style: .primary, isDisabled: true) {}
    }
    .padding()
}
