//
//  RegisterRequest.swift
//  stoury
//
//  Created by Muhammad Arfian Praniza on 13/03/26.
//

import Foundation

struct RegisterRequest: Codable {
    let name: String
    let email: String
    let password: String
}
