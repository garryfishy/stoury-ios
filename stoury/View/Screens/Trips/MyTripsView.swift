//
//  MyTripsView.swift
//  stoury
//
//  Created by Muhammad Arfian Praniza on 10/03/26.
//

import SwiftUI

struct MyTripsView: View {
    @StateObject private var viewModel: MyTripViewModel
    private let sessionStore: SessionStore
    @State private var showGenerateAI = false

    init(sessionStore: SessionStore) {
        self.sessionStore = sessionStore
        _viewModel = StateObject(
            wrappedValue: MyTripViewModel(sessionStore: sessionStore)
        )
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if viewModel.isLoading {
                VStack {
                    Spacer()
                    ProgressView("Memuat perjalanan...")
                        .frame(maxWidth: .infinity)
                    Spacer()
                }
            } else if let errorMessage = viewModel.errorMessage {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Perjalanan Saya")
                        .font(.system(size: 28, weight: .bold))

                    Text(errorMessage)
                        .foregroundStyle(.red)

                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .background(.white)
            } else if viewModel.trips.isEmpty {
                EmptyTripView(
                    onGenerateAI: { showGenerateAI = true },
                    onManual: {}
                )
            } else {
                VStack(alignment: .leading, spacing: 12) {
                    HStack(alignment: .center) {
                        Text("Perjalanan Saya")
                            .font(.system(size: 28, weight: .bold))

                        Spacer()

                        Button {
                            showGenerateAI = true
                        } label: {
                            Image(systemName: "plus")
                                .font(.system(size: 22, weight: .bold))
                                .foregroundStyle(.white)
                                .frame(width: 50, height: 50)
                                .background(Color("PrimaryOrange"))
                                .clipShape(Circle())
                        }
                        .buttonStyle(.plain)
                    }

                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .background(.white)
            }
        }
        .task {
            await viewModel.getTrips()
        }
        .fullScreenCover(isPresented: $showGenerateAI) {
            GenerateWithAIView(sessionStore: sessionStore)
        }
    }
}

#Preview {
    MyTripsView(sessionStore: SessionStore())
}
