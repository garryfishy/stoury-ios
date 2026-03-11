//
//  DashboardViewModel.swift
//  stoury
//
//  Created by Muhammad Arfian Praniza on 10/03/26.
//

import Foundation
import Combine

@MainActor
final class DashboardViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var searchText = ""

    private let sessionStore: SessionStore
    private let dashboardStore: DashboardStore
    private let apiService: APIService
   
    init(
        sessionStore: SessionStore,
    dashboardStore: DashboardStore? = nil,
        apiService: APIService? = nil
    ) {
        self.sessionStore = sessionStore
        self.dashboardStore = dashboardStore ?? DashboardStore()
        self.apiService = apiService ?? APIService(sessionStore: sessionStore)
    }

    var destination: DashboardDestination? {
        dashboardStore.destination
    }

    var featured: [DashboardPlace] {
        dashboardStore.featured
    }

    var exploreMore: [DashboardPlace] {
        dashboardStore.exploreMore
    }
    
    func logout() {
        sessionStore.clearSession()
        dashboardStore.clear()
    }
    
    func getDashboard() async {
        print("DashboardViewModel.getDashboard started")

        errorMessage = nil
        isLoading = true
        defer {
            isLoading = false
            print("DashboardViewModel.getDashboard finished")
        }

        do {
            let home = try await apiService.getDashboard()
            print("Dashboard fetched successfully")
            print("Destination:", home.destination.name)
            print("Featured count:", home.featured.count)
            print("Explore more count:", home.exploreMore.count)

            dashboardStore.setHome(home)

            print("Store updated, featured count now:", dashboardStore.featured.count)
        } catch {
            print("Dashboard fetch failed:", error)
            errorMessage = error.localizedDescription
        }
    }

}
