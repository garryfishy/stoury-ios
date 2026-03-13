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
}

struct TripItineraryDay: Decodable, Identifiable {
    let id: UUID
    let dayNumber: Int
    let date: String
    let notes: String?
    let items: [TripItineraryItem]
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
    let source: String
    let attraction: AttractionSummary?
}

struct AttractionSummary: Decodable, Identifiable {
    let id: UUID
    let destinationId: UUID
    let name: String
    let slug: String
    let fullAddress: String
    let latitude: String
    let longitude: String
    let estimatedDurationMinutes: Int
    let rating: String?
    let thumbnailImageUrl: URL?
    let mainImageUrl: URL?
    let categories: [AttractionCategorySummary]

    var locationLine: String {
        fullAddress
            .split(separator: ",")
            .prefix(2)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .joined(separator: ", ")
    }
}

struct AttractionCategorySummary: Decodable, Identifiable {
    let id: UUID
    let name: String
    let slug: String
}
