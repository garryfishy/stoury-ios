//
//  RootView.swift
//  stoury
//
//  Created by Garry Agassi on 11/03/26.
//

import SwiftUI

struct RootView: View {
    @EnvironmentObject var sessionStore: SessionStore
    @State private var selectedTab: AppTab = .trips

    var body: some View {
        if sessionStore.isAuthenticated {
            if sessionStore.needsPreferences {
                PreferencesView(isPresented: $sessionStore.needsPreferences)
            } else {
                VStack(spacing: 0) {
                    Group {
                        switch selectedTab {
                        case .dashboard:
                            ContentView(sessionStore: sessionStore)
                        case .trips:
                            MyTripsView(sessionStore: sessionStore)
                        case .forum:
                            Text("Forum")
                        case .profile:
                            ProfileView()
                        }
                    }

                    Spacer()

                    BottomNavbar(selectedTab: $selectedTab)
                }
            }
        } else {
            LoginView(sessionStore: sessionStore)
        }
    }
}
