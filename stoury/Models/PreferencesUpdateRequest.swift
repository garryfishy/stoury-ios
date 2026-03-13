//
//  PreferencesUpdateRequest.swift
//  stoury
//
//  Created by Muhammad Arfian Praniza on 13/03/26.
//

import Foundation

struct PreferencesUpdateRequest: Encodable {
    let categoryIds: [UUID]
}
