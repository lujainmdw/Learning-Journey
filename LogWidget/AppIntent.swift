import AppIntents
import WidgetKit

struct ToggleLearnIntent: AppIntent {
    static var title: LocalizedStringResource = "Toggle Learned Status"
    static var description = IntentDescription("Logs or unlogs today as learned from the widget.")

    func perform() async throws -> some IntentResult {
        let suiteName = "group.com.lujainah.learningjourney"
        let defaults = UserDefaults(suiteName: suiteName)
        
        let currentStatus = defaults?.string(forKey: "widget_todayStatus") ?? "none"
        var learnedDays = defaults?.integer(forKey: "widget_learnedDays") ?? 0
        
        if currentStatus == "learned" {
            learnedDays = max(0, learnedDays - 1)
            defaults?.set("none", forKey: "widget_todayStatus")
        } else if currentStatus == "none" {
            learnedDays += 1
            defaults?.set("learned", forKey: "widget_todayStatus")
        }
        
        defaults?.set(learnedDays, forKey: "widget_learnedDays")
        WidgetCenter.shared.reloadAllTimelines()
        
        return .result()
    }
}
