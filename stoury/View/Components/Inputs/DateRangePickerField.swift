import SwiftUI

struct DateRangePickerField: View {
    let title: String
    let placeholder: String
    @Binding var startDate: Date?
    @Binding var endDate: Date?
    var leadingSystemImage: String? = nil

    @State private var isExpanded = false
    @State private var displayedMonth = Date()

    private let fieldHeight: CGFloat = 52

    private var displayText: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "id_ID")
        formatter.dateFormat = "d MMM yyyy"

        if let startDate, let endDate {
            return "\(formatter.string(from: startDate)) - \(formatter.string(from: endDate))"
        }

        if let startDate {
            return formatter.string(from: startDate)
        }

        return placeholder
    }

    private var isPlaceholder: Bool {
        startDate == nil && endDate == nil
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 18, weight: .semibold))

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

                }
                .padding(.horizontal, 16)
                .frame(height: fieldHeight)
                .frame(maxWidth: .infinity)
                .background(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.25), lineWidth: 1)
                )
            }
            .buttonStyle(.plain)
            .overlay(alignment: .topLeading) {
                if isExpanded {
                    CustomDateRangeCalendar(
                        displayedMonth: $displayedMonth,
                        startDate: $startDate,
                        endDate: $endDate
                    )
                    .offset(y: fieldHeight + 8)
                    .zIndex(9999)
                }
            }
        }
        .zIndex(isExpanded ? 9999 : 0)
    }
}
