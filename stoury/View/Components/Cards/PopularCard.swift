//
//  PopularCard.swift
//  stoury
//
//  Created by Garry Agassi on 11/03/26.
//

import SwiftUI

struct PopularCard: View {
    let imageURL: String?
    let labelText: String?

    var body: some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.white)
                .frame(width: 175, height: 175)
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                .overlay {
                    if let imageURL, !imageURL.isEmpty {
                        AsyncImage(url: URL(string: imageURL)) { phase in
                            switch phase {
                            case .empty:
                                ProgressView()
                                    .frame(width: 175, height: 175)

                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 175, height: 175)
                                    .clipped()
                                    .cornerRadius(8)

                            case .failure:
                                Color.clear
                                    .frame(width: 175, height: 175)

                            @unknown default:
                                Color.clear
                                    .frame(width: 175, height: 175)
                            }
                        }
                    }
                }

            Text(labelText ?? "")
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.orange)
                .cornerRadius(6)
                .padding(10)
        }
    }
}
