//
//  TripGeneration.swift
//  stoury
//
//  Created by Codex on 13/03/26.
//

import Foundation

struct DestinationOption: Identifiable, Hashable {
    let id: UUID
    let name: String
    let description: String
    let countryName: String
    let cityName: String?
    let regionName: String?
    let heroImageUrl: URL?

    var locationLine: String {
        let primaryLocation = cityName ?? regionName ?? name
        return "\(primaryLocation), \(countryName)"
    }
}

struct CreateTripRequest: Encodable {
    let title: String
    let destinationId: UUID
    let planningMode: String
    let startDate: String
    let endDate: String
    let budget: Int
    let preferenceSource: String
    let preferenceCategoryIds: [UUID]
}

struct CreatedTrip: Decodable, Identifiable {
    let id: UUID
}

struct GeneratedTripRoute: Identifiable {
    let tripId: UUID
    let tripTitle: String
    let destination: DestinationOption
    let startDate: String
    let endDate: String

    var id: UUID { tripId }
}

struct GeneratedItineraryPreview: Decodable, Identifiable {
    let tripId: UUID
    let destinationId: UUID
    let planningMode: String
    let startDate: String
    let endDate: String
    let generatedAt: String
    let preferences: [Preference]
    let budget: String
    let isPartial: Bool
    let warnings: [String]
    let days: [GeneratedItineraryDay]

    var id: UUID { tripId }
}

struct GeneratedItineraryDay: Decodable, Identifiable {
    let dayNumber: Int
    let date: String
    let notes: String?
    let isPartial: Bool
    let items: [GeneratedItineraryItem]

    var id: Int { dayNumber }
}

struct GeneratedItineraryItem: Decodable, Identifiable {
    let attractionId: UUID
    let attractionName: String
    let startTime: String
    let endTime: String
    let orderIndex: Int
    let notes: String?
    let estimatedBudgetMin: Int?
    let estimatedBudgetMax: Int?
    let estimatedBudgetNote: String?
    let source: String?
    let attraction: AttractionSummary?

    var id: String {
        "\(attractionId.uuidString)-\(orderIndex)-\(startTime)"
    }
}

struct SaveItineraryRequest: Encodable {
    let days: [SaveItineraryDay]
}

struct SaveItineraryDay: Encodable {
    let dayNumber: Int
    let date: String
    let notes: String?
    let items: [SaveItineraryItem]
}

struct SaveItineraryItem: Encodable {
    let attractionId: String
    let startTime: String
    let endTime: String
    let orderIndex: Int
    let notes: String?
    let estimatedBudgetMin: Int?
    let estimatedBudgetMax: Int?
    let estimatedBudgetNote: String?
}

extension GeneratedItineraryPreview {
    var savePayload: SaveItineraryRequest {
        SaveItineraryRequest(
            days: days.map { day in
                SaveItineraryDay(
                    dayNumber: day.dayNumber,
                    date: day.date,
                    notes: day.notes,
                    items: day.items.map { item in
                        SaveItineraryItem(
                            attractionId: item.attractionId.uuidString.lowercased(),
                            startTime: item.startTime,
                            endTime: item.endTime,
                            orderIndex: item.orderIndex,
                            notes: item.notes,
                            estimatedBudgetMin: item.estimatedBudgetMin,
                            estimatedBudgetMax: item.estimatedBudgetMax,
                            estimatedBudgetNote: item.estimatedBudgetNote
                        )
                    }
                )
            }
        )
    }
}
