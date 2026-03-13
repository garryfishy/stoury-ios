import SwiftUI

struct EmptyTripView: View {
    let onGenerateAI: () -> Void
    let onManual: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Perjalanan Saya")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.black)
                .padding(.top, 8)

            Spacer()

            TripCard(
                title: "Siap menjelajah hari ini?",
                subtitle: "Batam, Jogja, atau Bali?",
                description: "Buat perjalananmu sendiri atau biarkan AI\nkami membantumu menjelajahi kota pilihan.",
                primaryTitle: "Buat rencana dengan AI",
                secondaryTitle: "Tentukan sendiri",
                onPrimary: onGenerateAI,
                onSecondary: onManual
            )

            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color.white)
    }
}

#Preview {
    EmptyTripView(onGenerateAI: {}, onManual: {})
}
