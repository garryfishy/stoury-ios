//
//  TripCard.swift
//  stoury
//
//  Created by Muhammad Arfian Praniza on 10/03/26.
//

import SwiftUI

struct TripCard: View {
    let title: String
    let subtitle: String
    let description: String
    let primaryTitle: String
    let secondaryTitle: String
    let onPrimary: () -> Void
    let onSecondary: () -> Void
    init(
        title: String,
        subtitle: String,
        description: String,
        primaryTitle: String,
        secondaryTitle: String,
        onPrimary: @escaping () -> Void,
        onSecondary: @escaping () -> Void
    ) {
        self.title = title
        self.subtitle = subtitle
        self.description = description
        self.primaryTitle = primaryTitle
        self.secondaryTitle = secondaryTitle
        self.onPrimary = onPrimary
        self.onSecondary = onSecondary
    }

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "globe.asia.australia.fill")
                .font(.system(size: 42, weight: .semibold))
                .foregroundColor(.orange)

            Text(title)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.black)
                .multilineTextAlignment(.center)

            VStack(spacing: 0) {
                Text(subtitle)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(.gray)

                Text(description)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
            }

            VStack(spacing: 12) {
                StouryButton(title: secondaryTitle, style: .outline, action: onSecondary)
                StouryButton(title: primaryTitle, systemImage: "sparkles", style: .filled, action: onPrimary)
            }
            .padding(.top, 4)
            .padding(.horizontal, 10)
        }
        .padding(20)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 4)
    }
}

#Preview {
    TripCard(
        title: "Siap menjelajah hari ini?",
        subtitle: "Batam, Jogja, atau Bali?",
        description: "Buat perjalananmu sendiri atau biarkan AI\nkami membantumu menjelajahi kota pilihan.",
        primaryTitle: "Buat rencana dengan AI",
        secondaryTitle: "Tentukan sendiri",
        onPrimary: {},
        onSecondary: {}
    )
    .padding()
}

