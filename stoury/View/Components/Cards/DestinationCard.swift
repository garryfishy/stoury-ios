//
//  DestinationCard.swift
//  stoury
//
//  Created by Muhammad Arfian Praniza on 10/03/26.
//

import SwiftUI

struct DestinationCard: View {
    let badgeText: String
    let title: String
    let subtitle: String
    let rating: String
    let imageName: String
    let action: () -> Void

    init(
        badgeText: String,
        title: String,
        subtitle: String,
        rating: String,
        imageName: String,
        action: @escaping () -> Void = {}
    ) {
        self.badgeText = badgeText
        self.title = title
        self.subtitle = subtitle
        self.rating = rating
        self.imageName = imageName
        self.action = action
    }

    var body: some View {
        HStack(spacing: 16) {
            Image(imageName)
                .resizable()
                .scaledToFill()
                .frame(width: 120, height: 120)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

            VStack(alignment: .leading, spacing: 8) {
                Text(badgeText)
                    .font(.system(size: 12, weight: .semibold))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .clipShape(Capsule())

                Text(title)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.black)

                Text(subtitle)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(.gray)

                HStack(spacing: 6) {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                    Text(rating)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.black)
                }
            }

            Spacer()

//            Button(action: action) {
//                Image(systemName: "arrowshape.turn.up.right")
//                    .font(.system(size: 20, weight: .bold))
//                    .foregroundColor(.orange)
//                    .frame(width: 44, height: 44)
//                    .overlay(
//                        RoundedRectangle(cornerRadius: 12, style: .continuous)
//                            .stroke(Color.orange, lineWidth: 2)
//                    )
//            }
            .buttonStyle(.plain)
        }
        .padding(16)
        .background(Color(red: 0.99, green: 0.97, blue: 0.95))
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }
}
#Preview {
    DestinationCard(
        badgeText: "Populer",
        title: "Bandara Hang Nadim",
        subtitle: "Nongsa, Batam",
        rating: "4.4",
        imageName: "sample_destination"
    )
    .padding()
}
