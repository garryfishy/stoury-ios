//
//  PreferencesCard.swift
//  stoury
//
//  Created by Muhammad Arfian Praniza on 12/03/26.
//

import SwiftUI
struct PreferenceItem: Identifiable, Hashable {
    let id: String
    let title: String
    let subtitle: String
    let imageName: String

    init(id: String, title: String, subtitle: String, imageName: String) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.imageName = imageName
    }
}

struct PreferencesCard: View {
    let items: [PreferenceItem]
    @Binding var selectedIDs: Set<String>

    private let cardBackground = Color(red: 0.99, green: 0.97, blue: 0.95)
    private let highlightColor = Color.blue

    var body: some View {
        VStack(spacing: 16) {
            ForEach(items) { item in
                PreferenceRow(
                    item: item,
                    isSelected: selectedIDs.contains(item.id),
                    cardBackground: cardBackground,
                    highlightColor: highlightColor
                ) {
                    toggle(item.id)
                }
            }
        }
        .padding(16)
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
    }

    private func toggle(_ id: String) {
        if selectedIDs.contains(id) {
            selectedIDs.remove(id)
        } else {
            selectedIDs.insert(id)
        }
    }
}

private struct PreferenceRow: View {
    let item: PreferenceItem
    let isSelected: Bool
    let cardBackground: Color
    let highlightColor: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(item.imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 83, height: 77)
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
//                    .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous))

                VStack(alignment: .leading, spacing: 3) {
                    Text(item.title)
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.black)

                    Text(item.subtitle)
                        .font(.system(size: 10, weight: .regular))
                        .foregroundColor(.black)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 0)
            }
            .padding(14)
            .background(cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .stroke(isSelected ? highlightColor : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    PreferencesCard(
        items: [
            PreferenceItem(
                id: "popular",
                title: "Populer",
                subtitle: "Jelajahi destinasi favorit yang paling\nsering dikunjungi traveler.",
                imageName: "pref-populer"
            ),
            PreferenceItem(
                id: "food",
                title: "Makanan",
                subtitle: "Temukan rasa autentik dan rekomendasi\ntempat makan terbaik.",
                imageName: "pref-makanan"
            ),
            PreferenceItem(
                id: "shop",
                title: "Belanja",
                subtitle: "Dari pasar seni hingga mall mewah,\ntemukan surga belanjamu.",
                imageName: "pref-belanja"
            ),
            PreferenceItem(
                id: "history",
                title: "Sejarah",
                subtitle: "Telusuri jejak sejarah dan keindahan\nwarisan masa lalu.",
                imageName: "pref-sejarah"
            )
        ],
        selectedIDs: .constant(["shop"])
    )
    .padding()
}

