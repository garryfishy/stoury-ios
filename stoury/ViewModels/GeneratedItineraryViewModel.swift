//
//  GeneratedItineraryViewModel.swift
//  stoury
//
//  Created by Codex on 13/03/26.
//

import Foundation
import Combine

@MainActor
final class GeneratedItineraryViewModel: ObservableObject {
    @Published private(set) var itinerary: TripItinerary?
    @Published var isLoading = false
    @Published var errorMessage: String?

    let tripId: UUID

    private let apiService: APIService

    init(tripId: UUID, sessionStore: SessionStore, apiService: APIService? = nil) {
        self.tripId = tripId
        self.apiService = apiService ?? APIService(sessionStore: sessionStore)
    }

    func load() async {
        guard !isLoading else { return }

        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            itinerary = try await apiService.getTripItinerary(tripId: tripId)
        } catch {
            errorMessage = error.localizedDescription
            AppLogger.error("GeneratedItineraryViewModel.load failed for trip \(tripId.uuidString)", error: error)
        }
    }
}
