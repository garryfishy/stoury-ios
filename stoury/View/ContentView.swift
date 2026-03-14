//
//  ContentView.swift
//  stoury
//
//  Created by Garry Agassi on 10/03/26.
//

import SwiftUI
import UIKit

struct ContentView: View {
    @StateObject private var viewModel: DashboardViewModel
    @State private var searchText = ""
    @State private var navigationPath: [AttractionDetailRoute] = []

    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    private let sessionStore: SessionStore

    init(sessionStore: SessionStore) {
        self.sessionStore = sessionStore
        _viewModel = StateObject(
            wrappedValue: DashboardViewModel(sessionStore: sessionStore)
        )
    }

    var body: some View {
        NavigationStack(path: $navigationPath) {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 28) {
                    searchSection
                    featuredSection
                    destinationSection
                }
                .padding(.vertical, 24)
                .padding(.horizontal, 20)
                .contentShape(Rectangle())
            }
            .scrollDismissesKeyboard(.interactively)
            .simultaneousGesture(
                TapGesture().onEnded {
                    dismissKeyboard()
                }
            )
            .task {
                await viewModel.getDashboard()
            }
            .task(id: normalizedSearchQuery) {
                await viewModel.handleSearchQueryChanged(normalizedSearchQuery)
            }
            .navigationDestination(for: AttractionDetailRoute.self) { route in
                ItineraryDetailView(sessionStore: sessionStore, route: route)
            }
            .navigationBarBackButtonHidden(true)
            .toolbar(.hidden, for: .navigationBar)
        }
    }

    private var normalizedSearchQuery: String {
        searchText.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var showingSearchDropdown: Bool {
        !normalizedSearchQuery.isEmpty
    }

    private var searchSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SearchInputField(text: $searchText)

            if showingSearchDropdown {
                searchDropdown
            }
        }
    }

    private var featuredSection: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text(viewModel.featuredTitle)
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(.black)

            if viewModel.isLoading && viewModel.featured.isEmpty {
                dashboardLoader
            } else if viewModel.featured.isEmpty {
                sectionEmptyState("Belum ada rekomendasi untuk ditampilkan.")
            } else {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(viewModel.featured) { item in
                        Button {
                            openAttractionDetail(for: item.id)
                        } label: {
                            PopularCard(
                                imageURL: item.thumbnailImageUrl,
                                labelText: item.badge,
                                title: item.name,
                                subtitle: item.shortLocation
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    private var searchDropdown: some View {
        VStack(alignment: .leading, spacing: 0) {
            if viewModel.isSearching && viewModel.searchResults.isEmpty {
                dropdownMessageRow("Mencari...")
            } else if let errorMessage = viewModel.errorMessage,
                      !errorMessage.isEmpty,
                      viewModel.searchResults.isEmpty {
                dropdownMessageRow(errorMessage, isError: true)
            } else if viewModel.searchResults.isEmpty {
                dropdownMessageRow("Tidak ada hasil untuk \"\(normalizedSearchQuery)\".")
            } else {
                ForEach(viewModel.searchResults) { item in
                    Button {
                        searchText = ""
                        openAttractionDetail(for: item.id)
                    } label: {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(item.name)
                                .font(.system(size: 18, weight: .medium))
                                .foregroundStyle(.black)
                                .lineLimit(1)

                            Text(item.shortLocation)
                                .font(.system(size: 14))
                                .foregroundStyle(.black.opacity(0.65))
                                .lineLimit(1)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 18)
                        .padding(.vertical, 14)
                    }
                    .buttonStyle(.plain)
                    .onAppear {
                        Task {
                            await viewModel.loadNextSearchPageIfNeeded(currentItem: item)
                        }
                    }

                    if item.id != viewModel.searchResults.last?.id {
                        Divider()
                            .padding(.leading, 18)
                    }
                }

                if viewModel.isLoadingMoreSearchResults {
                    HStack {
                        Spacer()
                        ProgressView()
                            .tint(Color("PrimaryOrange"))
                            .padding(.vertical, 12)
                        Spacer()
                    }
                }
            }
        }
        .background(.white)
        .overlay {
            RoundedRectangle(cornerRadius: 24)
                .stroke(Color("PrimaryOrange").opacity(0.7), lineWidth: 1)
        }
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 3)
    }

    private var destinationSection: some View {
        VStack(alignment: .leading, spacing: 18) {
            destinationTabs

            if let errorMessage = viewModel.errorMessage,
               !errorMessage.isEmpty,
               viewModel.selectedDestinationAttractions.isEmpty,
               !viewModel.isLoadingDestinationAttractions,
               !viewModel.isLoading {
                Text(errorMessage)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(.red)
            }

            if viewModel.isLoadingDestinationAttractions {
                dashboardLoader
            } else if viewModel.destinations.isEmpty && !viewModel.isLoading {
                sectionEmptyState("Belum ada destinasi yang tersedia.")
            } else if viewModel.selectedDestinationAttractions.isEmpty {
                sectionEmptyState("Belum ada atraksi untuk destinasi ini.")
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: 16) {
                        ForEach(viewModel.selectedDestinationAttractions) { item in
                            Button {
                                openAttractionDetail(for: item.id)
                            } label: {
                                ExploreMoreCard(
                                    imageURL: item.thumbnailImageUrl ?? item.mainImageUrl,
                                    title: item.name
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
        }
    }

    private var destinationTabs: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 24) {
                ForEach(viewModel.destinations) { destination in
                    destinationTab(destination)
                }
            }
            .padding(.vertical, 2)
        }
    }

    private func destinationTab(_ destination: DashboardDestination) -> some View {
        let isSelected = viewModel.selectedDestinationSlug == destination.slug

        return Button {
            Task {
                await viewModel.selectDestination(destination)
            }
        } label: {
            VStack(alignment: .leading, spacing: 6) {
                Text(destination.name)
                    .font(.system(size: 18, weight: isSelected ? .semibold : .regular))
                    .foregroundStyle(isSelected ? Color("PrimaryOrange") : Color.black)

                Rectangle()
                    .fill(isSelected ? Color("PrimaryOrange") : .clear)
                    .frame(height: 2)
            }
        }
        .buttonStyle(.plain)
    }

    private var dashboardLoader: some View {
        HStack {
            Spacer()
            ProgressView()
                .progressViewStyle(.circular)
                .tint(Color("PrimaryOrange"))
                .padding(.vertical, 20)
            Spacer()
        }
    }

    private func sectionEmptyState(_ message: String) -> some View {
        Text(message)
            .font(.system(size: 14))
            .foregroundStyle(.gray)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 8)
    }

    private func dropdownMessageRow(_ message: String, isError: Bool = false) -> some View {
        Text(message)
            .font(.system(size: 14, weight: .medium))
            .foregroundStyle(isError ? .red : .gray)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 18)
            .padding(.vertical, 18)
    }

    private func openAttractionDetail(for attractionId: UUID) {
        dismissKeyboard()
        navigationPath.append(
            AttractionDetailRoute(
                attractionId: attractionId,
                selectedDate: nil
            )
        )
    }

    private func dismissKeyboard() {
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil,
            from: nil,
            for: nil
        )
    }
}

#Preview {
    ContentView(sessionStore: SessionStore())
}
