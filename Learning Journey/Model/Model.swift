import SwiftUI
import Combine


enum GoalStatus {
    case active
    case completed
    case failed
}

struct LearningModel {
    var topic: String = ""
    var selectedDuration: String = "Week"
    let durations = ["Week", "Month", "Year"]
    
    var learnedDays: Int = 0
    var freezedDays: Int = 0
    var dayLogs: [Date: String] = [:]
    var goalStartDate: Date = Calendar.current.startOfDay(for: Date())
    var currentDate: Date = Calendar.current.startOfDay(for: Date())
    
    var goalDays: Int {
        if selectedDuration == "Week" { return 7 }
        else if selectedDuration == "Month" { return 30 }
        else { return 365 }
    }
    
    var maxFreezes: Int {
        if selectedDuration == "Week" { return 2 }
        else if selectedDuration == "Month" { return 8 }
        else { return 96 }
    }
}
