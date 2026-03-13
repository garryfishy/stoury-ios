//
//  GeneratedItineraryView.swift
//  stoury
//
//  Created by Muhammad Arfian Praniza on 10/03/26.
//

import SwiftUI

struct GeneratedItineraryView: View {
    private enum ResultTab: Hashable {
        case overview
        case day(Int)

        var title: String {
            switch self {
            case .overview:
                return "Overview"
            case .day(let dayNumber):
                return "Hari \(dayNumber)"
            }
        }
    }

    let route: GeneratedTripRoute

    @StateObject private var viewModel: GeneratedItineraryViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTab: ResultTab = .overview

    init(sessionStore: SessionStore, route: GeneratedTripRoute) {
        self.route = route
        _viewModel = StateObject(
            wrappedValue: GeneratedItineraryViewModel(
                tripId: route.tripId,
                sessionStore: sessionStore
            )
        )
    }

    private var days: [TripItineraryDay] {
        (viewModel.itinerary?.days ?? []).sorted { $0.dayNumber < $1.dayNumber }
    }

    private var tabs: [ResultTab] {
        [.overview] + days.map { .day($0.dayNumber) }
    }

    private var selectedDay: TripItineraryDay? {
        guard case let .day(dayNumber) = selectedTab else { return nil }
        return days.first(where: { $0.dayNumber == dayNumber })
    }

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .top) {
                Color(red: 0.97, green: 0.97, blue: 0.96)
                    .ignoresSafeArea()

                if viewModel.isLoading && viewModel.itinerary == nil {
                    loadingState(height: proxy.size.height)
                } else if viewModel.itinerary != nil {
                    content(height: proxy.size.height)
                } else if let errorMessage = viewModel.errorMessage {
                    errorState(errorMessage, height: proxy.size.height)
                } else {
                    emptyState(height: proxy.size.height)
                }
            }
        }
        .task {
            await viewModel.load()
        }
    }

    private func content(height: CGFloat) -> some View {
        VStack(spacing: 0) {
            heroSection(height: min(max(height * 0.34, 280), 340))

            sheetSection()
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .offset(y: -28)
                .padding(.bottom, -28)
        }
        .ignoresSafeArea(edges: .top)
    }

    private func heroSection(height: CGFloat) -> some View {
        ZStack(alignment: .topLeading) {
            AsyncImage(url: route.destination.heroImageUrl) { phase in
                switch phase {
                case .empty:
                    LinearGradient(
                        colors: [Color("PrimaryOrange"), Color.black.opacity(0.7)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                case .failure:
                    LinearGradient(
                        colors: [Color("PrimaryOrange"), Color.black.opacity(0.7)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                @unknown default:
                    Color("PrimaryOrange")
                }
            }

            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [Color.black.opacity(0.15), Color.black.opacity(0.78)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )

            VStack(alignment: .leading, spacing: 18) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundStyle(.white)
                }
                .buttonStyle(.plain)

                Spacer()

                VStack(alignment: .leading, spacing: 12) {
                    Text(route.tripTitle)
                        .font(.system(size: 26, weight: .bold))
                        .foregroundStyle(.white)

                    VStack(alignment: .leading, spacing: 8) {
                        infoRow(systemImage: "calendar", text: route.displayDateRange)
                        infoRow(systemImage: "location", text: route.destination.locationLine)
                    }

                    Text(route.destination.description)
                        .font(.system(size: 14))
                        .foregroundStyle(.white.opacity(0.95))
                        .lineSpacing(4)
                }
            }
            .padding(.horizontal, 22)
            .padding(.top, 58)
            .padding(.bottom, 34)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
        .frame(height: height)
        .clipped()
    }

    private func infoRow(systemImage: String, text: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: systemImage)
                .font(.system(size: 13, weight: .medium))

            Text(text)
                .font(.system(size: 14, weight: .medium))
        }
        .foregroundStyle(.white)
    }

    private func sheetSection() -> some View {
        VStack(spacing: 0) {
            Capsule()
                .fill(Color.black.opacity(0.14))
                .frame(width: 56, height: 5)
                .padding(.top, 12)
                .padding(.bottom, 20)

            tabBar
                .padding(.bottom, 18)

            Group {
                switch selectedTab {
                case .overview:
                    overviewSection(days: days)
                case .day:
                    dayDetailSection(for: selectedDay)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
        .padding(.horizontal, 18)
        .padding(.bottom, 18)
        .background(.white)
        .clipShape(
            UnevenRoundedRectangle(
                topLeadingRadius: 34,
                topTrailingRadius: 34
            )
        )
    }

    private var tabBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 30) {
                ForEach(tabs, id: \.self) { tab in
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedTab = tab
                        }
                    } label: {
                        VStack(spacing: 6) {
                            Text(tab.title)
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundStyle(selectedTab == tab ? Color("PrimaryOrange") : Color.gray.opacity(0.7))

                            Rectangle()
                                .fill(selectedTab == tab ? Color("PrimaryOrange") : Color.clear)
                                .frame(height: 2)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 8)
        }
    }

    private func overviewSection(days: [TripItineraryDay]) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                ForEach(days) { day in
                    VStack(alignment: .leading, spacing: 14) {
                        Text("Day \(day.dayNumber)")
                            .font(.system(size: 17, weight: .bold))
                            .foregroundStyle(.primary)

                        Text(day.overviewRoute)
                            .font(.system(size: 16))
                            .foregroundStyle(Color.black.opacity(0.46))
                            .lineSpacing(4)
                    }
                    .padding(20)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .fill(Color(red: 0.97, green: 0.95, blue: 0.93))
                    )
                }
            }
            .padding(.bottom, 20)
        }
    }

    private func dayDetailSection(for day: TripItineraryDay?) -> some View {
        ScrollView {
            if let day {
                LazyVStack(alignment: .leading, spacing: 8) {
                    ForEach(Array(day.items.sorted(by: { $0.orderIndex < $1.orderIndex }).enumerated()), id: \.element.id) { index, item in
                        timelineRow(item, isLast: index == day.items.count - 1)
                    }
                }
                .padding(.bottom, 24)
            } else {
                Text("Belum ada detail itinerary untuk hari ini.")
                    .font(.system(size: 15))
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 12)
            }
        }
    }

    private func timelineRow(_ item: TripItineraryItem, isLast: Bool) -> some View {
        HStack(alignment: .top, spacing: 14) {
            Text(item.displayStartTime)
                .font(.system(size: 15, weight: .bold))
                .frame(width: 44, alignment: .leading)
                .padding(.top, 6)

            VStack(spacing: 0) {
                Circle()
                    .fill(Color("PrimaryOrange"))
                    .frame(width: 12, height: 12)

                Rectangle()
                    .fill(isLast ? Color.clear : Color.black.opacity(0.18))
                    .frame(width: 2)
                    .frame(maxHeight: .infinity)
                    .padding(.top, 4)
            }
            .frame(width: 12)

            itineraryCard(item)
                .padding(.bottom, 12)
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
    }

    private func itineraryCard(_ item: TripItineraryItem) -> some View {
        HStack(alignment: .top, spacing: 12) {
            cardImage(for: item)

            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .center) {
                    if let badgeText = item.badgeText {
                        Text(badgeText)
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(Color("PrimaryOrange"))
                            .clipShape(Capsule())
                    }

                    if let ratingText = item.ratingText {
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
                                .font(.system(size: 10))
                            Text(ratingText)
                                .font(.system(size: 14, weight: .semibold))
                        }
                        .foregroundStyle(Color("PrimaryOrange"))
                    }

                    Spacer()

                    Image(systemName: "location.north.line.fill")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Color("PrimaryOrange"))
                }

                Text(item.attractionName)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(.primary)

                Text(item.locationLine)
                    .font(.system(size: 14))
                    .foregroundStyle(Color.black.opacity(0.55))

                if let budgetText = item.budgetRangeText {
                    Text(budgetText)
                        .font(.system(size: 13))
                        .foregroundStyle(Color.black.opacity(0.65))
                }

                if let notes = item.notes, !notes.isEmpty {
                    Text(notes)
                        .font(.system(size: 13))
                        .foregroundStyle(Color.black.opacity(0.55))
                }
            }
        }
        .padding(.bottom, 16)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(Color.black.opacity(0.1))
                .frame(height: 1)
        }
    }

    private func cardImage(for item: TripItineraryItem) -> some View {
        Group {
            if let imageURL = item.attraction?.thumbnailImageUrl ?? item.attraction?.mainImageUrl {
                AsyncImage(url: imageURL) { phase in
                    switch phase {
                    case .empty:
                        imagePlaceholder
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                    case .failure:
                        imagePlaceholder
                    @unknown default:
                        imagePlaceholder
                    }
                }
            } else {
                imagePlaceholder
            }
        }
        .frame(width: 88, height: 88)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private var imagePlaceholder: some View {
        ZStack {
            LinearGradient(
                colors: [Color("PrimaryOrange").opacity(0.7), Color("PrimaryOrange").opacity(0.25)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            Image(systemName: "sparkles")
                .font(.system(size: 24, weight: .semibold))
                .foregroundStyle(.white)
        }
    }

    private func loadingState(height: CGFloat) -> some View {
        VStack(spacing: 16) {
            Spacer()
            ProgressView()
                .scaleEffect(1.2)
            Text("Memuat itinerary final...")
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(.secondary)
            Spacer()
        }
        .frame(maxWidth: .infinity, minHeight: height)
    }

    private func errorState(_ message: String, height: CGFloat) -> some View {
        VStack(spacing: 14) {
            Spacer()
            Text("Gagal memuat hasil itinerary.")
                .font(.system(size: 20, weight: .bold))
            Text(message)
                .font(.system(size: 14))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
            StouryButton(title: "Coba Lagi", style: .primary) {
                Task { await viewModel.load() }
            }
            .padding(.horizontal, 24)
            Spacer()
        }
        .frame(maxWidth: .infinity, minHeight: height)
    }

    private func emptyState(height: CGFloat) -> some View {
        VStack(spacing: 12) {
            Spacer()
            Text("Belum ada itinerary yang bisa ditampilkan.")
                .font(.system(size: 16, weight: .medium))
            Spacer()
        }
        .frame(maxWidth: .infinity, minHeight: height)
    }
}

private extension GeneratedTripRoute {
    var displayDateRange: String {
        let parser = DateFormatter()
        parser.locale = Locale(identifier: "en_US_POSIX")
        parser.dateFormat = "yyyy-MM-dd"

        let display = DateFormatter()
        display.locale = Locale(identifier: "id_ID")
        display.dateFormat = "d MMMM yyyy"

        guard let parsedStartDate = parser.date(from: startDate),
              let parsedEndDate = parser.date(from: endDate) else {
            return "\(startDate) - \(endDate)"
        }

        return "\(display.string(from: parsedStartDate)) - \(display.string(from: parsedEndDate))"
    }
}

private extension TripItineraryDay {
    var overviewRoute: String {
        let orderedNames = items
            .sorted { $0.orderIndex < $1.orderIndex }
            .map(\.attractionName)

        guard !orderedNames.isEmpty else {
            return "Belum ada tujuan yang dijadwalkan."
        }

        return orderedNames.joined(separator: "   →   ")
    }
}

private extension TripItineraryItem {
    var displayStartTime: String {
        startTime.replacingOccurrences(of: ":", with: ".")
    }

    var ratingText: String? {
        guard let rawRating = attraction?.rating, !rawRating.isEmpty else { return nil }
        return rawRating
    }

    var badgeText: String? {
        if let firstCategory = attraction?.categories.first?.name, !firstCategory.isEmpty {
            return firstCategory
        }

        return source.isEmpty ? nil : source.replacingOccurrences(of: "_", with: " ").capitalized
    }

    var locationLine: String {
        attraction?.locationLine ?? "Lokasi belum tersedia"
    }

    var budgetRangeText: String? {
        guard let minBudget = estimatedBudgetMin,
              let maxBudget = estimatedBudgetMax else {
            return nil
        }

        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = Locale(identifier: "id_ID")
        formatter.maximumFractionDigits = 0

        let minimum = formatter.string(from: NSNumber(value: minBudget)) ?? "\(minBudget)"
        let maximum = formatter.string(from: NSNumber(value: maxBudget)) ?? "\(maxBudget)"
        return "Rp. \(minimum) - \(maximum)"
    }
}
