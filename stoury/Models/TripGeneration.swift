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

struct GeneratedTripRoute: Identifiable, Hashable {
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
    let strategy: GeneratedItineraryStrategy?
    let budget: String
    let budgetFit: GeneratedItineraryBudgetFit?
    let budgetWarnings: [String]
    let isPartial: Bool
    let coverage: GeneratedItineraryCoverage?
    let warnings: [String]
    let days: [GeneratedItineraryDay]

    var id: UUID { tripId }

    private enum CodingKeys: String, CodingKey {
        case tripId
        case destinationId
        case planningMode
        case startDate
        case endDate
        case generatedAt
        case preferences
        case strategy
        case budget
        case budgetFit
        case budgetWarnings
        case isPartial
        case coverage
        case warnings
        case days
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        tripId = try container.decode(UUID.self, forKey: .tripId)
        destinationId = try container.decode(UUID.self, forKey: .destinationId)
        planningMode = try container.decode(String.self, forKey: .planningMode)
        startDate = try container.decode(String.self, forKey: .startDate)
        endDate = try container.decode(String.self, forKey: .endDate)
        generatedAt = try container.decode(String.self, forKey: .generatedAt)
        preferences = try container.decodeIfPresent([Preference].self, forKey: .preferences) ?? []
        strategy = try container.decodeIfPresent(GeneratedItineraryStrategy.self, forKey: .strategy)
        budget = try container.decode(String.self, forKey: .budget)
        budgetFit = try container.decodeIfPresent(GeneratedItineraryBudgetFit.self, forKey: .budgetFit)
        budgetWarnings = try container.decodeIfPresent([String].self, forKey: .budgetWarnings) ?? []
        isPartial = try container.decodeIfPresent(Bool.self, forKey: .isPartial) ?? false
        coverage = try container.decodeIfPresent(GeneratedItineraryCoverage.self, forKey: .coverage)
        warnings = try container.decodeIfPresent([String].self, forKey: .warnings) ?? []
        days = try container.decodeIfPresent([GeneratedItineraryDay].self, forKey: .days) ?? []
    }
}

struct GeneratedItineraryDay: Decodable, Identifiable {
    let dayNumber: Int
    let date: String
    let notes: String?
    let isPartial: Bool
    let items: [GeneratedItineraryItem]

    var id: Int { dayNumber }

    private enum CodingKeys: String, CodingKey {
        case dayNumber
        case date
        case notes
        case isPartial
        case items
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        dayNumber = try container.decode(Int.self, forKey: .dayNumber)
        date = try container.decode(String.self, forKey: .date)
        notes = try container.decodeIfPresent(String.self, forKey: .notes)
        isPartial = try container.decodeIfPresent(Bool.self, forKey: .isPartial) ?? false
        items = try container.decodeIfPresent([GeneratedItineraryItem].self, forKey: .items) ?? []
    }
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

    private enum CodingKeys: String, CodingKey {
        case attractionId
        case attractionName
        case startTime
        case endTime
        case orderIndex
        case notes
        case estimatedBudgetMin
        case estimatedBudgetMax
        case estimatedBudgetNote
        case source
        case attraction
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        attractionId = try container.decode(UUID.self, forKey: .attractionId)
        attractionName = try container.decode(String.self, forKey: .attractionName)
        startTime = try container.decode(String.self, forKey: .startTime)
        endTime = try container.decode(String.self, forKey: .endTime)
        orderIndex = try container.decode(Int.self, forKey: .orderIndex)
        notes = try container.decodeIfPresent(String.self, forKey: .notes)
        estimatedBudgetMin = try container.decodeIfPresent(Int.self, forKey: .estimatedBudgetMin)
        estimatedBudgetMax = try container.decodeIfPresent(Int.self, forKey: .estimatedBudgetMax)
        estimatedBudgetNote = try container.decodeIfPresent(String.self, forKey: .estimatedBudgetNote)
        source = try container.decodeIfPresent(String.self, forKey: .source)
        attraction = try container.decodeIfPresent(AttractionSummary.self, forKey: .attraction)
    }
}

struct GeneratedItineraryStrategy: Decodable {
    let mode: String?
    let provider: String?
    let usedProviderRanking: Bool?
    let reasoning: String?
}

struct GeneratedItineraryBudgetFit: Decodable {
    let level: String?
    let perDayBudget: Double?
    let isApproximate: Bool?
    let reasoning: String?
}

struct GeneratedItineraryCoverage: Decodable {
    let requestedDayCount: Int?
    let generatedDayCount: Int?
    let availableAttractionCount: Int?
    let requestedItemSlots: Int?
    let scheduledItemCount: Int?
    let maxItemsPerDay: Int?
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
