//
//  AttractionDetailViewModel.swift
//  stoury
//
//  Created by Codex on 14/03/26.
//

import Foundation
import Combine

@MainActor
final class AttractionDetailViewModel: ObservableObject {
    @Published private(set) var attraction: AttractionDetail?
    @Published var isLoading = false
    @Published var errorMessage: String?

    let route: AttractionDetailRoute

    private let apiService: APIService

    init(route: AttractionDetailRoute, sessionStore: SessionStore, apiService: APIService? = nil) {
        self.route = route
        self.apiService = apiService ?? APIService(sessionStore: sessionStore)
    }

    func load() async {
        guard !isLoading else { return }

        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            attraction = try await apiService.getAttraction(attractionId: route.attractionId)
        } catch {
            errorMessage = error.localizedDescription
            AppLogger.error("AttractionDetailViewModel.load failed for attraction \(route.attractionId.uuidString)", error: error)
        }
    }
}
