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
    
    let columns = [ GridItem(.flexible()), GridItem(.flexible()) ]
    let rows = [
        GridItem(.fixed(175)),
        GridItem(.fixed(175))
    ]
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 24) {
                
                Text("Yang menarik di Batam")
                    .font(.system(size: 20, weight: .bold))
                
                LazyVGrid(columns: columns, spacing: 16){
                    if viewModel.featured.isEmpty {
                        Text("No data to show")
                    }
                    
                    if viewModel.isLoading {
                        Text("Loading...")                }
                    ForEach(viewModel.featured) {
                        item in PopularCard(imageURL: item.thumbnailImageUrl, labelText: item.badge, title: item.name, subtitle: item.shortLocation)
                    }
                }
                
                Text("Jelajahi lebih banyak di Batam")
                    .font(.system(size: 20, weight: .bold))
                
                ScrollView(.horizontal) {
                    LazyHStack(spacing: 16) {
                        ForEach(viewModel.exploreMore) {
                            item in ExploreMoreCard(imageURL: item.thumbnailImageUrl,
//                                                    labelText: item.badge,
                                                    title: item.name)
                        }
                    }
                }
                
            }
            .padding(.vertical, 24)
            .padding(.horizontal, 12)
            .task {
                await viewModel.getDashboard()
            }
            
        }
    }
}

#Preview {
    ContentView(sessionStore: SessionStore())
}
