//
//  ProfileView.swift
//  stoury
//
//  Created by Muhammad Arfian Praniza on 10/03/26.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var sessionStore: SessionStore
    @State private var selectedTab: AppTab = .profile

    private var displayName: String {
        sessionStore.currentUser?.name ?? "Pengguna"
    }

    private var displayEmail: String {
        sessionStore.currentUser?.email ?? "-"
    }

    var body: some View {
        VStack(spacing: 50) {
            Spacer()
            VStack(spacing: 24) {
                ProfileCard(
                    name: displayName,
                    email: displayEmail
                )

                VStack(spacing: 12) {
                    StouryButton(title: "Profil", systemImage: "person", style: .secondary) {}
                    StouryButton(title: "Keluar", systemImage: "arrow.turn.up.left", style: .secondary) {}
                }
            }
            .padding(.top, 80)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)

            BottomNavbar(selectedTab: $selectedTab)
        }
        .padding(.horizontal, 24)
        .background(Color.white)
    }
}

#Preview {
    ProfileView()
        .environmentObject(SessionStore())
}

