//
//  ItineraryCard.swift
//  stoury
//
//  Created by Muhammad Arfian Praniza on 10/03/26.
//

import SwiftUI

struct ItineraryCard: View {
    let title: String
    let time: String
    let detail: String
    let tag: String?

    init(
        title: String,
        time: String,
        detail: String,
        tag: String? = nil
    ) {
        self.title = title
        self.time = time
        self.detail = detail
        self.tag = tag
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .firstTextBaseline) {
                Text(title)
                    .font(.headline)
                Spacer()
                Text(time)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            Text(detail)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(2)

            if let tag {
                Text(tag)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.accentColor.opacity(0.15))
                    .foregroundColor(.accentColor)
                    .clipShape(Capsule())
            }
        }
        .padding(14)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 3)
    }
}

#Preview {
    ItineraryCard(
        title: "Arashiyama Bamboo Grove",
        time: "08:30 - 10:00",
        detail: "Morning walk and photography along the main path.",
        tag: "Day 1"
    )
    .padding()
}
