import SwiftUI

struct GenerateWithAIView: View {
    @State private var tripName: String = ""
    @State private var options: [String] = ["Batam", "Yogyakarta", "Bali"]
    @State private var selectedCity: String? = ""
    @State private var startDate: Date? = nil
    @State private var endDate: Date? = nil
    @State private var budget: String = ""
    @State private var usePreference: Bool = false
    @State private var selectedPreferences: Set<String> = []
    
    private let preferences = [
        "Populer",
        "Makanan",
        "Belanja",
        "Sejarah"
    ]

    let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 4)

    func doSomething() {}
    
    private func togglePreference(_ preference: String) {
        if selectedPreferences.contains(preference) {
            selectedPreferences.remove(preference)
        } else {
            selectedPreferences.insert(preference)
        }
    }
    
    private var isFormValid: Bool {
        !tripName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !(selectedCity?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true) &&
        startDate != nil &&
        endDate != nil &&
        !budget.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
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
                                options: options,
                                selectedValue: $selectedCity,
                                leadingSystemImage: "magnifyingglass"
                            )
                            .zIndex(10)

                            DateRangePickerField(
                                title: "Tanggal Perjalanan",
                                placeholder: "Pilih Tanggal",
                                startDate: $startDate,
                                endDate: $endDate,
                                leadingSystemImage: "calendar"
                            )

                            InputField(
                                title: "Budget",
                                placeholder: "Masukkan Budget",
                                text: $budget,
                                leadingSystemImage: "dollarsign.circle"
                            )

                            VStack(alignment: .leading, spacing: 12) {
                                Text("Preferensi")
                                    .font(.system(size: 16, weight: .bold))
                                
                                Toggle(isOn: $usePreference) {
                                    Text("Gunakan preferensi akun saya")
                                        .font(.system(size: 15))
                                }
                                .toggleStyle(Checkbox())
                                
                                LazyVGrid(columns: columns, spacing: 12) {
                                    ForEach(preferences, id: \.self) { preference in
                                        let isSelected = selectedPreferences.contains(preference)
                                        
                                        VStack(spacing: 8) {
                                            Image(preference.lowercased())
                                                .resizable()
                                                .scaledToFill()
                                                .aspectRatio(1, contentMode: .fit)
                                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                                .overlay {
                                                    RoundedRectangle(cornerRadius: 10)
                                                        .stroke(
                                                            isSelected ? Color("PrimaryOrange") : Color.clear,
                                                            lineWidth: 2
                                                        )
                                                }
                                            
                                            Text(preference)
                                                .font(.system(size: 14, weight: .medium))
                                                .multilineTextAlignment(.center)
                                        }
                                        .contentShape(Rectangle())
                                        .onTapGesture {
                                            togglePreference(preference)
                                        }
                                    }
                                }
                            }}
                        .padding(.horizontal, 16)
                        .padding(.top, 32)
                    }

                    VStack {
                        StouryButton(
                            title: "Buat Rencana Perjalanan",
                            style: .primary,
                            isDisabled: !isFormValid
                        ) {
                            doSomething()
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .padding(.top, 14)
                    .padding(.bottom, 20)
                    .background(.clear)
                }
                .background(.white)
                .clipShape(
                    UnevenRoundedRectangle(
                        topLeadingRadius: 28,
                        topTrailingRadius: 28
                    )
                )
                .background(.white)
                .ignoresSafeArea(edges: .bottom)
            }
        }
    }

    var header: some View {
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

    func categoryTitle(_ index: Int) -> String {
        switch index {
        case 0: return "Populer"
        case 1: return "Makanan"
        case 2: return "Belanja"
        default: return "Sejarah"
        }
    }
}
#Preview {
  GenerateWithAIView()
}

