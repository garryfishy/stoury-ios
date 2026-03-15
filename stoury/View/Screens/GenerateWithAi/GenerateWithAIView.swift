import SwiftUI
import UIKit

struct GenerateWithAIView: View {
    @StateObject private var viewModel: TripGeneratorViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var tripName = ""
    @State private var selectedCity: String? = nil
    @State private var startDate: Date? = nil
    @State private var endDate: Date? = nil
    @State private var budget = ""
    @State private var usePreference = false
    @State private var selectedPreferenceIDs: Set<UUID> = []
    @State private var generatedTripRoute: GeneratedTripRoute?

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 4)
    private let sessionStore: SessionStore
    private let onGeneratedTrip: ((GeneratedTripRoute) -> Void)?

    init(sessionStore: SessionStore, onGeneratedTrip: ((GeneratedTripRoute) -> Void)? = nil) {
        self.sessionStore = sessionStore
        self.onGeneratedTrip = onGeneratedTrip
        _viewModel = StateObject(
            wrappedValue: TripGeneratorViewModel(sessionStore: sessionStore)
        )
    }

    private var isFormValid: Bool {
        !tripName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !(selectedCity?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true) &&
        startDate != nil &&
        endDate != nil &&
        !budget.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private func dismissKeyboard() {
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil,
            from: nil,
            for: nil
        )
    }

    private func togglePreference(_ preference: Preference) {
        if selectedPreferenceIDs.contains(preference.id) {
            selectedPreferenceIDs.remove(preference.id)
        } else {
            selectedPreferenceIDs.insert(preference.id)
        }
    }

    private func applyAccountPreferencesSelection() {
        let matchedIDs = viewModel.matchedAccountPreferenceIDs()

        print("GenerateWithAIView.applyAccountPreferencesSelection matched IDs:", matchedIDs.map(\.uuidString))
        print("GenerateWithAIView.applyAccountPreferencesSelection master preferences:", viewModel.masterPreferences.map(\.name))
        print("GenerateWithAIView.applyAccountPreferencesSelection account preferences:", viewModel.accountPreferences.map(\.name))

        guard !matchedIDs.isEmpty else {
            selectedPreferenceIDs.removeAll()
            usePreference = false
            viewModel.preferenceErrorMessage = "Preferensi akun belum cocok dengan master data."
            print("GenerateWithAIView.applyAccountPreferencesSelection no matching preferences found")
            return
        }

        viewModel.preferenceErrorMessage = nil
        selectedPreferenceIDs = matchedIDs
        print("GenerateWithAIView.applyAccountPreferencesSelection selectedPreferenceIDs:", selectedPreferenceIDs.map(\.uuidString))
    }

    private func preferenceAssetName(for preference: Preference) -> String {
        switch preference.slug.lowercased() {
        case "popular":
            return "populer"
        case "food":
            return "makanan"
        case "shopping":
            return "belanja"
        case "history":
            return "sejarah"
        default:
            return preference.name.lowercased()
        }
    }

    private func submitGeneration() {
        dismissKeyboard()

        Task {
            let route = await viewModel.generateTrip(
                title: tripName,
                destinationName: selectedCity,
                startDate: startDate,
                endDate: endDate,
                budget: budget,
                useAccountPreferences: usePreference,
                selectedPreferenceIDs: selectedPreferenceIDs
            )

            if let route {
                if let onGeneratedTrip {
                    onGeneratedTrip(route)
                } else {
                    generatedTripRoute = route
                }
            }
        }
    }

    var body: some View {
        ZStack(alignment: .top) {
            Color("PrimaryOrange")
                .ignoresSafeArea()

            VStack(spacing: 0) {
                header

                VStack(spacing: 0) {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 28) {
                            InputField(
                                title: "Nama Trip",
                                placeholder: "Masukkan nama trip",
                                text: $tripName,
                                leadingSystemImage: "briefcase"
                            )

                            DropdownField(
                                title: "Lokasi",
                                placeholder: "Pilih lokasi",
                                options: viewModel.destinationNames,
                                selectedValue: $selectedCity,
                                leadingSystemImage: "magnifyingglass"
                            )
                            .zIndex(10)

                            DateRangePickerField(
                                title: "Tanggal Perjalanan",
                                placeholder: "Pilih Tanggal",
                                startDate: $startDate,
                                endDate: $endDate,
                                leadingSystemImage: "calendar",
                                blockPreviousDates: true
                            )
                            .zIndex(20)

                            InputField(
                                title: "Budget",
                                placeholder: "Masukkan Budget",
                                text: $budget,
                                leadingSystemImage: "dollarsign.circle",
                                keyboardType: .numberPad,
                                textContentType: .oneTimeCode,
                                numbersOnly: true,
                                groupedNumbers: true
                            )

                            VStack(alignment: .leading, spacing: 12) {
                                Text("Preferensi")
                                    .font(.system(size: 16, weight: .bold))

                                Toggle(isOn: $usePreference) {
                                    Text("Gunakan preferensi akun saya")
                                        .font(.system(size: 15))
                                }
                                .toggleStyle(Checkbox())

                                if viewModel.isLoadingInitialData && viewModel.masterPreferences.isEmpty {
                                    ProgressView("Memuat preferensi...")
                                        .font(.system(size: 12))
                                }

                                if let preferenceErrorMessage = viewModel.preferenceErrorMessage {
                                    Text(preferenceErrorMessage)
                                        .font(.system(size: 12))
                                        .foregroundStyle(.red)
                                }

                                LazyVGrid(columns: columns, spacing: 12) {
                                    ForEach(viewModel.masterPreferences) { preference in
                                        let isSelected = selectedPreferenceIDs.contains(preference.id)

                                        VStack(spacing: 8) {
                                            Image(preferenceAssetName(for: preference))
                                                .resizable()
                                                .scaledToFill()
                                                .scaleEffect(2)
                                                .aspectRatio(1, contentMode: .fit)
                                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                                .overlay {
                                                    RoundedRectangle(cornerRadius: 10)
                                                        .stroke(
                                                            isSelected ? Color("PrimaryOrange") : Color.clear,
                                                            lineWidth: 2
                                                        )
                                                }

                                            Text(preference.name)
                                                .font(.system(size: 14, weight: .medium))
                                                .multilineTextAlignment(.center)
                                        }
                                        .contentShape(Rectangle())
                                        .onTapGesture {
                                            togglePreference(preference)
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 32)
                    }
                    .simultaneousGesture(
                        TapGesture().onEnded {
                            dismissKeyboard()
                        }
                    )
                    .zIndex(1)

                    VStack(alignment: .leading, spacing: 10) {
                        if let errorMessage = viewModel.errorMessage {
                            Text(errorMessage)
                                .font(.system(size: 12))
                                .foregroundStyle(.red)
                        }

                        StouryButton(
                            title: "Buat Rencana Perjalanan",
                            style: .primary,
                            isDisabled: !isFormValid || viewModel.isGenerating
                        ) {
                            submitGeneration()
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .padding(.top, 14)
                    .padding(.bottom, 20)
                    .background(.clear)
                    .padding(.horizontal, 16)
                    .zIndex(0)
                }
                .background(.white)
                .clipShape(
                    UnevenRoundedRectangle(
                        topLeadingRadius: 28,
                        topTrailingRadius: 28
                    )
                )
                .ignoresSafeArea(edges: .bottom)
            }
        }
        .simultaneousGesture(
            TapGesture().onEnded {
                dismissKeyboard()
            }
        )
        .task {
            await viewModel.loadInitialData()

            if selectedCity == nil || selectedCity?.isEmpty == true {
                selectedCity = viewModel.defaultDestinationName
            }
        }
        .onChange(of: usePreference) { _, newValue in
            viewModel.preferenceErrorMessage = nil
            print("GenerateWithAIView.usePreference toggled:", newValue)
            print("GenerateWithAIView.usePreference current selectedPreferenceIDs:", selectedPreferenceIDs.map(\.uuidString))

            guard newValue else {
                print("GenerateWithAIView.usePreference turned off")
                return
            }
            applyAccountPreferencesSelection()
        }
        .onReceive(NotificationCenter.default.publisher(for: .returnToHomeRequested)) { _ in
            dismiss()
        }
        .overlay {
            if viewModel.isGenerating {
                GenerateWithAILoadingView()
                    .transition(.opacity)
            }
        }
        .allowsHitTesting(!viewModel.isGenerating)
        .navigationBarBackButtonHidden(true)
        .enableSwipeBack()
        .navigationDestination(item: $generatedTripRoute) { route in
            GeneratedItineraryView(sessionStore: sessionStore, route: route)
        }
    }

    private var header: some View {
        ZStack(alignment: .top) {
            Color("PrimaryOrange")
                .frame(height: 80)

            VStack(spacing: 4) {
                HStack(spacing: 8) {
                    Image(systemName: "sparkles")
                        .foregroundStyle(.white)

                    Text("Dibuat dengan AI")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(.white)
                }

                Text("Buat trip terbaikmu!")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(.white.opacity(0.95))
            }
            .padding(.top, 14)

            HStack {
                BackButton()
                Spacer()
            }
            .padding(.top, 8)
        }
    }
}

#Preview {
    GenerateWithAIView(sessionStore: SessionStore())
}
