//
//  PreferencesView.swift
//  stoury
//
//  Created by Muhammad Arfian Praniza on 12/03/26.
//

import SwiftUI

struct PreferencesView: View {
    @EnvironmentObject private var sessionStore: SessionStore
    @Binding var isPresented: Bool
    @State private var selectedIDs: Set<String> = []

    init(isPresented: Binding<Bool> = .constant(true)) {
        self._isPresented = isPresented
    }

    private var primaryOrange: Color {
        Color("PrimaryOrange")
    }

    private var items: [PreferenceItem] {
        [
            PreferenceItem(
                id: "popular",
                title: "Populer",
                subtitle: "Jelajahi destinasi favorit yang paling\nsering dikunjungi traveler.",
                imageName: "populer",
                imageScale: 1.4
            ),
            PreferenceItem(
                id: "food",
                title: "Makanan",
                subtitle: "Temukan rasa autentik dan rekomendasi\ntempat makan terbaik.",
                imageName: "makanan",
                imageScale: 1.4
            ),
            PreferenceItem(
                id: "shop",
                title: "Belanja",
                subtitle: "Dari pasar seni hingga mall mewah,\ntemukan surga belanjamu.",
                imageName: "belanja",
                imageScale: 1.4
            ),
            PreferenceItem(
                id: "history",
                title: "Sejarah",
                subtitle: "Telusuri jejak sejarah dan keindahan\nwarisan masa lalu.",
                imageName: "sejarah",
                imageScale: 1
            )
        ]
    }

    var body: some View {
        NavigationStack {
            ZStack {
                primaryOrange
                    .ignoresSafeArea()

                VStack(spacing: 20) {
                    Text("Apa preferensi liburanmu?")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)

                    PreferencesCard(
                        items: items,
                        selectedIDs: $selectedIDs
                    )

                    Button {
                        if !selectedIDs.isEmpty {
                            sessionStore.markPreferencesCompleted(for: sessionStore.currentUser)
                            isPresented = false
                        }
                    } label: {
                        Text("LANJUTKAN")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: 320)
                            .frame(height: 50)
                            .background(selectedIDs.isEmpty ? Color.gray : Color.blue)
                            .clipShape(Capsule())
                    }
                    .disabled(selectedIDs.isEmpty)
                }
                .padding(.horizontal, 24)
            }
        }
    }
}

#Preview {
    PreferencesView(isPresented: .constant(true))
        .environmentObject(SessionStore())
}

