//
//  SessionPersistenceService.swift
//  stoury
//
//  Created by Codex on 13/03/26.
//

import Foundation
import Security

protocol SessionPersisting {
    func loadSession() -> AuthSession?
    func saveSession(_ session: AuthSession)
    func clearSession()
}

final class SessionPersistenceService: SessionPersisting {
    private let service: String
    private let account = "auth.session"

    init(service: String = Bundle.main.bundleIdentifier ?? "garryfishy.stoury") {
        self.service = service
    }

    func loadSession() -> AuthSession? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)

        guard status == errSecSuccess,
              let data = item as? Data else {
            return nil
        }

        return try? JSONDecoder().decode(AuthSession.self, from: data)
    }

    func saveSession(_ session: AuthSession) {
        guard let data = try? JSONEncoder().encode(session) else {
            return
        }

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]

        let attributes: [String: Any] = [
            kSecValueData as String: data
        ]

        let updateStatus = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)

        if updateStatus == errSecItemNotFound {
            var addQuery = query
            addQuery[kSecValueData as String] = data
            SecItemAdd(addQuery as CFDictionary, nil)
        }
    }

    func clearSession() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]

        SecItemDelete(query as CFDictionary)
    }
}
