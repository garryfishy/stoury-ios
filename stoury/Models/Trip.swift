//
//  Trip.swift
//  stoury
//
//  Created by Muhammad Arfian Praniza on 10/03/26.
//

import Foundation

struct Trip: Decodable, Identifiable {
    let id: UUID
    let title: String
    let userId: UUID
    let destinationId: UUID
    let planningMode: String
    let startDate: String
    let endDate: String
    let durationDays: Int
    let budget: String
    let destination: DashboardDestination
    let preferences: [Preference]?
    let hasItinerary: Bool
}
