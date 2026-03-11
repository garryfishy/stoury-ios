//
//  BottomNavItem.swift
//  stoury
//
//  Created by Garry Agassi on 11/03/26.
//

import SwiftUI

struct BottomNavItem: View {
    let tab: AppTab
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(tab.iconAssetName)
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)

                Text(tab.title)
                    .font(.system(size: 11, weight: .medium))
            }
            .foregroundStyle(isSelected ? .orange : .gray)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 6)
        }
        .buttonStyle(.plain)
    }
}
