import Foundation

final class APIService {
    let baseURL = "https://stoury-api.oceandigital.id/api"
    let sessionStore: SessionStore
    var refreshTask: Task<Void, Error>?

    init(sessionStore: SessionStore) {
        self.sessionStore = sessionStore
    }
}
