//
//  DashboardViewModel.swift
//  stoury
//
//  Created by Muhammad Arfian Praniza on 10/03/26.
//

import Foundation
import Combine

@MainActor
final class DashboardViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var isLoadingDestinationAttractions = false
    @Published var isSearching = false
    @Published var isLoadingMoreSearchResults = false
    @Published var errorMessage: String?
    @Published var searchText = ""

    private let sessionStore: SessionStore
    private let dashboardStore: DashboardStore
    private let apiService: APIService
    private let searchLimit = 10
    private var currentSearchPage = 1
    private var hasMoreSearchResults = false
    private var activeSearchQuery = ""
    private var searchResultsStorage: [DashboardFeaturedItem] = []
   
    init(
        sessionStore: SessionStore,
        dashboardStore: DashboardStore? = nil,
        apiService: APIService? = nil
    ) {
        self.sessionStore = sessionStore
        self.dashboardStore = dashboardStore ?? DashboardStore()
        self.apiService = apiService ?? APIService(sessionStore: sessionStore)
    }

    var featured: [DashboardFeaturedItem] {
        dashboardStore.featured
    }

    var featuredTitle: String {
        "Jelajahi rekomendasi kami"
    }

    var destinations: [DashboardDestination] {
        dashboardStore.destinations
    }

    var selectedDestinationSlug: String? {
        dashboardStore.selectedDestinationSlug
    }

    var selectedDestination: DashboardDestination? {
        dashboardStore.selectedDestination
    }

    var selectedDestinationAttractions: [DestinationAttractionItem] {
        dashboardStore.selectedDestinationAttractions
    }

    var searchResults: [DashboardFeaturedItem] {
        searchResultsStorage
    }

    var isSearchActive: Bool {
        !activeSearchQuery.isEmpty
    }
    
    func logout() {
        sessionStore.clearSession()
        dashboardStore.clear()
    }
    
    func getDashboard() async {
        errorMessage = nil
        isLoading = true
        defer { isLoading = false }

        do {
            async let homeTask = apiService.getDashboard()
            async let destinationsTask = apiService.getDestinations()

            let home = try await homeTask
            let destinations = try await destinationsTask
            dashboardStore.setHome(home)
            dashboardStore.setDestinations(destinations)

            let initialDestinationSlug = resolveInitialDestinationSlug(
                featuredDestinationSlug: home.featured.first?.destination?.slug,
                destinations: destinations
            )

            if let initialDestinationSlug {
                dashboardStore.setSelectedDestination(slug: initialDestinationSlug)
                await loadAttractions(for: initialDestinationSlug, showLoader: false)
            } else {
                dashboardStore.setSelectedDestinationAttractions([])
            }
        } catch {
            print("DashboardViewModel.getDashboard failed:", error)
            errorMessage = error.localizedDescription
        }
    }

    func selectDestination(_ destination: DashboardDestination) async {
        guard dashboardStore.selectedDestinationSlug != destination.slug else { return }
        errorMessage = nil
        dashboardStore.setSelectedDestination(slug: destination.slug)
        dashboardStore.setSelectedDestinationAttractions([])
        await loadAttractions(for: destination.slug, showLoader: true)
    }

    func handleSearchQueryChanged(_ query: String) async {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        searchText = query

        guard !trimmedQuery.isEmpty else {
            clearSearch()
            return
        }

        do {
            try await Task.sleep(nanoseconds: 300_000_000)
        } catch {
            return
        }

        guard !Task.isCancelled else { return }
        await search(query: trimmedQuery, reset: true)
    }

    func loadNextSearchPageIfNeeded(currentItem: DashboardFeaturedItem) async {
        guard isSearchActive,
              !isSearching,
              !isLoadingMoreSearchResults,
              hasMoreSearchResults else { return }

        let thresholdItems = searchResultsStorage.suffix(2)
        guard thresholdItems.contains(where: { $0.id == currentItem.id }) else { return }

        await search(query: activeSearchQuery, reset: false)
    }

    private func search(query: String, reset: Bool) async {
        if reset {
            isSearching = true
            currentSearchPage = 1
            hasMoreSearchResults = false
            activeSearchQuery = query
            errorMessage = nil
            searchResultsStorage = []
        } else {
            isLoadingMoreSearchResults = true
        }

        defer {
            if reset {
                isSearching = false
            } else {
                isLoadingMoreSearchResults = false
            }
        }

        let requestedPage = reset ? 1 : currentSearchPage + 1
        let requestedQuery = query

        do {
            let payload = try await apiService.searchDashboard(
                query: requestedQuery,
                page: requestedPage,
                limit: searchLimit
            )

            guard activeSearchQuery == requestedQuery else { return }

            let newItems = payload.items

            if reset {
                searchResultsStorage = newItems
            } else {
                let existingIds = Set(searchResultsStorage.map(\.id))
                searchResultsStorage.append(
                    contentsOf: newItems.filter { !existingIds.contains($0.id) }
                )
            }

            currentSearchPage = requestedPage
            hasMoreSearchResults = newItems.count == searchLimit
        } catch {
            if isCancellation(error) {
                return
            }

            guard activeSearchQuery == requestedQuery else { return }

            if reset {
                searchResultsStorage = []
            }

            hasMoreSearchResults = false
            print("DashboardViewModel.search failed for query '\(requestedQuery)':", error)
            errorMessage = error.localizedDescription
        }
    }

    private func loadAttractions(for slug: String, showLoader: Bool) async {
        if showLoader {
            isLoadingDestinationAttractions = true
        }
        defer {
            if showLoader {
                isLoadingDestinationAttractions = false
            }
        }

        do {
            let payload = try await apiService.getAttractionsByDestination(
                destinationSlug: slug,
                page: 1,
                limit: 100
            )
            dashboardStore.setSelectedDestinationAttractions(payload.items)
        } catch {
            print("DashboardViewModel.loadAttractions failed for \(slug):", error)
            errorMessage = error.localizedDescription
            dashboardStore.setSelectedDestinationAttractions([])
        }
    }

    private func resolveInitialDestinationSlug(
        featuredDestinationSlug: String?,
        destinations: [DashboardDestination]
    ) -> String? {
        if let featuredDestinationSlug,
           destinations.contains(where: { $0.slug == featuredDestinationSlug }) {
            return featuredDestinationSlug
        }

        return destinations.first?.slug
    }

    private func clearSearch() {
        activeSearchQuery = ""
        currentSearchPage = 1
        hasMoreSearchResults = false
        searchResultsStorage = []
        isSearching = false
        isLoadingMoreSearchResults = false
        errorMessage = nil
    }

    private func isCancellation(_ error: Error) -> Bool {
        if error is CancellationError {
            return true
        }

        if let urlError = error as? URLError, urlError.code == .cancelled {
            return true
        }

        return false
    }
}
