//
//  MyTripViewModel.swift
//  stoury
//
//  Created by Muhammad Arfian Praniza on 10/03/26.
//

import Foundation
import Combine

@MainActor
final class MyTripViewModel: ObservableObject {
    @Published private(set) var trips: [Trip] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let apiService: APIService

    init(sessionStore: SessionStore, apiService: APIService? = nil) {
        self.apiService = apiService ?? APIService(sessionStore: sessionStore)
    }

    func getTrips() async {
        errorMessage = nil
        isLoading = true
        defer { isLoading = false }

        do {
            trips = try await apiService.getTrips()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
