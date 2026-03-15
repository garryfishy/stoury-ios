//
//  PopularCard.swift
//  stoury
//
//  Created by Garry Agassi on 11/03/26.
//

import SwiftUI

struct ExploreMoreCard: View {
    let imageURL: URL?
    let title: String?

    private var placeholderImage: some View {
        LinearGradient(
            colors: [
                Color.gray.opacity(0.16),
                Color.gray.opacity(0.08)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .overlay {
            Image(systemName: "photo")
                .font(.system(size: 24, weight: .medium))
                .foregroundStyle(.gray.opacity(0.55))
        }
    }

    var body: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(Color.white)
            .frame(width: 215, height: 155)
            .overlay {
                RemoteImageView(url: imageURL, contentMode: .fill) {
                    placeholderImage
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .clipped()
            }
            .overlay(alignment: .bottom) {
                Rectangle()
                    .fill(Color.black.opacity(0.8))
                    .frame(height: 35)
            }
            .overlay(alignment: .bottomLeading) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title ?? "")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                        .lineLimit(1)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
            }
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}
