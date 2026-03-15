//
//  AttractionDetail.swift
//  stoury
//
//  Created by Codex on 14/03/26.
//

import Foundation

struct AttractionDetailRoute: Identifiable, Hashable {
    let attractionId: UUID
    let selectedDate: String?

    var id: String {
        "\(attractionId.uuidString)-\(selectedDate ?? "none")"
    }
}

struct AttractionDetail: Decodable, Identifiable {
    let id: UUID
    let destinationId: UUID
    let name: String
    let slug: String
    let description: String?
    let fullAddress: String?
    let latitude: String?
    let longitude: String?
    let estimatedDurationMinutes: Int?
    let openingHours: [String: [AttractionDetailOpeningWindow]]
    let rating: String?
    let thumbnailImageUrl: URL?
    let mainImageUrl: URL?
    let enrichment: AttractionDetailEnrichment?
    let primaryPreference: AttractionPrimaryPreference?
    let destination: DashboardDestination?
    let categories: [AttractionCategorySummary]
    let shortLocation: String?
    let photos: [AttractionPhoto]

    private enum CodingKeys: String, CodingKey {
        case id
        case destinationId
        case name
        case slug
        case description
        case fullAddress
        case latitude
        case longitude
        case estimatedDurationMinutes
        case openingHours
        case rating
        case thumbnailImageUrl
        case mainImageUrl
        case enrichment
        case primaryPreference
        case destination
        case categories
        case shortLocation
        case photos
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        destinationId = try container.decode(UUID.self, forKey: .destinationId)
        name = try container.decode(String.self, forKey: .name)
        slug = try container.decode(String.self, forKey: .slug)
        description = try container.decodeIfPresent(String.self, forKey: .description)
        fullAddress = try container.decodeIfPresent(String.self, forKey: .fullAddress)
        latitude = try container.decodeIfPresent(String.self, forKey: .latitude)
        longitude = try container.decodeIfPresent(String.self, forKey: .longitude)
        estimatedDurationMinutes = try container.decodeIfPresent(Int.self, forKey: .estimatedDurationMinutes)
        openingHours = try container.decodeIfPresent([String: [AttractionDetailOpeningWindow]].self, forKey: .openingHours) ?? [:]
        rating = try container.decodeIfPresent(String.self, forKey: .rating)
        thumbnailImageUrl = try container.decodeIfPresent(URL.self, forKey: .thumbnailImageUrl)
        mainImageUrl = try container.decodeIfPresent(URL.self, forKey: .mainImageUrl)
        enrichment = try container.decodeIfPresent(AttractionDetailEnrichment.self, forKey: .enrichment)
        primaryPreference = try container.decodeIfPresent(AttractionPrimaryPreference.self, forKey: .primaryPreference)
        destination = try container.decodeIfPresent(DashboardDestination.self, forKey: .destination)
        categories = try container.decodeIfPresent([AttractionCategorySummary].self, forKey: .categories) ?? []
        shortLocation = try container.decodeIfPresent(String.self, forKey: .shortLocation)
        photos = try container.decodeIfPresent([AttractionPhoto].self, forKey: .photos) ?? []
    }
}

struct AttractionDetailOpeningWindow: Decodable, Hashable {
    let open: String
    let close: String

    init(from decoder: Decoder) throws {
        if let container = try? decoder.container(keyedBy: CodingKeys.self) {
            open = try container.decode(String.self, forKey: .open)
            close = try container.decode(String.self, forKey: .close)
            return
        }

        let singleValueContainer = try decoder.singleValueContainer()
        let rawValue = try singleValueContainer.decode(String.self)
        let parts = rawValue.split(separator: "-", maxSplits: 1).map {
            $0.trimmingCharacters(in: .whitespacesAndNewlines)
        }

        guard parts.count == 2 else {
            throw DecodingError.dataCorruptedError(
                in: singleValueContainer,
                debugDescription: "Expected opening hours in 'HH:mm-HH:mm' format."
            )
        }

        open = parts[0]
        close = parts[1]
    }

    private enum CodingKeys: String, CodingKey {
        case open
        case close
    }
}

struct AttractionDetailEnrichment: Decodable {
    let externalSource: String?
    let externalPlaceId: String?
    let externalRating: String?
    let externalReviewCount: Int?
    let externalLastSyncedAt: String?
}

struct AttractionPhoto: Decodable, Identifiable, Hashable {
    let url: URL
    let type: String

    var id: String {
        "\(type)-\(url.absoluteString)"
    }
}
