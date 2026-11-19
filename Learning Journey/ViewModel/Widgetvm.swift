import SwiftUI
import WidgetKit

struct LogWidgetViewModel {
    let entry: LearningEntry
    
    var learnedDaysText: String {
        entry.learnedDays == 1 ? "1 day" : "\(entry.learnedDays) days"
    }
    
    var freezedSummaryText: String {
        "Learned • \(entry.freezedDays) freezed"
    }
    
    var isLearned: Bool {
        entry.todayStatus == "learned"
    }
    
    var statusLabel: String {
        switch entry.todayStatus {
        case "learned": return "Logged ✓"
        case "freezed": return "Freezed"
        default: return "Not Logged Yet"
        }
    }
    
    var statusIcon: String {
        switch entry.todayStatus {
        case "learned": return "flame.fill"
        case "freezed": return "snowflake"
        default: return "circle.dashed"
        }
    }
    
    var statusColor: Color {
        switch entry.todayStatus {
        case "learned": return .orange
        case "freezed": return .cyan
        default: return .gray
        }
    }
    
    var statusBadge: String {
        switch entry.todayStatus {
        case "learned": return "Logged"
        case "freezed": return "Freezed"
        default: return "Pending"
        }
    }
}

// MARK: - Timeline Provider
struct Provider: TimelineProvider {
    private let sharedDefaults = UserDefaults(suiteName: "group.LearningJourney")

    func placeholder(in context: Context) -> LearningEntry {
        LearningEntry(date: Date(), learnedDays: 1, freezedDays: 0, todayStatus: "learned")
    }

    func getSnapshot(in context: Context, completion: @escaping (LearningEntry) -> Void) {
        completion(loadEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<LearningEntry>) -> Void) {
        let entry = loadEntry()
        let nextMidnight = Calendar.current.startOfDay(for: Date().addingTimeInterval(86400))
        completion(Timeline(entries: [entry], policy: .after(nextMidnight)))
    }
    
    private func loadEntry() -> LearningEntry {
        let learned = sharedDefaults?.integer(forKey: "widget_learnedDays") ?? 0
        let freezed = sharedDefaults?.integer(forKey: "widget_freezedDays") ?? 0
        let status = sharedDefaults?.string(forKey: "widget_todayStatus") ?? "none"
        return LearningEntry(date: Date(), learnedDays: learned, freezedDays: freezed, todayStatus: status)
    }
}
