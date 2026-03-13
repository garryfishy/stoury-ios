//
//  PreferencesView.swift
//  stoury
//
//  Created by Muhammad Arfian Praniza on 12/03/26.
//

import SwiftUI

struct PreferencesView: View {
    @EnvironmentObject private var sessionStore: SessionStore
    @State private var selectedIDs: Set<String> = []
    @State private var showDashboard = false

    private var primaryOrange: Color {
        Color("PrimaryOrange")
    }

    private var items: [PreferenceItem] {
        [
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

                    StouryButton(title: "Lanjutkan", style: .primary) {
                        showDashboard = true
                    }
                }
                .padding(.horizontal, 24)
            }
            .navigationDestination(isPresented: $showDashboard) {
                ContentView(sessionStore: sessionStore)
            }
        }
    }
}

#Preview {
    PreferencesView()
        .environmentObject(SessionStore())
}
