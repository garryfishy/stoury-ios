//
//  User.swift
//  stoury
//
//  Created by Muhammad Arfian Praniza on 10/03/26.
//

import Foundation

struct User: Decodable {
    let id: UUID
    let name: String
    let email: String
    let roles: [String]
}
