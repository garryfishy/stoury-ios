//
//  ProfileCard.swift
//  stoury
//
//  Created by Muhammad Arfian Praniza on 12/03/26.
//

import SwiftUI

struct ProfileCard: View {
    let name: String
    let email: String
    let avatarImageName: String?

    init(
        name: String,
        email: String,
        avatarImageName: String? = nil
    ) {
        self.name = name
        self.email = email
        self.avatarImageName = avatarImageName
    }

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                    .frame(width: 130, height: 130)

                if let avatarImageName {
                    Image(avatarImageName)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 110, height: 110)
                        .clipShape(Circle())
                } else {
                    Image(systemName: "person")
                        .font(.system(size: 44, weight: .regular))
                        .foregroundColor(.black)
                }
            }

            Text(name)
                .font(.system(size: 22, weight: .semibold))
                .foregroundColor(.black)
                .padding(.top, 18)

            Text(email)
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(.gray)
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}

#Preview {
    ProfileCard(
        name: "Nolan Bergson",
        email: "nolanbergson@gmail.com"
    )
    .padding()
}
