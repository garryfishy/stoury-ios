//
//  CustomDateRangeCalendar.swift
//  stoury
//
//  Created by Garry Agassi on 12/03/26.
//

import SwiftUI

struct CustomDateRangeCalendar: View {
    @Binding var displayedMonth: Date
    @Binding var startDate: Date?
    @Binding var endDate: Date?

    private let calendar = Calendar.current
    private let weekdays = ["MIN", "SEN", "SEL", "RAB", "KAM", "JUM", "SAB"]

    private var daysInMonth: [DateValue] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: displayedMonth),
              let firstWeekInterval = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.start),
              let lastWeekInterval = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.end - 1)
        else {
            return []
        }

        var days: [DateValue] = []
        var currentDate = firstWeekInterval.start

        while currentDate < lastWeekInterval.end {
            let isCurrentMonth = calendar.isDate(currentDate, equalTo: displayedMonth, toGranularity: .month)
            let day = calendar.component(.day, from: currentDate)

            days.append(
                DateValue(
                    day: day,
                    date: currentDate,
                    isCurrentMonth: isCurrentMonth
                )
            )

            guard let nextDate = calendar.date(byAdding: .day, value: 1, to: currentDate) else {
                break
            }
            currentDate = nextDate
        }

        return days
    }

    private var monthTitle: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "id_ID")
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: displayedMonth).capitalized
    }

    var body: some View {
        VStack(spacing: 16) {
            headerView
            weekdayHeader
            daysGrid
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.gray.opacity(0.15), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
    }

    private var headerView: some View {
        HStack {
            Text(monthTitle)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.orange)

            Spacer()

            Button {
                if let previousMonth = calendar.date(byAdding: .month, value: -1, to: displayedMonth) {
                    displayedMonth = previousMonth
                }
            } label: {
                Image(systemName: "chevron.left")
                    .foregroundColor(.orange)
                    .font(.system(size: 20, weight: .semibold))
            }

            Button {
                if let nextMonth = calendar.date(byAdding: .month, value: 1, to: displayedMonth) {
                    displayedMonth = nextMonth
                }
            } label: {
                Image(systemName: "chevron.right")
                    .foregroundColor(.orange)
                    .font(.system(size: 20, weight: .semibold))
            }
        }
    }

    private var weekdayHeader: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 12) {
            ForEach(weekdays, id: \.self) { day in
                Text(day)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.orange)
                    .frame(maxWidth: .infinity)
            }
        }
    }

    private var daysGrid: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 12) {
            ForEach(daysInMonth) { value in
                if value.isCurrentMonth {
                    dayCell(for: value.date)
                } else {
                    Text("\(value.day)")
                        .foregroundColor(.clear)
                        .frame(width: 36, height: 36)
                }
            }
        }
    }

    @ViewBuilder
    private func dayCell(for date: Date) -> some View {
        let day = calendar.component(.day, from: date)
        let isStart = isSameDay(date, startDate)
        let isEnd = isSameDay(date, endDate)
        let isSingleSelected = isStart && endDate == nil
        let isInRange = isDateInRange(date)
        let isToday = calendar.isDateInToday(date)

        Button {
            handleDateTap(date)
        } label: {
            ZStack {
                if isInRange {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.orange.opacity((isStart || isEnd || isSingleSelected) ? 1.0 : 0.18))
                        .frame(height: 36)
                }

                if isToday && !isInRange {
                    Circle()
                        .stroke(Color.orange.opacity(0.5), lineWidth: 1)
                        .frame(width: 36, height: 36)
                }

                Text("\(day)")
                    .font(.system(size: 18, weight: (isStart || isEnd || isSingleSelected) ? .bold : .regular))
                    .foregroundColor((isStart || isEnd || isSingleSelected) ? .white : .primary)
                    .frame(width: 36, height: 36)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }

    private func handleDateTap(_ tappedDate: Date) {
        let normalizedDate = calendar.startOfDay(for: tappedDate)

        if startDate == nil {
            startDate = normalizedDate
            endDate = nil
            return
        }

        if let startDate, endDate == nil {
            let normalizedStart = calendar.startOfDay(for: startDate)

            if normalizedDate >= normalizedStart {
                endDate = normalizedDate
            } else {
                self.startDate = normalizedDate
                self.endDate = normalizedStart
            }
            return
        }

        startDate = normalizedDate
        endDate = nil
    }

    private func isSameDay(_ lhs: Date, _ rhs: Date?) -> Bool {
        guard let rhs else { return false }
        return calendar.isDate(lhs, inSameDayAs: rhs)
    }

    private func isDateInRange(_ date: Date) -> Bool {
        guard let startDate else { return false }

        let normalizedDate = calendar.startOfDay(for: date)
        let normalizedStart = calendar.startOfDay(for: startDate)

        if let endDate {
            let normalizedEnd = calendar.startOfDay(for: endDate)
            return normalizedDate >= normalizedStart && normalizedDate <= normalizedEnd
        }

        return normalizedDate == normalizedStart
    }
}

struct DateValue: Identifiable {
    let id = UUID()
    let day: Int
    let date: Date
    let isCurrentMonth: Bool
}
