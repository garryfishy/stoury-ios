//
//  AppTab.swift
//  stoury
//
//  Created by Garry Agassi on 11/03/26.
//

import Foundation

enum AppTab: CaseIterable, Hashable {
    case trips
    case dashboard
    case forum
    case profile
    
    var title: String {
        switch self {
        case .trips: return "Perjalanan"
        case .dashboard: return "Jelajah"
        case .forum: return "Forum"
        case .profile: return "Profil"
        }
    }
    
    var iconAssetName: String {
            switch self {
            case .trips: return "ic-tab-perjalanan"
            case .dashboard: return "ic-tab-jelajah"
            case .forum: return "ic-tab-forum"
            case .profile: return "ic-tab-profil"
            }
        }
}
