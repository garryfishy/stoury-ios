//
//  PopularCard.swift
//  stoury
//
//  Created by Garry Agassi on 11/03/26.
//

import SwiftUI

struct PopularCard: View {
    let imageURL: URL?
    let labelText: String?
    let title: String?
    let subtitle: String?

    private var hasBadge: Bool {
        guard let labelText else { return false }
        return !labelText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

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
        RoundedRectangle(cornerRadius: 8)
            .fill(Color.white)
            .frame(maxWidth: .infinity)
            .frame(height: 175)
            .overlay {
                RemoteImageView(url: imageURL, contentMode: .fill) {
                    placeholderImage
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .overlay(alignment: .bottom) {
                Rectangle()
                    .fill(Color.black.opacity(0.8))
                    .frame(height: 50)
            }
            .overlay(alignment: .bottomLeading) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title ?? "")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                        .lineLimit(1)

                    Text(subtitle ?? "")
                        .font(.system(size: 10, weight: .regular))
                        .foregroundColor(.white.opacity(0.9))
                        .lineLimit(1)
                }
                .padding(.horizontal, 10)
                .padding(.top, 4)
                .padding(.bottom, 8)
            }
            .overlay(alignment: .topLeading) {
                if hasBadge {
                    Text(labelText ?? "")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color("PrimaryOrange"))
                        .cornerRadius(6)
                        .padding(10)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}
