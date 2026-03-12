//
//  Atrraction.swift
//  stoury
//
//  Created by Garry Agassi on 12/03/26.
//

import Foundation

struct AttractionsResponse: Decodable {
    let success: Bool
    let message: String
    let data: AttractionsData
    let meta: PaginationMeta
}

struct AttractionsData: Decodable {
    let destination: DashboardDestination
    let items: [Attraction]
}

struct Attraction: Decodable, Identifiable {
    let id: UUID
    let destinationId: UUID
    let name: String
    let slug: String
    let description: String
    let fullAddress: String
    let latitude: String
    let longitude: String
    let estimatedDurationMinutes: Int
    let openingHours: [String: [String]]
    let rating: String
    let thumbnailImageUrl: URL?
    let mainImageUrl: URL?
    let enrichment: AttractionEnrichment
    let destination: DashboardDestination
    let categories: [AttractionCategory]
}

struct AttractionEnrichment: Decodable {
    let externalSource: String?
    let externalPlaceId: String?
    let externalRating: String?
    let externalReviewCount: Int?
    let externalLastSyncedAt: String?
}

struct AttractionCategory: Decodable, Identifiable {
    let id: UUID
    let name: String
    let slug: String
}

struct PaginationMeta: Decodable {
    let page: Int
    let limit: Int
    let total: Int
    let totalPages: Int
}
