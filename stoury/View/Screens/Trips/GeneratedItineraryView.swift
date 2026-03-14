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
    private let sessionStore: SessionStore
    private let onSelectAttraction: ((AttractionDetailRoute) -> Void)?

    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL
    @StateObject private var viewModel: GeneratedItineraryViewModel
    @State private var selectedTab: ResultTab = .overview
    @State private var isDrawerExpanded = false
    @State private var sheetDragOffset: CGFloat = 0
    @State private var selectedAttractionRoute: AttractionDetailRoute?

    init(
        sessionStore: SessionStore,
        route: GeneratedTripRoute,
        onSelectAttraction: ((AttractionDetailRoute) -> Void)? = nil
    ) {
        self.route = route
        self.sessionStore = sessionStore
        self.onSelectAttraction = onSelectAttraction
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
                    content(size: proxy.size)
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
        .onReceive(NotificationCenter.default.publisher(for: .returnToHomeRequested)) { _ in
            dismiss()
        }
        .navigationBarBackButtonHidden(true)
        .enableSwipeBack()
        .fullScreenCover(item: $selectedAttractionRoute) { selectedRoute in
            ItineraryDetailView(
                sessionStore: sessionStore,
                route: selectedRoute
            )
        }
    }

    private func content(size: CGSize) -> some View {
        let heroHeight = min(max(size.height * 0.34, 300), 340)
        let sheetTop = currentSheetTopPadding(heroHeight: heroHeight)

        return ZStack(alignment: .top) {
            heroSection(height: heroHeight)
                .clipped()
                .ignoresSafeArea(edges: .top)

            sheetSection(heroHeight: heroHeight)
                .frame(maxHeight: .infinity, alignment: .top)
                .padding(.top, sheetTop)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .clipped()
    }

    private func currentSheetTopPadding(heroHeight: CGFloat) -> CGFloat {
        let collapsed = collapsedSheetTopPadding(heroHeight: heroHeight)
        let expanded = expandedSheetTopPadding
        let basePadding = isDrawerExpanded ? expanded : collapsed
        let proposedPadding = basePadding + sheetDragOffset

        return min(
            collapsed,
            max(expanded, proposedPadding)
        )
    }

    private func collapsedSheetTopPadding(heroHeight: CGFloat) -> CGFloat {
        heroHeight - 80
    }

    private var expandedSheetTopPadding: CGFloat { 54 }

    private func heroSection(height: CGFloat) -> some View {
        ZStack(alignment: .topLeading) {
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [Color.black.opacity(0.12), Color.black.opacity(0.76)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )

            VStack(alignment: .leading, spacing: 12) {
                Spacer()

                Text(route.tripTitle)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(.white)
                    .lineLimit(2)

                VStack(alignment: .leading, spacing: 7) {
                    infoRow(systemImage: "calendar", text: route.displayDateRange)
                    infoRow(systemImage: "location", text: route.destination.locationLine)
                }

                Text(route.destination.description)
                    .font(.system(size: 12))
                    .foregroundStyle(.white.opacity(0.95))
                    .lineSpacing(3)
                    .lineLimit(5)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal, 22)
            .padding(.top, 92)
            .padding(.bottom, 82)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)

            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 36, height: 36)
            }
            .buttonStyle(.plain)
            .padding(.top, 58)
            .padding(.leading, 22)
        }
        .frame(height: height)
        .background {
            AsyncImage(url: route.destination.heroImageUrl) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                case .empty, .failure:
                    LinearGradient(
                        colors: [Color("PrimaryOrange"), Color.black.opacity(0.7)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                @unknown default:
                    Color("PrimaryOrange")
                }
            }
        }
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

    private func sheetSection(heroHeight: CGFloat) -> some View {
        VStack(spacing: 0) {
            sheetChrome(heroHeight: heroHeight)
                .padding(.horizontal, 14)

            tabContent
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
        .padding(.bottom, 18)
        .background(.white)
        .clipShape(
            UnevenRoundedRectangle(
                topLeadingRadius: 24,
                topTrailingRadius: 24
            )
        )
        .shadow(color: .black.opacity(0.08), radius: 12, y: -4)
        .contentShape(Rectangle())
        .simultaneousGesture(drawerGesture(heroHeight: heroHeight))
    }

    private func sheetChrome(heroHeight: CGFloat) -> some View {
        VStack(spacing: 0) {
            drawerHandle

            tabBar
                .padding(.bottom, 14)
        }
        .contentShape(Rectangle())
    }

    private var drawerHandle: some View {
        Capsule()
            .fill(Color.black.opacity(0.14))
            .frame(width: 56, height: 5)
            .padding(.top, 12)
            .padding(.bottom, 20)
            .frame(maxWidth: .infinity)
    }

    private var tabContent: some View {
        TabView(selection: $selectedTab) {
            overviewSection(days: days)
                .tag(ResultTab.overview)

            ForEach(days) { day in
                dayDetailSection(for: day)
                    .tag(ResultTab.day(day.dayNumber))
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
    }

    private var tabBar: some View {
        ScrollViewReader { proxy in
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
                        .id(tab)
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 8)
            }
            .onAppear {
                proxy.scrollTo(selectedTab, anchor: .center)
            }
            .onChange(of: selectedTab) { _, newValue in
                withAnimation(.easeInOut(duration: 0.2)) {
                    proxy.scrollTo(newValue, anchor: .center)
                }
            }
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
            .padding(.horizontal, 10)
            .padding(.bottom, 20)
        }
    }

    private func dayDetailSection(for day: TripItineraryDay) -> some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 8) {
                ForEach(Array(day.items.sorted(by: { $0.orderIndex < $1.orderIndex }).enumerated()), id: \.element.id) { index, item in
                    timelineRow(
                        item,
                        isLast: index == day.items.count - 1,
                        selectedDate: day.date
                    )
                }
            }
            .padding(.horizontal, 8)
            .padding(.bottom, 24)
        }
    }

    private func timelineRow(_ item: TripItineraryItem, isLast: Bool, selectedDate: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Text(item.displayStartTime)
                .font(.system(size: 13, weight: .bold))
                .monospacedDigit()
                .lineLimit(1)
                .minimumScaleFactor(0.9)
                .frame(width: 56, alignment: .leading)
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

            itineraryCard(item, selectedDate: selectedDate)
                .padding(.bottom, 12)
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
    }

    private func itineraryCard(_ item: TripItineraryItem, selectedDate: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Button {
                let route = AttractionDetailRoute(
                    attractionId: item.attractionId,
                    selectedDate: selectedDate
                )
                if let onSelectAttraction {
                    onSelectAttraction(route)
                } else {
                    selectedAttractionRoute = route
                }
            } label: {
                HStack(alignment: .top, spacing: 10) {
                    cardImage(for: item)

                    VStack(alignment: .leading, spacing: 6) {
                        HStack(alignment: .center, spacing: 8) {
                            if let badgeText = item.badgeText {
                                Text(badgeText)
                                    .font(.system(size: 11, weight: .semibold))
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 4)
                                    .background(Color("PrimaryOrange"))
                                    .clipShape(Capsule())
                            }

                            if let ratingText = item.ratingText {
                                HStack(spacing: 4) {
                                    Image(systemName: "star.fill")
                                        .font(.system(size: 10, weight: .semibold))
                                        .foregroundStyle(Color(red: 0.94, green: 0.69, blue: 0.05))

                                    Text(ratingText)
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundStyle(Color.black.opacity(0.76))
                                }
                            }
                        }

                        Text(item.attractionName)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(.primary)
                            .lineLimit(2)

                        Text(item.locationLine)
                            .font(.system(size: 12))
                            .foregroundStyle(Color.black.opacity(0.55))
                            .lineLimit(1)

                        if let budgetText = item.budgetRangeText {
                            Text(budgetText)
                                .font(.system(size: 11.5, weight: .regular))
                                .foregroundStyle(Color.black.opacity(0.68))
                        }

                        if let openingHoursText = item.tripDayOpeningHoursText {
                            HStack(spacing: 4) {
                                Text("Buka:")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundStyle(Color("PrimaryOrange"))

                                Text(openingHoursText)
                                    .font(.system(size: 12, weight: .regular))
                                    .foregroundStyle(Color.black.opacity(0.7))
                            }
                        }

                        if let notes = item.notes, !notes.isEmpty {
                            Text(notes)
                                .font(.system(size: 12))
                                .foregroundStyle(Color.black.opacity(0.55))
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .frame(maxWidth: .infinity, alignment: .leading)

            Button {
                guard let mapsURL = item.appleMapsURL else { return }
                openURL(mapsURL)
            } label: {
                Image("ic-direction")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color("PrimaryOrange"))
                    .frame(width: 20, alignment: .center)
            }
            .buttonStyle(.plain)
            .disabled(item.appleMapsURL == nil)
            .opacity(item.appleMapsURL == nil ? 0.35 : 1)
            .padding(.top, 4)
        }
        .padding(.bottom, 16)
        .padding(.trailing, 8)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(Color.black.opacity(0.1))
                .frame(height: 1)
        }
    }

    private func drawerGesture(heroHeight: CGFloat) -> some Gesture {
        DragGesture(minimumDistance: 8, coordinateSpace: .global)
            .onChanged { value in
                let vertical = value.translation.height
                let horizontal = value.translation.width
                guard abs(vertical) > abs(horizontal) * 0.5 else { return }

                // Apply rubber-banding when dragging beyond bounds
                let collapsed = collapsedSheetTopPadding(heroHeight: heroHeight)
                let expanded = expandedSheetTopPadding
                let basePadding = isDrawerExpanded ? expanded : collapsed
                let proposed = basePadding + vertical

                if proposed < expanded {
                    // Rubber band when dragging above expanded
                    let excess = expanded - proposed
                    sheetDragOffset = vertical + excess * 0.7
                } else if proposed > collapsed {
                    // Rubber band when dragging below collapsed
                    let excess = proposed - collapsed
                    sheetDragOffset = vertical - excess * 0.7
                } else {
                    sheetDragOffset = vertical
                }
            }
            .onEnded { value in
                let vertical = value.translation.height
                let velocity = value.predictedEndTranslation.height - vertical

                let collapsed = collapsedSheetTopPadding(heroHeight: heroHeight)
                let expanded = expandedSheetTopPadding
                let basePadding = isDrawerExpanded ? expanded : collapsed
                let currentPosition = basePadding + vertical

                // Use velocity to determine intent: fast swipe wins regardless of position
                let shouldExpand: Bool
                if abs(velocity) > 200 {
                    shouldExpand = velocity < 0
                } else {
                    let midpoint = (collapsed + expanded) / 2
                    shouldExpand = currentPosition < midpoint
                }

                withAnimation(.spring(response: 0.35, dampingFraction: 0.86)) {
                    isDrawerExpanded = shouldExpand
                    sheetDragOffset = 0
                }
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
        .frame(width: 74, height: 74)
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
            StouryButton(title: "Kembali Ke Beranda", style: .tertiary) {
                NotificationCenter.default.post(name: .returnToHomeRequested, object: nil)
                dismiss()
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
        if let primaryPreferenceName = attraction?.primaryPreference?.name, !primaryPreferenceName.isEmpty {
            return primaryPreferenceName
        }

        if let firstCategory = attraction?.categories.first?.name, !firstCategory.isEmpty {
            return firstCategory
        }

        guard let source, !source.isEmpty else { return nil }
        return source.replacingOccurrences(of: "_", with: " ").capitalized
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

    var tripDayOpeningHoursText: String? {
        guard let attraction else { return nil }

        if attraction.tripDayIsOpen == false {
            return "Tutup"
        }

        guard let ranges = attraction.tripDayOpeningHours else {
            return nil
        }

        guard !ranges.isEmpty else {
            return "Tutup"
        }

        return ranges
            .map { range in
                let open = range.open.replacingOccurrences(of: ":", with: ".")
                let close = range.close.replacingOccurrences(of: ":", with: ".")
                return "\(open) - \(close)"
            }
            .joined(separator: ", ")
    }

    var appleMapsURL: URL? {
        guard let attraction,
              let latitudeString = attraction.latitude,
              let longitudeString = attraction.longitude,
              let latitude = Double(latitudeString),
              let longitude = Double(longitudeString) else {
            return nil
        }

        var components = URLComponents(string: "http://maps.apple.com/")
        components?.queryItems = [
            URLQueryItem(name: "ll", value: "\(latitude),\(longitude)"),
            URLQueryItem(name: "q", value: attraction.name)
        ]

        return components?.url
    }
}
