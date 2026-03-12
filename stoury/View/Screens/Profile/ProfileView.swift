//
//  ProfileView.swift
//  stoury
//
//  Created by Muhammad Arfian Praniza on 10/03/26.
//

import SwiftUI
struct ProfileView: View {
    @State private var selectedTab: AppTab = .profile

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 24) {
                ProfileCard(
                    name: "Nolan Bergson",
                    email: "nolanbergson@gmail.com"
                )

                VStack(spacing: 12) {
                    StouryButton(title: "Profil", systemImage: "person", style: .secondary) {}
                        .frame(maxWidth: 265)
                        .frame(height: 55)
                        .background(Color("PrimaryOrange").opacity(0.1))
                        .clipShape(Capsule())
                        .overlay(
                            Capsule().stroke(Color("PrimaryOrange"), lineWidth: 1.5)
                        )
                    StouryButton(title: "Keluar", systemImage: "arrow.turn.up.left", style: .secondary) {}
                        .frame(maxWidth: 265)
                        .frame(height: 55)
                        .background(Color("PrimaryOrange").opacity(0.1))
                        .clipShape(Capsule())
                        .overlay(
                            Capsule().stroke(Color("PrimaryOrange"), lineWidth: 1.5)
                        )
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
}

