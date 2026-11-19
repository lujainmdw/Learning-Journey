import SwiftUI
import Combine
import WidgetKit

//Push to the viewmodel
class LearningViewModel: ObservableObject {
    @Published private var model = LearningModel()
    
    let themeVM = ThemeViewModel.shared
    
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
        
        let lastActiveDate = model.dayLogs.keys.max() ?? model.goalStartDate
        let hoursWithoutLogging = model.currentDate.timeIntervalSince(lastActiveDate) / 3600
        if hoursWithoutLogging > 32 || (currentDayIndex == model.goalDays && todayStatus != "none" && totalLoggedDays < model.goalDays) {
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
        syncWidgetData()
    }
    func logLearned() {
        let dayKey = calendar.startOfDay(for: model.currentDate)
        
        if todayStatus == "learned" {
            model.dayLogs.removeValue(forKey: dayKey)
            model.learnedDays -= 1
        } else if todayStatus == "none" {
            model.dayLogs[dayKey] = "learned"
            model.learnedDays += 1
        }
        syncWidgetData()
    }

  
    func logFreeze() {
        guard !isFreezeDisabled else { return }
        let dayKey = calendar.startOfDay(for: model.currentDate)
        model.dayLogs[dayKey] = "freezed"
        model.freezedDays += 1
        syncWidgetData()
    }
    
    //for testing
    func simulateNextDay() {
        if let nextDay = calendar.date(byAdding: .day, value: 1, to: model.currentDate) {
            model.currentDate = nextDay
            syncWidgetData()
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
            return themeVM.surfaceBackground
        } else if status == "freezed" {
            return Color.cyan.opacity(0.18)
        } else if isCurrentDay && goalStatus == .active {
            return themeVM.primaryColor
        } else {
            return Color.clear
        }
    }
    
    func dateTextColor(for date: Date) -> Color {
        let dayKey = calendar.startOfDay(for: date)
        let status = model.dayLogs[dayKey] ?? "none"
        
        if status == "learned" {
            return themeVM.primaryColor
        } else if status == "freezed" {
            return .cyan
        } else {
            return .primary
        }
    }
    
    private let sharedDefaults = UserDefaults(suiteName: "group.LearningJourney")

    func syncWidgetData() {
        if sharedDefaults == nil {
               print(" ERROR: App Group UserDefaults is NIL!")
           } else {
        sharedDefaults?.set(model.learnedDays, forKey: "widget_learnedDays")
        sharedDefaults?.set(model.freezedDays, forKey: "widget_freezedDays")
        sharedDefaults?.set(todayStatus, forKey: "widget_todayStatus")
               sharedDefaults?.synchronize()
                       print(" Saved to Widget -> Learned: \(model.learnedDays), Status: \(todayStatus)")
                   }
        WidgetCenter.shared.reloadTimelines(ofKind: "LogWidget")
               }
    init() {
        syncWidgetData()
    }

}
