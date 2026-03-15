import Foundation

enum AppLogger {
    static func info(_ message: @autoclosure () -> String) {
        #if DEBUG
        print(message())
        #endif
    }

    static func error(_ message: @autoclosure () -> String, error: Error? = nil) {
        #if DEBUG
        print(message())
        if let error {
            print("Raw error:", error)
        }
        #endif
    }

    static func response(_ data: Data, label: String) {
        #if DEBUG
        guard let body = String(data: data, encoding: .utf8), !body.isEmpty else {
            return
        }
        print("\(label):", body)
        #endif
    }
}
