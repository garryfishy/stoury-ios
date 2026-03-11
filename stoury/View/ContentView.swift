//
//  ContentView.swift
//  stoury
//
//  Created by Garry Agassi on 10/03/26.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel: DashboardViewModel
    @State private var searchText = ""

    init(sessionStore: SessionStore) {
        _viewModel = StateObject(
            wrappedValue: DashboardViewModel(sessionStore: sessionStore)
        )
    }
    
    let columns = [ GridItem(.flexible()), GridItem(.flexible()) ]

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            SearchInputField(text: $searchText)
            
            Text("Yang menarik di Batam")
                .font(.system(size: 20, weight: .bold))
            
            LazyVGrid(columns: columns, spacing: 16){
                PopularCard()
                PopularCard()
                PopularCard()
                PopularCard()
            }


            
            Spacer()
            
        }
        .padding(.vertical, 24)
        .padding(.horizontal, 12)
    }
}

#Preview {
    ContentView(sessionStore: SessionStore())
}
