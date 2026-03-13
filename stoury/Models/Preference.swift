//
//  Preference.swift
//  stoury
//
//  Created by Codex on 13/03/26.
//

import Foundation

struct Preference: Decodable, Identifiable {
    let id: UUID
    let name: String
    let slug: String
    let description: String
}
