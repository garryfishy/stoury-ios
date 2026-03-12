//
//  DropdownField.swift
//  stoury
//
//  Created by Garry Agassi on 12/03/26.
//

import SwiftUI

import SwiftUI

struct DropdownField: View {
    let title: String
    let placeholder: String
    let options: [String]
    @Binding var selectedValue: String?
    var leadingSystemImage: String? = nil

    @State private var isExpanded = false

    private let fieldHeight: CGFloat = 52

    private var displayText: String {
        if let selectedValue, !selectedValue.isEmpty {
            return selectedValue
        }
        return placeholder
    }

    private var isPlaceholder: Bool {
        selectedValue?.isEmpty ?? true
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)

            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isExpanded.toggle()
                }
            } label: {
                HStack {
                    if let leadingSystemImage {
                        Image(systemName: leadingSystemImage)
                            .foregroundColor(.gray)
                    }

                    Text(displayText)
                        .foregroundColor(isPlaceholder ? .gray : .primary)

                    Spacer()

                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(.gray)
                }
                .padding(.horizontal, 16)
                .frame(height: fieldHeight)
                .background(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
            }
            .buttonStyle(.plain)
            .overlay(alignment: .topLeading) {
                if isExpanded {
                    VStack(spacing: 0) {
                        ForEach(options, id: \.self) { option in
                            Button {
                                selectedValue = option
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    isExpanded = false
                                }
                            } label: {
                                HStack {
                                    Text(option)
                                        .foregroundColor(.primary)
                                    Spacer()
                                }
                                .padding(.horizontal, 16)
                                .frame(height: fieldHeight)
                                .background(Color.white)
                            }
                            .buttonStyle(.plain)

                            if option != options.last {
                                Divider()
                            }
                        }
                    }
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
                    .offset(y: fieldHeight + 8)
                    .zIndex(9999)
                }
            }
            .zIndex(9999)
        }
    }
}
