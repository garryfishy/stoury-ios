//
//  stouryApp.swift
//  stoury
//
//  Created by Garry Agassi on 10/03/26.
//

import SwiftUI

@main
struct stouryApp: App {
    @StateObject private var sessionStore = SessionStore()

      
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(sessionStore)
        }
    }
}
