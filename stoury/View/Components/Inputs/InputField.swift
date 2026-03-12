import SwiftUI

struct InputField: View {
    let title: String
    let placeholder: String
    @Binding var text: String

    var leadingSystemImage: String? = nil
    var keyboardType: UIKeyboardType = .default
    var isSecure: Bool = false
    var helperText: String? = nil
    var errorText: String? = nil

    private let fieldHeight: CGFloat = 52

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
                    } else {
                        TextField("", text: $text)
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
            .keyboardType(keyboardType)
            .autocorrectionDisabled()
            .textInputAutocapitalization(.never)

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
}
