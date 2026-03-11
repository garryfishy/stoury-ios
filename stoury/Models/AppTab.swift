//
//  AppTab.swift
//  stoury
//
//  Created by Garry Agassi on 11/03/26.
//

import Foundation

enum AppTab: CaseIterable, Hashable {
    case dashboard
    case trips
    case forum
    case profile
    
    var title: String {
        switch self {
        case .dashboard: return "Jelajah"
        case .trips: return "Perjalanan"
        case .forum: return "Forum"
        case .profile: return "Profil"
        }
    }
    
    var iconAssetName: String {
            switch self {
            case .dashboard: return "ic-tab-jelajah"
            case .trips: return "ic-tab-perjalanan"
            case .forum: return "ic-tab-forum"
            case .profile: return "ic-tab-profil"
            }
        }
}
