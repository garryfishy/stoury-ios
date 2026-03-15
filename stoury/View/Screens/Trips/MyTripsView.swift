//
//  MyTripsView.swift
//  stoury
//
//  Created by Muhammad Arfian Praniza on 10/03/26.
//

import SwiftUI

struct MyTripsView: View {
    private enum TripsRoute: Hashable {
        case generateAI
        case itinerary(GeneratedTripRoute)
        case attraction(AttractionDetailRoute)
    }

    @StateObject private var viewModel: MyTripViewModel
    private let sessionStore: SessionStore
    private let onNavigationActiveChange: ((Bool) -> Void)?
    @State private var navigationPath: [TripsRoute] = []

    init(
        sessionStore: SessionStore,
        onNavigationActiveChange: ((Bool) -> Void)? = nil
    ) {
        self.sessionStore = sessionStore
        self.onNavigationActiveChange = onNavigationActiveChange
        _viewModel = StateObject(
            wrappedValue: MyTripViewModel(sessionStore: sessionStore)
        )
    }

    private var upcomingTrips: [Trip] {
        viewModel.trips
            .filter { trip in
                guard let endDate = trip.endDateValue else { return true }
                return endDate >= Calendar.current.startOfDay(for: Date())
            }
            .sorted { lhs, rhs in
                (lhs.startDateValue ?? .distantFuture) < (rhs.startDateValue ?? .distantFuture)
            }
    }

    private var pastTrips: [Trip] {
        viewModel.trips
            .filter { trip in
                guard let endDate = trip.endDateValue else { return false }
                return endDate < Calendar.current.startOfDay(for: Date())
            }
            .sorted { lhs, rhs in
                (lhs.startDateValue ?? .distantPast) > (rhs.startDateValue ?? .distantPast)
            }
    }

    var body: some View {
        NavigationStack(path: $navigationPath) {
            content
                .task {
                    await viewModel.getTrips()
                }
                .onAppear {
                    onNavigationActiveChange?(false)
                }
                .onChange(of: navigationPath.count) { _, newValue in
                    onNavigationActiveChange?(newValue > 0)
                }
                .onReceive(NotificationCenter.default.publisher(for: .returnToHomeRequested)) { _ in
                    navigationPath.removeAll()
                }
                .navigationBarTitleDisplayMode(.inline)
                .toolbar(.hidden, for: .navigationBar)
                .navigationDestination(for: TripsRoute.self) { route in
                    switch route {
                    case .generateAI:
                        GenerateWithAIView(
                            sessionStore: sessionStore,
                            onGeneratedTrip: { generatedRoute in
                                navigationPath.append(.itinerary(generatedRoute))
                            }
                        )
                    case .itinerary(let generatedRoute):
                        GeneratedItineraryView(
                            sessionStore: sessionStore,
                            route: generatedRoute,
                            onSelectAttraction: { attractionRoute in
                                navigationPath.append(.attraction(attractionRoute))
                            }
                        )
                    case .attraction(let attractionRoute):
                        ItineraryDetailView(
                            sessionStore: sessionStore,
                            route: attractionRoute
                        )
                    }
                }
        }
    }

    @ViewBuilder
    private var content: some View {
        VStack(alignment: .leading, spacing: 16) {
            if viewModel.isLoading && viewModel.trips.isEmpty {
                VStack {
                    Spacer()
                    ProgressView("Memuat perjalanan...")
                        .frame(maxWidth: .infinity)
                    Spacer()
                }
            } else if let errorMessage = viewModel.errorMessage, viewModel.trips.isEmpty {
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Perjalanan Saya")
                            .font(.system(size: 28, weight: .bold))

                        Text(errorMessage)
                            .foregroundStyle(.red)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    .frame(maxWidth: .infinity, minHeight: 360, alignment: .topLeading)
                }
                .refreshable {
                    await viewModel.getTrips()
                }
                .background(.white)
            } else if viewModel.trips.isEmpty {
                ScrollView(showsIndicators: false) {
                    EmptyTripView(
                        onGenerateAI: { navigationPath.append(.generateAI) },
                        onManual: {}
                    )
                    .frame(maxWidth: .infinity, minHeight: 520, alignment: .top)
                }
                .refreshable {
                    await viewModel.getTrips()
                }
            } else {
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 28) {
                        HStack(alignment: .center) {
                            Text("Perjalanan Saya")
                                .font(.system(size: 28, weight: .bold))

                            Spacer()

                            Button {
                                navigationPath.append(.generateAI)
                            } label: {
                                Image(systemName: "plus")
                                    .font(.system(size: 22, weight: .bold))
                                    .foregroundStyle(.white)
                                    .frame(width: 50, height: 50)
                                    .background(Color("PrimaryOrange"))
                                    .clipShape(Circle())
                            }
                            .buttonStyle(.plain)
                        }

                        if let errorMessage = viewModel.errorMessage {
                            Text(errorMessage)
                                .font(.system(size: 13, weight: .medium))
                                .foregroundStyle(.red)
                        }

                        if !upcomingTrips.isEmpty {
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Akan Datang")
                                    .font(.system(size: 24, weight: .bold))

                                ForEach(upcomingTrips) { trip in
                                    Button {
                                        navigationPath.append(.itinerary(trip.generatedTripRoute))
                                    } label: {
                                        TripSummaryCard(trip: trip, backgroundColor: Color(.systemGray6))
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }

                        if !pastTrips.isEmpty {
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Sudah Lewat")
                                    .font(.system(size: 24, weight: .bold))

                                ForEach(pastTrips) { trip in
                                    Button {
                                        navigationPath.append(.itinerary(trip.generatedTripRoute))
                                    } label: {
                                        TripSummaryCard(
                                            trip: trip,
                                            backgroundColor: Color(red: 0.97, green: 0.95, blue: 0.92)
                                        )
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                    }
                    .padding(.bottom, 32)
                }
                .refreshable {
                    await viewModel.getTrips()
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .background(.white)
            }
        }
    }
}

#Preview {
    MyTripsView(sessionStore: SessionStore())
}

private struct TripSummaryCard: View {
    let trip: Trip
    let backgroundColor: Color

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            RemoteImageView(url: trip.destination.heroImageUrl, contentMode: .fill) {
                ZStack {
                    backgroundColor.opacity(0.7)
                    Image(systemName: "photo")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundStyle(.gray)
                }
            }
            .frame(width: 98, height: 98)
            .clipShape(RoundedRectangle(cornerRadius: 16))

            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 8) {
                    Image(systemName: "calendar")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(Color(red: 0.38, green: 0.42, blue: 0.5))

                    Text(trip.displayDateRange)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(Color(red: 0.25, green: 0.29, blue: 0.36))
                }

                Text(trip.title)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(.black)
                    .lineLimit(1)

                Text(trip.formattedBudget)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(Color(red: 0.35, green: 0.39, blue: 0.45))
            }

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(backgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }
}

private extension Trip {
    private static let storageFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    var startDateValue: Date? {
        Trip.storageFormatter.date(from: startDate)
    }

    var endDateValue: Date? {
        Trip.storageFormatter.date(from: endDate)
    }

    var displayDateRange: String {
        guard let startDateValue else { return startDate }

        guard let endDateValue else {
            return formatDisplayDate(startDateValue)
        }

        let startDisplay = formatDisplayDate(startDateValue)
        let endDisplay = formatDisplayDate(endDateValue)

        if Calendar.current.isDate(startDateValue, inSameDayAs: endDateValue) {
            return startDisplay
        }

        return "\(startDisplay) - \(endDisplay)"
    }

    private func formatDisplayDate(_ date: Date) -> String {
        let day = Calendar.current.component(.day, from: date)
        let year = Calendar.current.component(.year, from: date)
        let monthIndex = Calendar.current.component(.month, from: date) - 1
        let monthSymbols = ["Jan", "Feb", "Mar", "Apr", "Mei", "Jun", "Jul", "Agu", "Sept", "Okt", "Nov", "Des"]
        let month = monthSymbols.indices.contains(monthIndex) ? monthSymbols[monthIndex] : ""
        return "\(day) \(month) \(year)"
    }

    var formattedBudget: String {
        let cleanedBudget = budget.replacingOccurrences(of: ",", with: ".")
        let value = Decimal(string: cleanedBudget) ?? 0

        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "id_ID")
        formatter.numberStyle = .currency
        formatter.currencyCode = "IDR"
        formatter.maximumFractionDigits = 0

        return formatter.string(from: value as NSDecimalNumber) ?? "Rp0"
    }

    var generatedTripRoute: GeneratedTripRoute {
        GeneratedTripRoute(
            tripId: id,
            tripTitle: title,
            destination: DestinationOption(
                id: destination.id,
                name: destination.name,
                description: destination.description,
                countryName: destination.countryName,
                cityName: destination.cityName,
                regionName: destination.regionName,
                heroImageUrl: destination.heroImageUrl
            ),
            startDate: startDate,
            endDate: endDate
        )
    }
}
