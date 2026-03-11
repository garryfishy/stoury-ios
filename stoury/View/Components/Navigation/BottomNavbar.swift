//
//  BottomNavbar.swift
//  stoury
//
//  Created by Garry Agassi on 11/03/26.
//

import SwiftUI

struct BottomNavbar: View {
    @Binding var selectedTab: AppTab
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(AppTab.allCases, id: \.self) { tab in
                BottomNavItem(
                    tab: tab,
                    isSelected: selectedTab == tab
                ) {
                    selectedTab = tab
                }
            }
        }
        .padding(.horizontal, 8)
        .padding(.top, 6)
        .padding(.bottom, 8)
        .background(.white)
        .overlay(alignment: .top) {
            Divider()
        }

    }
}
