import WidgetKit
import Foundation

struct LearningEntry: TimelineEntry {
    let date: Date
    let learnedDays: Int
    let freezedDays: Int
    let todayStatus: String
}
