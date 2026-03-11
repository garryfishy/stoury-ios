//
//  ContentView.swift
//  stoury
//
//  Created by Garry Agassi on 10/03/26.
//

import SwiftUI

struct ContentView: View {
    @State private var goToLogin = false

    var body: some View {
        
        
        NavigationStack {
            VStack {
                Button("Go to Login"){
                    goToLogin = true
                }
            }
            .navigationDestination(isPresented: $goToLogin){
                LoginView()
            }
        }
    }
}

#Preview {
    ContentView()
}
