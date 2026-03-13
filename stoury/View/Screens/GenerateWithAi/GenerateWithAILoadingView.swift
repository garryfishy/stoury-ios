import SwiftUI

struct GenerateWithAILoadingView: View {
    @State private var animateIcon = false

    var body: some View {
        ZStack {
            Color("PrimaryOrange")
                .ignoresSafeArea()

            VStack(spacing: 22) {
                ZStack {
                    Circle()
                        .fill(.white)
                        .frame(width: 88, height: 88)
                        .shadow(color: .black.opacity(0.08), radius: 18, x: 0, y: 10)

                    Image(systemName: "sparkles")
                        .font(.system(size: 38, weight: .semibold))
                        .foregroundStyle(Color("PrimaryOrange"))
                        .scaleEffect(animateIcon ? 1.04 : 0.92)
                        .opacity(animateIcon ? 1 : 0.8)
                        .animation(
                            .easeInOut(duration: 1.1).repeatForever(autoreverses: true),
                            value: animateIcon
                        )
                }

                VStack(spacing: 8) {
                    Text("Membuat Rencana Perjalanan Anda")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)

                    Text("Mohon tunggu, kami sedang menyusun rencana perjalanan terbaik untuk Anda...")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(.white.opacity(0.95))
                        .multilineTextAlignment(.center)
                        .lineSpacing(2)
                        .padding(.horizontal, 8)
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 16)
            }
        }
        .onAppear {
            animateIcon = true
        }
    }
}

#Preview {
    GenerateWithAILoadingView()
}
