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

    var destination: DashboardDestination? {
        home?.destination
    }

    var featured: [DashboardPlace] {
        home?.featured ?? []
    }

    var exploreMore: [DashboardPlace] {
        home?.exploreMore ?? []
    }

    func setHome(_ home: DashboardHome) {
        self.home = home
    }

    func clear() {
        home = nil
    }
}
