import SwiftUI
import Combine

class LearningViewModel: ObservableObject {
    @Published private var model = LearningModel()
    
    private let calendar = Calendar.current
    
    var topic: String {
        get { model.topic }
        set { model.topic = newValue }
    }
    
    var selectedDuration: String {
        get { model.selectedDuration }
        set { model.selectedDuration = newValue }
    }
    
    var durations: [String] { model.durations }
    var goalDays: Int { model.goalDays }
    var maxFreezes: Int { model.maxFreezes }
    var learnedDays: Int { model.learnedDays }
    var freezedDays: Int { model.freezedDays }
    var currentDate: Date { model.currentDate }
    
    var todayStatus: String {
        let dayKey = calendar.startOfDay(for: model.currentDate)
        return model.dayLogs[dayKey] ?? "none"
    }
    
    var currentDayIndex: Int {
        let start = calendar.startOfDay(for: model.goalStartDate)
        let current = calendar.startOfDay(for: model.currentDate)
        let diff = calendar.dateComponents([.day], from: start, to: current).day ?? 0
        return diff + 1
    }
    
    var goalStatus: GoalStatus {
        let totalLoggedDays = model.learnedDays + model.freezedDays
        if totalLoggedDays >= model.goalDays {
            return .completed
        }
        
        let missedDaysBeforeToday = (currentDayIndex - 1) - totalLoggedDays
        if missedDaysBeforeToday > 0 || (currentDayIndex == model.goalDays && todayStatus != "none" && totalLoggedDays < model.goalDays) {
            return .failed
        }
        return .active
    }
    
    var isFreezeDisabled: Bool {
        return (model.freezedDays >= model.maxFreezes) || (todayStatus != "none")
    }
    
    func startNewGoal() {
        model.learnedDays = 0
        model.freezedDays = 0
        model.dayLogs.removeAll()
        let today = calendar.startOfDay(for: Date())
        model.goalStartDate = today
        model.currentDate = today
    }
    
    func logLearned() {
        guard todayStatus == "none" else { return }
        let dayKey = calendar.startOfDay(for: model.currentDate)
        model.dayLogs[dayKey] = "learned"
        model.learnedDays += 1
    }
    
    func logFreeze() {
        guard !isFreezeDisabled else { return }
        let dayKey = calendar.startOfDay(for: model.currentDate)
        model.dayLogs[dayKey] = "freezed"
        model.freezedDays += 1
    }
    
    func simulateNextDay() {
        if let nextDay = calendar.date(byAdding: .day, value: 1, to: model.currentDate) {
            model.currentDate = nextDay
        }
    }
    
    func formatDays(_ count: Int) -> String {
        return count == 1 ? "1 day" : "\(count) days"
    }
    
    var formattedToday: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, d MMMM"
        return formatter.string(from: model.currentDate)
    }
    
    var currentWeekDays: [Date] {
        guard let weekInterval = calendar.dateInterval(of: .weekOfYear, for: model.currentDate) else {
            return []
        }
        return (0..<7).compactMap { dayOffset in
            calendar.date(byAdding: .day, value: dayOffset, to: weekInterval.start)
        }
    }
    
    func dayLetter(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEEE"
        return formatter.string(from: date)
    }
    
    func dayNumber(for date: Date) -> Int {
        return calendar.component(.day, from: date)
    }
    
    var calendarMonths: [Date] {
        let year = calendar.component(.year, from: model.currentDate)
        return (1...12).compactMap { month in
            calendar.date(from: DateComponents(year: year, month: month, day: 1))
        }
    }
    
    func monthYearTitle(for monthStart: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: monthStart)
    }
    
    func daysInMonthGrid(for monthStart: Date) -> [Date?] {
        guard let range = calendar.range(of: .day, in: .month, for: monthStart) else { return [] }
        let firstWeekday = calendar.component(.weekday, from: monthStart)
        let leadingEmptySpaces = firstWeekday - 1
        
        var grid: [Date?] = Array(repeating: nil, count: leadingEmptySpaces)
        for dayOffset in 0..<range.count {
            if let date = calendar.date(byAdding: .day, value: dayOffset, to: monthStart) {
                grid.append(date)
            }
        }
        return grid
    }
    
    func dateCircleColor(for date: Date) -> Color {
        let dayKey = calendar.startOfDay(for: date)
        let status = model.dayLogs[dayKey] ?? "none"
        let isCurrentDay = calendar.isDate(dayKey, inSameDayAs: model.currentDate)
        
        if status == "learned" {
            return Color.orange.opacity(0.18)
        } else if status == "freezed" {
            return Color.cyan.opacity(0.18)
        } else if isCurrentDay && goalStatus == .active {
            return Color.orange
        } else {
            return Color.clear
        }
    }
    
    func dateTextColor(for date: Date) -> Color {
        let dayKey = calendar.startOfDay(for: date)
        let status = model.dayLogs[dayKey] ?? "none"
        
        if status == "learned" {
            return .orange
        } else if status == "freezed" {
            return .cyan
        } else {
            return .primary
        }
    }
}
