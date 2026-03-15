//
//  Itinerary.swift
//  stoury
//
//  Created by Muhammad Arfian Praniza on 10/03/26.
//

import Foundation

struct TripItinerary: Decodable {
    let itineraryId: UUID
    let tripId: UUID
    let destinationId: UUID
    let planningMode: String
    let startDate: String
    let endDate: String
    let hasItinerary: Bool
    let days: [TripItineraryDay]

    private enum CodingKeys: String, CodingKey {
        case itineraryId
        case tripId
        case destinationId
        case planningMode
        case startDate
        case endDate
        case hasItinerary
        case days
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        itineraryId = try container.decode(UUID.self, forKey: .itineraryId)
        tripId = try container.decode(UUID.self, forKey: .tripId)
        destinationId = try container.decode(UUID.self, forKey: .destinationId)
        planningMode = try container.decode(String.self, forKey: .planningMode)
        startDate = try container.decode(String.self, forKey: .startDate)
        endDate = try container.decode(String.self, forKey: .endDate)
        hasItinerary = try container.decodeIfPresent(Bool.self, forKey: .hasItinerary) ?? false
        days = try container.decodeIfPresent([TripItineraryDay].self, forKey: .days) ?? []
    }
}

struct TripItineraryDay: Decodable, Identifiable {
    let id: UUID
    let dayNumber: Int
    let date: String
    let notes: String?
    let items: [TripItineraryItem]

    private enum CodingKeys: String, CodingKey {
        case id
        case dayNumber
        case date
        case notes
        case items
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        dayNumber = try container.decode(Int.self, forKey: .dayNumber)
        date = try container.decode(String.self, forKey: .date)
        notes = try container.decodeIfPresent(String.self, forKey: .notes)
        items = try container.decodeIfPresent([TripItineraryItem].self, forKey: .items) ?? []
    }
}

struct TripItineraryItem: Decodable, Identifiable {
    let id: UUID
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

    private enum CodingKeys: String, CodingKey {
        case id
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
        id = try container.decode(UUID.self, forKey: .id)
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

struct AttractionSummary: Decodable, Identifiable {
    let id: UUID
    let destinationId: UUID
    let name: String
    let slug: String
    let fullAddress: String?
    let latitude: String?
    let longitude: String?
    let estimatedDurationMinutes: Int?
    let openingHours: [String: [TripDayOpeningHours]]?
    let tripDayOpeningHours: [TripDayOpeningHours]?
    let tripDayIsOpen: Bool?
    let rating: String?
    let thumbnailImageUrl: URL?
    let mainImageUrl: URL?
    let primaryPreference: AttractionPrimaryPreference?
    let categories: [AttractionCategorySummary]

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

    private enum CodingKeys: String, CodingKey {
        case id
        case destinationId
        case name
        case slug
        case fullAddress
        case latitude
        case longitude
        case estimatedDurationMinutes
        case openingHours
        case tripDayOpeningHours
        case tripDayIsOpen
        case rating
        case thumbnailImageUrl
        case mainImageUrl
        case primaryPreference
        case categories
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        destinationId = try container.decode(UUID.self, forKey: .destinationId)
        name = try container.decode(String.self, forKey: .name)
        slug = try container.decode(String.self, forKey: .slug)
        fullAddress = try container.decodeIfPresent(String.self, forKey: .fullAddress)
        latitude = try container.decodeIfPresent(String.self, forKey: .latitude)
        longitude = try container.decodeIfPresent(String.self, forKey: .longitude)
        estimatedDurationMinutes = try container.decodeIfPresent(Int.self, forKey: .estimatedDurationMinutes)
        openingHours = try container.decodeIfPresent([String: [TripDayOpeningHours]].self, forKey: .openingHours)
        tripDayOpeningHours = try container.decodeIfPresent([TripDayOpeningHours].self, forKey: .tripDayOpeningHours)
        tripDayIsOpen = try container.decodeIfPresent(Bool.self, forKey: .tripDayIsOpen)
        rating = try container.decodeIfPresent(String.self, forKey: .rating)
        thumbnailImageUrl = try container.decodeIfPresent(URL.self, forKey: .thumbnailImageUrl)
        mainImageUrl = try container.decodeIfPresent(URL.self, forKey: .mainImageUrl)
        primaryPreference = try container.decodeIfPresent(AttractionPrimaryPreference.self, forKey: .primaryPreference)
        categories = try container.decodeIfPresent([AttractionCategorySummary].self, forKey: .categories) ?? []
    }
}

struct TripDayOpeningHours: Decodable, Hashable {
    let open: String
    let close: String
}

struct AttractionPrimaryPreference: Decodable, Hashable {
    let slug: String
    let name: String
}

struct AttractionCategorySummary: Decodable, Identifiable {
    let id: UUID
    let name: String
    let slug: String
}
