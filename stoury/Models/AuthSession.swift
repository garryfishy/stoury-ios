//
//  Auth.swift
//  stoury
//
//  Created by Garry Agassi on 11/03/26.
//
import Foundation

struct AuthSession: Codable {
    let accessToken: String
    let refreshToken: String
    let user: User
}
