//
//  Dashboard.swift
//  stoury
//
//  Created by Garry Agassi on 11/03/26.
//

import Foundation

struct DashboardHome: Decodable {
    let destination: DashboardDestination
    let featured: [DashboardPlace]
    let exploreMore: [DashboardPlace]
    let meta: DashboardMeta
}

struct DashboardDestination: Decodable {
    let id: UUID
    let name: String
    let slug: String
    let isActive: Bool
    let description: String
    let destinationType: String
    let countryCode: String
    let countryName: String
    let provinceName: String
    let cityName: String
    let regionName: String?
    let heroImageUrl: URL?
}

struct DashboardPlace: Decodable, Identifiable {
    let id: UUID
    let slug: String
    let name: String
    let shortLocation: String
    let thumbnailImageUrl: URL?
    let rating: Double
    let badge: String
}

struct DashboardMeta: Decodable {
    let defaultDestinationSlug: String
    let featuredCount: Int
    let exploreMoreCount: Int
}
