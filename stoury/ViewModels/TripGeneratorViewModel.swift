//
//  TripGeneratorViewModel.swift
//  stoury
//
//  Created by Muhammad Arfian Praniza on 10/03/26.
//

import Foundation
import Combine

@MainActor
final class TripGeneratorViewModel: ObservableObject {
    @Published private(set) var destinationOptions: [DestinationOption]
    @Published private(set) var masterPreferences: [Preference] = []
    @Published private(set) var accountPreferences: [Preference] = []
    @Published var isLoadingInitialData = false
    @Published var isGenerating = false
    @Published var errorMessage: String?
    @Published var preferenceErrorMessage: String?

    private let apiService: APIService
    private let dateFormatter: DateFormatter

    init(sessionStore: SessionStore, apiService: APIService? = nil) {
        self.apiService = apiService ?? APIService(sessionStore: sessionStore)
        self.destinationOptions = []

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"
        self.dateFormatter = formatter
    }

    var destinationNames: [String] {
        destinationOptions.map(\.name)
    }

    var defaultDestinationName: String? {
        destinationOptions.first?.name
    }

    func loadInitialData() async {
        guard !isLoadingInitialData else { return }

        isLoadingInitialData = true
        preferenceErrorMessage = nil
        defer { isLoadingInitialData = false }

        do {
            let destinations = try await apiService.getDestinations(page: 1, limit: 100)
            destinationOptions = destinations.map { destination in
                DestinationOption(
                    id: destination.id,
                    name: destination.name,
                    description: destination.description,
                    countryName: destination.countryName,
                    cityName: destination.cityName,
                    regionName: destination.regionName,
                    heroImageUrl: destination.heroImageUrl
                )
            }
        } catch {
            destinationOptions = []
            errorMessage = "Gagal memuat daftar lokasi."
            print("TripGeneratorViewModel.loadInitialData failed to load destinations:", error)
        }

        do {
            masterPreferences = try await apiService.getPreferences()
        } catch {
            masterPreferences = []
            preferenceErrorMessage = "Gagal memuat daftar preferensi."
            print("TripGeneratorViewModel.loadInitialData failed to load master preferences:", error)
        }

        do {
            accountPreferences = try await apiService.getMyPreferences()
        } catch {
            accountPreferences = []
            if preferenceErrorMessage == nil {
                preferenceErrorMessage = "Gagal memuat preferensi akun."
            }
            print("TripGeneratorViewModel.loadInitialData failed to load account preferences:", error)
        }
    }

    func matchedAccountPreferenceIDs() -> Set<UUID> {
        let accountNames = Set(accountPreferences.map(\.normalizedName))

        let matchedIDs = masterPreferences.compactMap { preference -> UUID? in
            accountNames.contains(preference.normalizedName) ? preference.id : nil
        }

        return Set(matchedIDs)
    }

    func generateTrip(
        title: String,
        destinationName: String?,
        startDate: Date?,
        endDate: Date?,
        budget: String,
        useAccountPreferences: Bool,
        selectedPreferenceIDs: Set<UUID>
    ) async -> GeneratedTripRoute? {
        errorMessage = nil
        print("TripGeneratorViewModel.generateTrip started")

        guard let destinationName,
              let destination = destinationOptions.first(where: {
                  $0.name.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() ==
                  destinationName.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
              }) else {
            errorMessage = "Lokasi yang dipilih belum tersedia."
            print("Generate trip validation failed: destination not found for name:", destinationName ?? "nil")
            return nil
        }

        guard let startDate, let endDate else {
            errorMessage = "Tanggal perjalanan belum lengkap."
            print("Generate trip validation failed: missing start/end date")
            return nil
        }

        guard let numericBudget = Int(budget.filter(\.isNumber)), numericBudget > 0 else {
            errorMessage = "Budget harus berupa angka."
            print("Generate trip validation failed: invalid budget input:", budget)
            return nil
        }

        isGenerating = true
        defer { isGenerating = false }

        let body = CreateTripRequest(
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            destinationId: destination.id,
            planningMode: "ai_assisted",
            startDate: dateFormatter.string(from: startDate),
            endDate: dateFormatter.string(from: endDate),
            budget: numericBudget,
            preferenceSource: useAccountPreferences ? "account" : "custom",
            preferenceCategoryIds: Array(selectedPreferenceIDs)
        )

        do {
            let createdTrip = try await apiService.createTrip(body)
            print("Trip created successfully with id:", createdTrip.id.uuidString)
            let preview = try await apiService.generateAITripPreview(tripId: createdTrip.id)
            print("AI itinerary preview generated successfully for trip:", preview.tripId.uuidString)
            try await apiService.saveTripItinerary(
                tripId: preview.tripId,
                body: preview.savePayload
            )
            print("AI itinerary saved successfully for trip:", preview.tripId.uuidString)
            return GeneratedTripRoute(
                tripId: preview.tripId,
                tripTitle: body.title,
                destination: destination,
                startDate: body.startDate,
                endDate: body.endDate
            )
        } catch {
            errorMessage = error.localizedDescription
            print("Generate trip flow failed:", error)
            return nil
        }
    }
}

private extension Preference {
    var normalizedName: String {
        name.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }
}
