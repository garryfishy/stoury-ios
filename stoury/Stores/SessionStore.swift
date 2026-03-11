//
//  AuthSession.swift
//  stoury
//
//  Created by Garry Agassi on 11/03/26.
//

import Foundation
import Combine

@MainActor
final class SessionStore: ObservableObject {
    @Published private(set) var session: AuthSession?

    var isAuthenticated: Bool {
        session != nil
    }

    var currentUser: User? {
        session?.user
    }

    var accessToken: String? {
        session?.accessToken
    }

    func setSession(_ session: AuthSession) {
        self.session = session
    }

    func clearSession() {
        self.session = nil
    }
}
