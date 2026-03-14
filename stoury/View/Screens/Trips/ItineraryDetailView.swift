//
//  ItineraryDetailView.swift
//  stoury
//
//  Created by Muhammad Arfian Praniza on 10/03/26.
//

import SwiftUI

struct ItineraryDetailView: View {
    let route: AttractionDetailRoute

    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: AttractionDetailViewModel
    @State private var isOpeningHoursExpanded = true
    @State private var selectedPhoto: AttractionPhoto?

    init(sessionStore: SessionStore, route: AttractionDetailRoute) {
        self.route = route
        _viewModel = StateObject(
            wrappedValue: AttractionDetailViewModel(
                route: route,
                sessionStore: sessionStore
            )
        )
    }

    var body: some View {
        VStack(spacing: 0) {
            headerBar

            if viewModel.isLoading && viewModel.attraction == nil {
                loadingState
            } else if let attraction = viewModel.attraction {
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 22) {
                        heroImage(for: attraction)
                        attractionSummary(for: attraction)
                        photosSection(for: attraction)
                        descriptionSection(for: attraction)
                        openingHoursSection(for: attraction)
                        locationSection(for: attraction)
                    }
                    .padding(.bottom, 32)
                }
            } else if let errorMessage = viewModel.errorMessage {
                errorState(errorMessage)
            } else {
                emptyState
            }
        }
        .background(.white)
        .ignoresSafeArea(edges: .bottom)
        .task {
            await viewModel.load()
        }
        .onReceive(NotificationCenter.default.publisher(for: .returnToHomeRequested)) { _ in
            dismiss()
        }
        .navigationBarBackButtonHidden(true)
        .enableSwipeBack()
        .fullScreenCover(item: $selectedPhoto) { photo in
            AttractionPhotoPreview(photo: photo)
        }
    }

    private var headerBar: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.black)
                    .frame(width: 36, height: 36)
            }
            .buttonStyle(.plain)

            Spacer()

            Text(viewModel.attraction?.name ?? "Detail Atraksi")
                .font(.system(size: 18, weight: .semibold))
                .lineLimit(1)

            Spacer()

            Color.clear
                .frame(width: 36, height: 36)
        }
        .padding(.horizontal, 16)
        .padding(.top, 10)
        .padding(.bottom, 12)
    }

    private var loadingState: some View {
        VStack(spacing: 16) {
            Spacer()
            ProgressView()
            Text("Memuat detail atraksi...")
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(.secondary)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func errorState(_ message: String) -> some View {
        VStack(spacing: 16) {
            Spacer()
            Text("Gagal memuat detail atraksi.")
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
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var emptyState: some View {
        VStack {
            Spacer()
            Text("Detail atraksi belum tersedia.")
                .font(.system(size: 16, weight: .medium))
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func heroImage(for attraction: AttractionDetail) -> some View {
        AsyncImage(url: attraction.mainImageUrl ?? attraction.thumbnailImageUrl) { phase in
            switch phase {
            case .success(let image):
                image
                    .resizable()
                    .scaledToFill()
            case .empty, .failure:
                Rectangle()
                    .fill(Color(.systemGray5))
                    .overlay {
                        Image(systemName: "photo")
                            .font(.system(size: 28, weight: .medium))
                            .foregroundStyle(.gray)
                    }
            @unknown default:
                Color(.systemGray5)
            }
        }
        .frame(height: 240)
        .clipped()
    }

    private func attractionSummary(for attraction: AttractionDetail) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top, spacing: 12) {
                Text(attraction.name)
                    .font(.system(size: 30, weight: .bold))
                    .foregroundStyle(.black)
                    .lineLimit(2)

                Spacer()

                if let preferenceName = attraction.primaryPreference?.name, !preferenceName.isEmpty {
                    Text(preferenceName)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color("PrimaryOrange"))
                        .clipShape(Capsule())
                }
            }

            HStack(spacing: 6) {
                Image(systemName: "location")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(Color.black.opacity(0.55))

                Text(attraction.shortLocation ?? attraction.locationLine)
                    .font(.system(size: 14))
                    .foregroundStyle(Color.black.opacity(0.6))
                    .lineLimit(1)
            }

            if let ratingText = attraction.ratingText {
                HStack(spacing: 8) {
                    HStack(spacing: 2) {
                        ForEach(0..<5, id: \.self) { _ in
                            Image(systemName: "star.fill")
                                .font(.system(size: 12))
                                .foregroundStyle(Color(red: 0.94, green: 0.69, blue: 0.05))
                        }
                    }

                    Text(ratingText)
                        .font(.system(size: 17, weight: .medium))
                        .foregroundStyle(Color.black.opacity(0.8))
                }
            }
        }
        .padding(.horizontal, 20)
    }

    @ViewBuilder
    private func photosSection(for attraction: AttractionDetail) -> some View {
        let photos = attraction.displayPhotos

        if !photos.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                Text("Foto")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(.black)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(photos) { photo in
                            Button {
                                selectedPhoto = photo
                            } label: {
                                AsyncImage(url: photo.url) { phase in
                                    switch phase {
                                    case .success(let image):
                                        image
                                            .resizable()
                                            .scaledToFill()
                                    case .empty, .failure:
                                        Rectangle()
                                            .fill(Color(.systemGray5))
                                    @unknown default:
                                        Color(.systemGray5)
                                    }
                                }
                                .frame(width: 88, height: 64)
                                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
        }
    }

    private func descriptionSection(for attraction: AttractionDetail) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Tentang")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(.black)

            Text(attraction.description ?? "Deskripsi belum tersedia.")
                .font(.system(size: 14))
                .foregroundStyle(Color.black.opacity(0.62))
                .lineSpacing(4)
        }
        .padding(.horizontal, 20)
    }

    private func openingHoursSection(for attraction: AttractionDetail) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isOpeningHoursExpanded.toggle()
                }
            } label: {
                HStack {
                    Text("Jam Operasional")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(.black)

                    Spacer()

                    Image(systemName: isOpeningHoursExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.black)
                }
            }
            .buttonStyle(.plain)

            if isOpeningHoursExpanded {
                VStack(alignment: .leading, spacing: 10) {
                    Text(attraction.openStatusLine(selectedDate: route.selectedDate))
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(Color.black.opacity(0.68))

                    ForEach(attraction.openingHourRows(selectedDate: route.selectedDate)) { row in
                        HStack {
                            Text(row.label)
                                .font(.system(size: 14, weight: row.isHighlighted ? .semibold : .regular))
                                .foregroundStyle(.black)

                            Spacer()

                            Text(row.hours)
                                .font(.system(size: 14, weight: row.isHighlighted ? .semibold : .regular))
                                .foregroundStyle(Color.black.opacity(0.76))
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(row.isHighlighted ? Color("Beige") : Color.clear)
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    }
                }
            }
        }
        .padding(.horizontal, 20)
    }

    @ViewBuilder
    private func locationSection(for attraction: AttractionDetail) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Lokasi")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(.black)

            if let latitude = attraction.latitudeValue, let longitude = attraction.longitudeValue {
                MapPreview(
                    title: attraction.name,
                    latitude: latitude,
                    longitude: longitude
                )
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            } else {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color(.systemGray6))
                    .frame(height: 180)
                    .overlay {
                        Text("Koordinat lokasi belum tersedia.")
                            .font(.system(size: 14))
                            .foregroundStyle(.secondary)
                    }
            }
        }
        .padding(.horizontal, 20)
    }
}

private struct OpeningHoursRow: Identifiable {
    let key: String
    let label: String
    let hours: String
    let isHighlighted: Bool

    var id: String { key }
}

private struct AttractionPhotoPreview: View {
    let photo: AttractionPhoto

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Color.black
                .ignoresSafeArea()

            AsyncImage(url: photo.url) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 40)
                case .empty:
                    ProgressView()
                        .tint(.white)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                case .failure:
                    VStack(spacing: 12) {
                        Image(systemName: "photo")
                            .font(.system(size: 32, weight: .medium))
                        Text("Foto tidak bisa ditampilkan.")
                            .font(.system(size: 15, weight: .medium))
                    }
                    .foregroundStyle(.white.opacity(0.85))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                @unknown default:
                    EmptyView()
                }
            }

            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 36, height: 36)
                    .background(Color.white.opacity(0.16))
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
            .padding(.top, 18)
            .padding(.trailing, 18)
        }
    }
}

private extension AttractionDetail {
    var displayPhotos: [AttractionPhoto] {
        if !photos.isEmpty {
            return photos
        }

        return [mainImageUrl, thumbnailImageUrl]
            .compactMap { $0 }
            .enumerated()
            .map { index, url in
                AttractionPhoto(url: url, type: index == 0 ? "main" : "thumbnail")
            }
    }

    var locationLine: String {
        guard let fullAddress, !fullAddress.isEmpty else {
            return "Lokasi belum tersedia"
        }

        return fullAddress
            .split(separator: ",")
            .prefix(2)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .joined(separator: ", ")
    }

    var ratingText: String? {
        guard let rating, !rating.isEmpty else { return nil }
        return rating
    }

    var latitudeValue: Double? {
        guard let latitude else { return nil }
        return Double(latitude)
    }

    var longitudeValue: Double? {
        guard let longitude else { return nil }
        return Double(longitude)
    }

    func openingHourRows(selectedDate: String?) -> [OpeningHoursRow] {
        let highlightedKey = selectedWeekdayKey(from: selectedDate)

        return [
            ("sunday", "Minggu"),
            ("monday", "Senin"),
            ("tuesday", "Selasa"),
            ("wednesday", "Rabu"),
            ("thursday", "Kamis"),
            ("friday", "Jumat"),
            ("saturday", "Sabtu")
        ].map { key, label in
            let windows = openingHours[key] ?? []
            let hours = windows.isEmpty ? "Tutup" : windows.map { $0.displayRange }.joined(separator: ", ")
            return OpeningHoursRow(
                key: key,
                label: label,
                hours: hours,
                isHighlighted: key == highlightedKey
            )
        }
    }

    func openStatusLine(selectedDate: String?) -> String {
        guard let highlightedKey = selectedWeekdayKey(from: selectedDate) else {
            return "Pilih hari perjalanan untuk melihat highlight."
        }

        let windows = openingHours[highlightedKey] ?? []
        return windows.isEmpty ? "Tutup" : "Buka"
    }

    private func selectedWeekdayKey(from dateString: String?) -> String? {
        guard let dateString else { return nil }

        let parser = DateFormatter()
        parser.locale = Locale(identifier: "en_US_POSIX")
        parser.dateFormat = "yyyy-MM-dd"

        guard let date = parser.date(from: dateString) else { return nil }

        let weekday = Calendar(identifier: .gregorian).component(.weekday, from: date)

        switch weekday {
        case 1: return "sunday"
        case 2: return "monday"
        case 3: return "tuesday"
        case 4: return "wednesday"
        case 5: return "thursday"
        case 6: return "friday"
        case 7: return "saturday"
        default: return nil
        }
    }
}

private extension AttractionDetailOpeningWindow {
    var displayRange: String {
        "\(open.replacingOccurrences(of: ":", with: ".")) - \(close.replacingOccurrences(of: ":", with: "."))"
    }
}
