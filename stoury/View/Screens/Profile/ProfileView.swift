//
//  ProfileView.swift
//  stoury
//
//  Created by Muhammad Arfian Praniza on 10/03/26.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var sessionStore: SessionStore

    private var displayName: String {
        sessionStore.currentUser?.name ?? "Pengguna"
    }

    private var displayEmail: String {
        sessionStore.currentUser?.email ?? "-"
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 50) {
                VStack(spacing: 24) {
                    ProfileCard(
                        name: displayName,
                        email: displayEmail
                    )

                    VStack(spacing: 12) {
                        StouryButton(title: "Profil", systemImage: "person", style: .tertiary) {}
                        StouryButton(title: "Keluar", systemImage: "arrow.turn.up.left", style: .tertiary) {
                            Task {
                                await logout()
                            }
                        }
                    }
                }
                .padding(.top, 80)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            }
            .padding(.horizontal, 24)
            .background(Color.white)
            .navigationTitle("Profil")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private func logout() async {
        if let refreshToken = sessionStore.refreshToken {
            let apiService = APIService(sessionStore: sessionStore)
            _ = try? await apiService.logout(refreshToken: refreshToken)
        }

        sessionStore.clearSession()
    }
}

#Preview {
    ProfileView()
        .environmentObject(SessionStore())
}
