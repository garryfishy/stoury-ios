//
//  LogoutRequest.swift
//  stoury
//
//  Created by Muhammad Arfian Praniza on 13/03/26.
//

import Foundation

struct LogoutRequest: Encodable {
    let refreshToken: String
}
