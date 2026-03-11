//
//  RootView.swift
//  stoury
//
//  Created by Garry Agassi on 11/03/26.
//

import SwiftUI

struct RootView: View {
    @EnvironmentObject var sessionStore: SessionStore

    var body: some View {
        if sessionStore.isAuthenticated {
            ContentView(sessionStore: sessionStore)
        } else {
            LoginView()
        }
    }
}
