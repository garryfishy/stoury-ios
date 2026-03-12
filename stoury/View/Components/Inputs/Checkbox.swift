import SwiftUI

struct Checkbox: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        Button {
            configuration.isOn.toggle()
        } label: {
            HStack {
                Image(systemName: configuration.isOn ? "checkmark.square.fill" : "square")
                    .foregroundColor(.orange)

                configuration.label
                    .foregroundColor(.black)
            }
        }
        .buttonStyle(.plain)
    }
}
