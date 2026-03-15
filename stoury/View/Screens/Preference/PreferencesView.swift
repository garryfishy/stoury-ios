//
//  PreferencesView.swift
//  stoury
//
//  Created by Muhammad Arfian Praniza on 12/03/26.
//

import SwiftUI

struct PreferencesView: View {
    @EnvironmentObject private var sessionStore: SessionStore
    @Binding var isPresented: Bool
    @StateObject private var viewModel: PreferencesViewModel

    init(
        isPresented: Binding<Bool> = .constant(true),
        sessionStore: SessionStore? = nil,
        viewModel: PreferencesViewModel? = nil
    ) {
        self._isPresented = isPresented
        _viewModel = StateObject(
            wrappedValue: viewModel ?? PreferencesViewModel(sessionStore: sessionStore)
        )
    }

    private var primaryOrange: Color {
        Color("PrimaryOrange")
    }

    var body: some View {
        NavigationStack {
            ZStack {
                primaryOrange
                    .ignoresSafeArea()

                VStack(spacing: 20) {
                    Text("Apa preferensi liburanmu?")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)

                    if viewModel.isLoading {
                        LoadingView()
                    } else {
                        PreferencesCard(
                            items: viewModel.items,
                            selectedIDs: $viewModel.selectedIDs
                        )
                    }

                    if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .font(.system(size: 12, weight: .regular))
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    Button {
                        Task {
                            let isSaved = await viewModel.savePreferences()
                            if isSaved {
                                sessionStore.updatePreferencesRequirement(hasPreferences: true)
                                isPresented = false
                            }
                        }
                    } label: {
                        Text(viewModel.isSaving ? "MENYIMPAN..." : "LANJUTKAN")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: 320)
                            .frame(height: 50)
                            .background(viewModel.selectedIDs.isEmpty ? Color.gray : Color.blue)
                            .clipShape(Capsule())
                    }
                    .disabled(viewModel.selectedIDs.isEmpty || viewModel.isSaving)
                }
                .padding(.horizontal, 24)
            }
        }
        .task {
            await viewModel.loadPreferences()
        }
    }
}

#Preview {
    PreferencesView(isPresented: .constant(true), viewModel: PreferencesViewModel())
        .environmentObject(SessionStore())
}
