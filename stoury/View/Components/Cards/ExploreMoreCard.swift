//
//  PopularCard.swift
//  stoury
//
//  Created by Garry Agassi on 11/03/26.
//

import SwiftUI

struct ExploreMoreCard: View {
    let imageURL: URL?
//    let labelText: String?
    let title: String?

    var body: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(Color.white)
            .frame(width: 215, height: 155)
            .overlay {
                if let imageURL {
                    AsyncImage(url: imageURL) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                                .frame(width: 175, height: 175)

                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(width: 200, height: 175)

                        case .failure:
                            Color.gray.opacity(0.2)

                        @unknown default:
                            Color.gray.opacity(0.2)
                        }
                    }
                } else {
                    Color.gray.opacity(0.2)
                }
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
//            .overlay(alignment: .topLeading) {
//                Text(labelText ?? "")
//                    .font(.system(size: 10, weight: .bold))
//                    .foregroundColor(.white)
//                    .padding(.horizontal, 12)
//                    .padding(.vertical, 6)
//                    .background(Color("PrimaryOrange"))
//                    .cornerRadius(6)
//                    .padding(10)
//            }
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}
