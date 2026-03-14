//
//  DashboardStore.swift
//  stoury
//
//  Created by Garry Agassi on 11/03/26.
//

import Foundation
import Combine

@MainActor
final class DashboardStore: ObservableObject {
    @Published private(set) var home: DashboardHome?
    @Published private(set) var destinations: [DashboardDestination] = []
    @Published private(set) var selectedDestinationSlug: String?
    @Published private(set) var selectedDestinationAttractions: [DestinationAttractionItem] = []

    var featured: [DashboardFeaturedItem] {
        home?.featured ?? []
    }

    var selectedDestination: DashboardDestination? {
        guard let selectedDestinationSlug else { return nil }
        return destinations.first(where: { $0.slug == selectedDestinationSlug })
    }

    func setDestinations(_ destinations: [DashboardDestination]) {
        self.destinations = destinations
    }

    func setHome(_ home: DashboardHome) {
        self.home = home
    }

    func setSelectedDestination(slug: String?) {
        selectedDestinationSlug = slug
    }

    func setSelectedDestinationAttractions(_ attractions: [DestinationAttractionItem]) {
        selectedDestinationAttractions = attractions
    }

    func clear() {
        home = nil
        destinations = []
        selectedDestinationSlug = nil
        selectedDestinationAttractions = []
    }
}
