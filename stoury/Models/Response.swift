//
//  Response.swift
//  stoury
//
//  Created by Garry Agassi on 11/03/26.
//

import Foundation

struct APIResponse<T: Decodable>: Decodable {
    let success: Bool
    let message: String
    let data: T
}
