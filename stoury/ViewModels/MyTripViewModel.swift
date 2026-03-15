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
    @Published var isLoading = true
    @Published var errorMessage: String?

    private let apiService: APIService

    init(sessionStore: SessionStore, apiService: APIService? = nil) {
        self.apiService = apiService ?? APIService(sessionStore: sessionStore)
    }

    func getTrips() async {
        let shouldShowBlockingLoader = trips.isEmpty
        errorMessage = nil

        if shouldShowBlockingLoader {
            isLoading = true
        }

        defer {
            if shouldShowBlockingLoader {
                isLoading = false
            }
        }

        do {
            trips = try await apiService.getTrips()
        } catch {
            if isCancellation(error) {
                return
            }

            errorMessage = error.localizedDescription
            AppLogger.error("MyTripViewModel.getTrips failed", error: error)
        }
    }

    private func isCancellation(_ error: Error) -> Bool {
        if error is CancellationError {
            return true
        }

        if let urlError = error as? URLError, urlError.code == .cancelled {
            return true
        }

        return false
    }
}
