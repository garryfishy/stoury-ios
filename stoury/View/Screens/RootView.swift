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
    @State private var dashboardHasSubpage = false
    @State private var tripsHasSubpage = false
    @State private var isCheckingPreferences = false

    private var preferencesAPI: APIService {
        APIService(sessionStore: sessionStore)
    }

    private var shouldShowBottomNavbar: Bool {
        switch selectedTab {
        case .dashboard:
            return !dashboardHasSubpage
        case .trips:
            return !tripsHasSubpage
        case .forum, .profile:
            return true
        }
    }

    var body: some View {
        Group {
            if sessionStore.isAuthenticated {
                if sessionStore.needsPreferences {
                    PreferencesView(
                        isPresented: $sessionStore.needsPreferences,
                        sessionStore: sessionStore
                    )
                    .environmentObject(sessionStore)
                } else {
                    VStack(spacing: 0) {
                        Group {
                            switch selectedTab {
                            case .dashboard:
                                ContentView(
                                    sessionStore: sessionStore,
                                    onNavigationActiveChange: { isActive in
                                        dashboardHasSubpage = isActive
                                    }
                                )
                            case .trips:
                                MyTripsView(
                                    sessionStore: sessionStore,
                                    onNavigationActiveChange: { isActive in
                                        tripsHasSubpage = isActive
                                    }
                                )
                            case .forum:
                                ForumComingSoonView()
                            case .profile:
                                ProfileView()
                            }
                        }

                        if shouldShowBottomNavbar {
                            Spacer()
                            BottomNavbar(selectedTab: $selectedTab)
                        }
                    }
                }
            } else {
                LoginView(sessionStore: sessionStore)
            }
        }
        .task(id: sessionStore.currentUser?.id) {
            await resolvePreferencesGate()
        }
    }

    private func resolvePreferencesGate() async {
        guard sessionStore.isAuthenticated else {
            isCheckingPreferences = false
            return
        }

        guard !isCheckingPreferences else { return }

        isCheckingPreferences = true
        defer {
            isCheckingPreferences = false
        }

        do {
            let myPreferences = try await preferencesAPI.getMyPreferences()
            sessionStore.updatePreferencesRequirement(hasPreferences: !myPreferences.isEmpty)
        } catch {
            AppLogger.error("RootView.resolvePreferencesGate failed", error: error)
        }
    }
}

private struct ForumComingSoonView: View {
    var body: some View {
        VStack {
            Spacer()

            Text("Coming Soon")
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(Color("PrimaryOrange"))

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.white)
    }
}
