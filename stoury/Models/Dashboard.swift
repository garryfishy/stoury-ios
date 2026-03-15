//
//  Dashboard.swift
//  stoury
//
//  Created by Garry Agassi on 11/03/26.
//

import Foundation

struct DashboardHome: Decodable {
    let featured: [DashboardFeaturedItem]
    let meta: DashboardMeta

    private enum CodingKeys: String, CodingKey {
        case featured
        case meta
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        featured = try container.decodeIfPresent([DashboardFeaturedItem].self, forKey: .featured) ?? []
        meta = try container.decodeIfPresent(DashboardMeta.self, forKey: .meta) ?? DashboardMeta()
    }
}

struct DashboardSearchPayload: Decodable {
    let query: String
    let items: [DashboardFeaturedItem]

    private enum CodingKeys: String, CodingKey {
        case query
        case items
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        query = try container.decodeIfPresent(String.self, forKey: .query) ?? ""
        items = try container.decodeIfPresent([DashboardFeaturedItem].self, forKey: .items) ?? []
    }
}

struct DashboardDestination: Decodable, Identifiable, Hashable {
    let id: UUID
    let name: String
    let slug: String
    let isActive: Bool
    let description: String
    let destinationType: String
    let countryCode: String
    let countryName: String
    let provinceName: String
    let cityName: String?
    let regionName: String?
    let heroImageUrl: URL?
}

struct DashboardFeaturedItem: Decodable, Identifiable {
    let id: UUID
    let slug: String
    let name: String
    let shortLocation: String
    let thumbnailImageUrl: URL?
    let rating: Double
    let badge: String?
    let badgeKey: String?
    let destination: DashboardFeaturedDestination?

    private enum CodingKeys: String, CodingKey {
        case id
        case slug
        case name
        case shortLocation
        case thumbnailImageUrl
        case rating
        case badge
        case badgeKey
        case destination
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        slug = try container.decode(String.self, forKey: .slug)
        name = try container.decode(String.self, forKey: .name)
        shortLocation = try container.decode(String.self, forKey: .shortLocation)
        thumbnailImageUrl = try container.decodeIfPresent(URL.self, forKey: .thumbnailImageUrl)
        badge = try container.decodeIfPresent(String.self, forKey: .badge)
        badgeKey = try container.decodeIfPresent(String.self, forKey: .badgeKey)
        destination = try container.decodeIfPresent(DashboardFeaturedDestination.self, forKey: .destination)

        if let rating = try? container.decode(Double.self, forKey: .rating) {
            self.rating = rating
        } else if let ratingString = try? container.decode(String.self, forKey: .rating),
                  let rating = Double(ratingString) {
            self.rating = rating
        } else {
            rating = 0
        }
    }
}

struct DashboardFeaturedDestination: Decodable, Identifiable, Hashable {
    let id: UUID
    let slug: String
    let name: String
}

struct DashboardMeta: Decodable {
    let featuredCount: Int
    let candidatePoolSize: Int
    let totalActiveAttractionCount: Int

    init(
        featuredCount: Int = 0,
        candidatePoolSize: Int = 0,
        totalActiveAttractionCount: Int = 0
    ) {
        self.featuredCount = featuredCount
        self.candidatePoolSize = candidatePoolSize
        self.totalActiveAttractionCount = totalActiveAttractionCount
    }
}

struct DestinationAttractionsPayload: Decodable {
    let destination: DashboardDestination?
    let items: [DestinationAttractionItem]

    private enum CodingKeys: String, CodingKey {
        case destination
        case items
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        destination = try container.decodeIfPresent(DashboardDestination.self, forKey: .destination)
        items = try container.decodeIfPresent([DestinationAttractionItem].self, forKey: .items) ?? []
    }
}

struct DestinationAttractionItem: Decodable, Identifiable {
    let id: UUID
    let destinationId: UUID
    let name: String
    let slug: String
    let shortLocation: String?
    let fullAddress: String?
    let rating: String?
    let thumbnailImageUrl: URL?
    let mainImageUrl: URL?
    let primaryPreference: AttractionPrimaryPreference?

    var displayLocation: String {
        if let shortLocation, !shortLocation.isEmpty {
            return shortLocation
        }

        guard let fullAddress, !fullAddress.isEmpty else {
            return ""
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
        case shortLocation
        case fullAddress
        case rating
        case thumbnailImageUrl
        case mainImageUrl
        case primaryPreference
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        destinationId = try container.decode(UUID.self, forKey: .destinationId)
        name = try container.decode(String.self, forKey: .name)
        slug = try container.decode(String.self, forKey: .slug)
        shortLocation = try container.decodeIfPresent(String.self, forKey: .shortLocation)
        fullAddress = try container.decodeIfPresent(String.self, forKey: .fullAddress)
        thumbnailImageUrl = try container.decodeIfPresent(URL.self, forKey: .thumbnailImageUrl)
        mainImageUrl = try container.decodeIfPresent(URL.self, forKey: .mainImageUrl)
        primaryPreference = try container.decodeIfPresent(AttractionPrimaryPreference.self, forKey: .primaryPreference)

        if let rating = try? container.decode(String.self, forKey: .rating) {
            self.rating = rating
        } else if let rating = try? container.decode(Double.self, forKey: .rating) {
            self.rating = String(format: "%.1f", rating)
        } else {
            self.rating = nil
        }
    }
}
