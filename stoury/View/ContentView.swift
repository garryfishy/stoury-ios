//
//  ContentView.swift
//  stoury
//
//  Created by Garry Agassi on 10/03/26.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel: DashboardViewModel

    init(sessionStore: SessionStore) {
        _viewModel = StateObject(
            wrappedValue: DashboardViewModel(sessionStore: sessionStore)
        )
    }

    var body: some View {
        VStack {
            Text("Home")

            Button("Logout") {
                viewModel.logout()
            }
        }
    }
}

#Preview {
    ContentView(sessionStore: SessionStore())
}
