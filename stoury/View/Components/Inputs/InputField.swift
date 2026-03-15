import SwiftUI
import UIKit

struct InputField: View {
    let title: String
    let placeholder: String
    @Binding var text: String

    var leadingSystemImage: String? = nil
    var keyboardType: UIKeyboardType = .default
    var textContentType: UITextContentType? = nil
    var numbersOnly: Bool = false
    var groupedNumbers: Bool = false
    var isSecure: Bool = false
    var helperText: String? = nil
    var errorText: String? = nil

    private let fieldHeight: CGFloat = 52
    private static let groupedNumberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = "."
        formatter.decimalSeparator = ","
        formatter.maximumFractionDigits = 0
        formatter.usesGroupingSeparator = true
        return formatter
    }()

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)

            HStack {
                if let leadingSystemImage {
                    Image(systemName: leadingSystemImage)
                        .foregroundColor(.gray)
                }

                ZStack(alignment: .leading) {
                    if text.isEmpty {
                        Text(placeholder)
                            .foregroundColor(.gray)
                    }

                    if isSecure {
                        SecureField("", text: $text)
                            .keyboardType(keyboardType)
                            .textContentType(textContentType)
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.never)
                    } else {
                        TextField("", text: $text)
                            .keyboardType(keyboardType)
                            .textContentType(textContentType)
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.never)
                    }
                }

                Spacer(minLength: 0)
            }
            .padding(.horizontal, 16)
            .frame(height: fieldHeight)
            .background(Color.white)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        errorText == nil ? Color.gray.opacity(0.3) : Color.red,
                        lineWidth: 1
                    )
            )
            .onChange(of: text) { _, newValue in
                let sanitizedValue = sanitizedInput(from: newValue)
                if sanitizedValue != newValue {
                    text = sanitizedValue
                }
            }

            if let errorText {
                Text(errorText)
                    .font(.system(size: 12))
                    .foregroundColor(.red)
            } else if let helperText {
                Text(helperText)
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
            }
        }
    }

    private func sanitizedInput(from rawValue: String) -> String {
        guard numbersOnly || groupedNumbers else { return rawValue }

        let digitsOnly = rawValue.filter(\.isNumber)
        guard groupedNumbers else { return digitsOnly }
        guard !digitsOnly.isEmpty else { return "" }

        let numericValue = NSDecimalNumber(string: digitsOnly)
        guard numericValue != .notANumber else { return digitsOnly }

        return Self.groupedNumberFormatter.string(from: numericValue) ?? digitsOnly
    }
}
