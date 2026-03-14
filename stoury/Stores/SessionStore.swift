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
    @Published var needsPreferences = false

    private let hasCompletedPreferencesKeyPrefix = "stoury.hasCompletedPreferences."
    private let persistence: SessionPersisting

    init(persistence: SessionPersisting? = nil) {
        let resolvedPersistence = persistence ?? SessionPersistenceService()
        self.persistence = resolvedPersistence
        self.session = resolvedPersistence.loadSession()
        self.needsPreferences = shouldShowPreferences(for: self.session?.user)
    }

    var isAuthenticated: Bool {
        session != nil
    }

    var currentUser: User? {
        session?.user
    }

    var shouldShowPreferencesForCurrentUser: Bool {
        shouldShowPreferences(for: currentUser)
    }

    var accessToken: String? {
        session?.accessToken
    }

    var refreshToken: String? {
        session?.refreshToken
    }

    func setSession(_ session: AuthSession) {
        self.session = session
        needsPreferences = shouldShowPreferences(for: session.user)
        persistence.saveSession(session)
    }

    func updateSessionTokens(accessToken: String, refreshToken: String?) {
        guard let session else { return }

        let updatedSession = AuthSession(
            accessToken: accessToken,
            refreshToken: refreshToken ?? session.refreshToken,
            user: session.user
        )

        setSession(updatedSession)
    }

    func clearSession() {
        self.session = nil
        needsPreferences = false
        persistence.clearSession()
        URLCache.shared.removeAllCachedResponses()
    }

    func markPreferencesCompleted(for user: User?) {
        guard let user else { return }
        let key = hasCompletedPreferencesKeyPrefix + userKey(for: user)
        UserDefaults.standard.set(true, forKey: key)
        needsPreferences = false
    }

    func shouldShowPreferences(for user: User?) -> Bool {
        guard let user else { return false }
        let key = hasCompletedPreferencesKeyPrefix + userKey(for: user)
        let hasCompleted = UserDefaults.standard.bool(forKey: key)
        return !hasCompleted
    }

    private func userKey(for user: User) -> String {
        user.id.uuidString
    }
}
