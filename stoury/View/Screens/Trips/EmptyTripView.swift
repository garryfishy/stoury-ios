//
//  EmptyTripView.swift
//  stoury
//
//  Created by Muhammad Arfian Praniza on 12/03/26.
//

import SwiftUI

struct MyTripsView: View {
    @State private var selectedTab: AppTab = .trips

    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 20) {
                Text("Perjalanan Saya")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.black)
                    .padding(.top, 8)
                
                Spacer()

                TripCard(
                    title: "Siap menjelajah hari ini?",
                    subtitle: "Batam, Jogja, atau Bali?",
                    description: "Buat perjalananmu sendiri atau biarkan AI\nkami membantumu menjelajahi kota pilihan.",
                    primaryTitle: "Buat rencana dengan AI",
                    secondaryTitle: "Tentukan sendiri",
                    onPrimary: {},
                    onSecondary: {}
                )

                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)

            BottomNavbar(selectedTab: $selectedTab)
        }
        .background(Color.white)
    }
}

#Preview {
    MyTripsView()
}
