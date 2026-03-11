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
    private let sessionStore: SessionStore

    init(sessionStore: SessionStore) {        self.sessionStore = sessionStore
    }
    
    func logout() {
        sessionStore.clearSession()
    }

}
