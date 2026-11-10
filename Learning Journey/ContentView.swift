import SwiftUI
import Combine

enum GoalStatus {
    case active
    case completed
    case failed
}

class LearningViewModel: ObservableObject {
    @Published var topic: String = ""
    @Published var selectedDuration: String = "Week"
    let durations = ["Week", "Month", "Year"]
    
    var goalDays: Int {
            if selectedDuration == "Week" {
                return 7
            } else if selectedDuration == "Month" {
                return 30
            } else {
                return 365
            }
        }
    
    var maxFreezes: Int {
        if selectedDuration == "Week" {
            return 2
        } else if selectedDuration == "Month" {
            return 8
        } else {
            return 96
        }
    }
    
    @Published var learnedDays: Int = 0
    @Published var freezedDays: Int = 0
    @Published var dayLogs: [Date: String] = [:]
    
    @Published var goalStartDate: Date = Calendar.current.startOfDay(for: Date())
    @Published var currentDate: Date = Calendar.current.startOfDay(for: Date())
    
    
    private let calendar = Calendar.current
  //  private let today = Date()
    
    var todayStatus: String {
           let dayKey = calendar.startOfDay(for: currentDate)
           return dayLogs[dayKey] ?? "none"
       }
    
    var currentDayIndex: Int {
           let start = calendar.startOfDay(for: goalStartDate)
           let current = calendar.startOfDay(for: currentDate)
           let diff = calendar.dateComponents([.day], from: start, to: current).day ?? 0
           return diff + 1
       }
    
    var goalStatus: GoalStatus {
           let totalLoggedDays = learnedDays + freezedDays
           if totalLoggedDays >= goalDays {
           return .completed
                }
        
           let missedDaysBeforeToday = (currentDayIndex - 1) - totalLoggedDays
           if missedDaysBeforeToday > 0 || (currentDayIndex == goalDays && todayStatus != "none" && totalLoggedDays < goalDays) {
           return .failed
            }
                
            return .active
            }
            
    var isFreezeDisabled: Bool {
            return (freezedDays >= maxFreezes) || (todayStatus != "none")
            }
    
    func startNewGoal() {
            learnedDays = 0
            freezedDays = 0
            dayLogs.removeAll()
            let today = calendar.startOfDay(for: Date())
            goalStartDate = today
            currentDate = today
        }
        
        func logLearned() {
            guard todayStatus == "none" else { return }
            let dayKey = calendar.startOfDay(for: currentDate)
            dayLogs[dayKey] = "learned"
            learnedDays += 1
        }
        
        func logFreeze() {
            guard !isFreezeDisabled else { return }
            let dayKey = calendar.startOfDay(for: currentDate)
            dayLogs[dayKey] = "freezed"
            freezedDays += 1
        }
    
    func simulateNextDay() {
            if let nextDay = calendar.date(byAdding: .day, value: 1, to: currentDate) {
                currentDate = nextDay
            }
        }
    
    func formatDays(_ count: Int) -> String {
        return count == 1 ? "1 day" : "\(count) days"
    }
    
    var formattedToday: String {
           let formatter = DateFormatter()
           formatter.dateFormat = "EEEE, d MMMM"
           return formatter.string(from: currentDate)
       }
    
    var currentWeekDays: [Date] {
           guard let weekInterval = calendar.dateInterval(of: .weekOfYear, for: currentDate) else {
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
        let year = calendar.component(.year, from: currentDate)
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
           let status = dayLogs[dayKey] ?? "none"
           let isCurrentDay = calendar.isDate(dayKey, inSameDayAs: currentDate)
           
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
           let status = dayLogs[dayKey] ?? "none"
           
           if status == "learned" {
               return .orange
           } else if status == "freezed" {
               return .cyan
           } else {
               return .primary
           }
       }
   }



struct OnboardingView: View {
    @StateObject var vm = LearningViewModel()
    @State private var showActivityPage = false
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 32) {
                
        HStack {
        Spacer()
        Image(systemName: "flame.fill")
                .font(.system(size: 36))
                .foregroundColor(.orange)
        Spacer()
                }
                .padding(.top, 44)
                .padding(.bottom, 40)
                
        VStack(alignment: .leading, spacing: 8) {
        Text("Hello **Learner**")
                .fontWeight(.regular)
                .font(.system(size: 34))
                Text("This app will help you learn everyday!")
                .font(.system(size: 16))
                .foregroundColor(.secondary)
                }
                
        VStack(alignment: .leading, spacing: 14) {
        Text("I want to learn")
                .font(.system(size: 16, weight: .medium))
                    
        TextField("Swift", text: $vm.topic)
                .font(.system(size: 16))
                .tint(.orange)
                    
        Divider()
        .background(Color.primary.opacity(0.50))
                }
                
        VStack(alignment: .leading, spacing: 14) {
        Text("I want to learn it in a")
                .font(.system(size: 16, weight: .medium))
                    
        HStack(spacing: 12) {
                ForEach(vm.durations, id: \.self) { duration in
        let isSelected = (vm.selectedDuration == duration)
                            
                Button(action: {
                vm.selectedDuration = duration
                }) {
        Text(duration)
                .font(.system(size: 17, weight: .medium))
                .foregroundColor(isSelected ? .white : .secondary)
                .padding(.horizontal, 24)
                .frame(height: 44)
                }
                .glassEffect(
                    .regular
                    .tint(isSelected ? .orange : .clear)
                    .interactive(),
                    in: .capsule)
                        }
                    }
                }
                
        Spacer()
        VStack(spacing: 14) {
       // NavigationLink(destination: ActivityView(vm: vm)) {
            Button(action: {vm.startNewGoal()
                            showActivityPage = true
            }) {
                Text("Start Learning")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white)
                .padding(.horizontal, 44)
                .padding(.vertical, 14)
                }
                .glassEffect(
                    .regular
                    .tint(.orange)
                    .interactive(),
                    in: .capsule)
                                
        Text("You can edit your desire later")
                .font(.system(size: 12))
                .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.bottom, 20)
                }
                .padding(.horizontal, 24)
                .navigationDestination(isPresented: $showActivityPage) {
                    ActivityView(vm: vm, isPresented: $showActivityPage)
                            }
                 }
        .preferredColorScheme(.dark)
    }
    }

struct ActivityView: View {
    @ObservedObject var vm: LearningViewModel
    @Binding var isPresented: Bool
    
    @State private var showFullCalendar = false
    @State private var showUpdateGoal = false

    var body: some View {
        VStack(spacing: 24) {
            
        HStack(alignment: .top) {
        VStack(alignment: .leading, spacing: 4) {
        Text("Activity")
                .font(.system(size: 34, weight: .bold))
        Text(vm.formattedToday)
                .font(.system(size: 15))
                .foregroundColor(.secondary)
                }
                
        Spacer()
        HStack (spacing: 8) {
        Button(action: {showFullCalendar = true}) {
        Image(systemName: "calendar")
                .font(.system(size: 24, weight: .semibold))
                .foregroundColor(.primary)
                .frame(width: 52, height: 52)
                }.glassEffect(.regular.interactive())
                    
        Button(action: {showUpdateGoal = true}) {
        Image(systemName: "pencil.and.outline")
                .font(.system(size: 24, weight: .semibold))
                .foregroundColor(.primary)
                .frame(width: 52, height: 52)
              } .glassEffect(.regular.interactive())
            }
        .navigationDestination(isPresented: $showUpdateGoal) {
            UpdateGoalView(vm: vm, isPresented: $showUpdateGoal)
        }
            }
        .padding(.top, 8)
            
            HStack(spacing: 0) {
                ForEach(vm.currentWeekDays, id: \.self) { date in
            VStack(spacing: 10) {
            Text(vm.dayLetter(for: date))
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.primary)
                                   
            Text("\(vm.dayNumber(for: date))")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(vm.dateTextColor(for: date))
                .frame(width: 40, height: 40)
                .background(
                Circle()
                .fill(vm.dateCircleColor(for: date))
                        )
                        }
                .frame(maxWidth: .infinity)
                }
            }
        HStack(spacing: 16) {
        VStack(spacing: 6) {
        Image(systemName: "flame.fill")
                .font(.system(size: 20))
                .foregroundColor(.orange)
                    
        Text(vm.formatDays(vm.learnedDays))
                .font(.system(size: 17, weight: .bold))
                    
        Text("Learned")
                .font(.system(size: 12))
                .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 96)
                .glassEffect(in:.rect(cornerRadius: 34))
               
                
                
        VStack(spacing: 6) {
        Image(systemName: "snowflake")
                .font(.system(size: 20))
                .foregroundColor(.cyan)
                    
        Text(vm.formatDays(vm.freezedDays))
                .font(.system(size: 17, weight: .bold))
                    
        Text("Freezed")
                .font(.system(size: 12))
                .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 96)
                .glassEffect(in: .rect(cornerRadius: 34))
            }
            
        Spacer()
    if vm.goalStatus == .active {
        Button(action: {vm.logLearned()}) {
        Text(vm.todayStatus == "learned" ? "Logged as Learned" : "Log as Learned")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(vm.todayStatus == "none" ? .white : .gray)
                .frame(width: 260, height: 260)
                .glassEffect(
                    .regular
                    .tint(vm.todayStatus == "none" ? .orange : .clear)
                    .interactive(),
                    in: .circle
                )
                }
        .disabled(vm.todayStatus != "none")
        
        Spacer()
            
        VStack(spacing: 12) {
        Button(action: {vm.logFreeze()}) {
        Text(vm.todayStatus == "freezed" || vm.freezedDays >= vm.maxFreezes ? "Freezed for a day" : "Freeze for a day")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(vm.isFreezeDisabled ? .secondary : .white)
                .frame(width: 260, height: 50)
                .glassEffect(
                   .regular
                   .tint(vm.isFreezeDisabled ? .clear : .cyan)
                   .interactive(),
                   in: .capsule
                )
                }
        .disabled(vm.isFreezeDisabled)
                
        Text("\(vm.freezedDays) out of \(vm.maxFreezes) Freezes used")
                .font(.system(size: 13))
                .foregroundColor(.secondary)
               }
    } else if vm.goalStatus == .completed {
        VStack(spacing: 14) {
        Image(systemName: "hands.clap.fill")
                    .font(.system(size: 54))
                    .foregroundColor(.orange)
                    .padding(.bottom, 6)
                        
        Text("Will done!")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.primary)
                        
        Text("Ready for your next goal?")
                    .font(.system(size: 15))
                    .foregroundColor(.secondary)
                    }
                    
        Spacer()
                    
        Button(action: {isPresented = false}) {
            HStack(spacing: 8) {
                Image(systemName: "pencil.and.outline")
                Text("Set a goal")}
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                    .frame(width: 190, height: 50)
                    .glassEffect(
                        .regular
                        .tint(.orange)
                        .interactive(),
                        in: .capsule)
                    }
                    .padding(.bottom, 24)
                    
                } else {
                    VStack(spacing: 14) {
                        Image(systemName: "xmark.seal")
                            .font(.system(size: 54))
                            .foregroundColor(.orange)
                            .padding(.bottom, 6)
                        
                        Text("You didn't reach your goal this time.")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.center)
                        
                        Text("Want to set another goal?")
                            .font(.system(size: 15))
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Button(action: {isPresented = false}) {
                        HStack(spacing: 8) {
                            Image(systemName: "pencil.and.outline")
                            Text("Set a goal")
                        }
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                        .frame(width: 190, height: 50)
                        .glassEffect(
                            .regular
                            .tint(.orange)
                            .interactive(),
                            in: .capsule)
                    }
                    .padding(.bottom, 24)
                }
              
       //for testing
            HStack {
            Text("Day \(vm.currentDayIndex) of \(vm.goalDays)")
                .font(.caption2)
                .foregroundColor(.secondary)
        Spacer()
                    
                    
            Button("Simulate +1 Day →") {vm.simulateNextDay()}
                .font(.caption2.bold())
                .foregroundColor(.orange)
                }
                .padding(.top, 4)
            }
            .padding(.horizontal, 20)
            .navigationBarBackButtonHidden(true)
            .navigationDestination(isPresented: $showFullCalendar) {
                AllActivitiesCalendarView(vm: vm)
            }
        
        
        
            .preferredColorScheme(.dark)
        }
    }

struct AllActivitiesCalendarView: View {
    @ObservedObject var vm: LearningViewModel
    @Environment(\.dismiss) private var dismiss
    
    let weekDayHeaders = ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"]
    let columns = Array(repeating: GridItem(.flexible(), spacing: 0), count: 7)
    
    var body: some View {
        ZStack(alignment: .top) {
            
            ScrollViewReader { proxy in
            ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 28) {
                        
            Spacer().frame(height: 54)
                        
            ForEach(vm.calendarMonths, id: \.self) { monthStart in
            VStack(alignment: .leading, spacing: 16) {
                                
                              
            Text(vm.monthYearTitle(for: monthStart))
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(.primary)
                    .padding(.horizontal, 4)
                                
                               
            HStack(spacing: 0) {
            ForEach(weekDayHeaders, id: \.self) { day in
            Text(day)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
                    }
                    }
                                
    let daysGrid = vm.daysInMonthGrid(for: monthStart)
            LazyVGrid(columns: columns, spacing: 14) {
            ForEach(0..<daysGrid.count, id: \.self) { index in
                    if let date = daysGrid[index] {
                    Text("\(vm.dayNumber(for: date))")
                            .font(.system(size: 17, weight: .medium))
                            .foregroundColor(vm.dateTextColor(for: date))
                            .frame(width: 40, height: 40)
                            .background(
                            Circle()
                            .fill(vm.dateCircleColor(for: date))
                            )
                            } else {
                            Color.clear
                            .frame(width: 40, height: 40)
                                        }
                                    }
                                }
                                
            Divider()
            .background(Color.primary.opacity(0.50))
            .padding(.top, 8)
            }
            .id(Calendar.current.component(.month, from: monthStart))
            }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 40)
                }
            .onAppear {
        let currentMonth = Calendar.current.component(.month, from: vm.currentDate)
                    proxy.scrollTo(currentMonth, anchor: .top)
                }
            }
            
            HStack {
                Button(action: {dismiss()}) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.primary)
                    .frame(width: 40, height: 40)
                    .glassEffect(.regular.interactive(), in: .circle)
                }
            Spacer()
                
            Text("Activities")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.primary)
                
            Spacer()
                Color.clear
                .frame(width: 40, height: 40)
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
        }
        .navigationBarBackButtonHidden(true)
        .preferredColorScheme(.dark)
    }
}


struct UpdateGoalView: View {
    @ObservedObject var vm: LearningViewModel
    @Binding var isPresented: Bool
    
    @State private var tempTopic: String = ""
    @State private var tempDuration: String = "Week"
    @State private var showAlert = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 32) {
            
            HStack {
                Button(action: {isPresented = false}) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
                    .frame(width: 40, height: 40)
                    .glassEffect(.regular.interactive(), in: .circle)
                }
                
        Spacer()
                
            Text("Learning Goal")
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(.white)
                
        Spacer()
                
            Button(action: {showAlert = true}) {
            Image(systemName: "checkmark")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)
                .frame(width: 40, height: 40)
                .glassEffect(
                    .regular
                    .tint(.orange)
                    .interactive(),
                    in: .circle)
                }
            }
            .padding(.top, 8)
            
            VStack(alignment: .leading, spacing: 14) {
                Text("I want to learn")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                
                TextField("Swift", text: $tempTopic)
                    .font(.system(size: 16))
                    .tint(.orange)
                    .foregroundColor(.white)
                
        Divider()
            .background(Color.white.opacity(0.50))
            }
        .padding(.top, 20)
            
            VStack(alignment: .leading, spacing: 14) {
                Text("I want to learn it in a")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                
            HStack(spacing: 12) {
                ForEach(vm.durations, id: \.self) { duration in
                        let isSelected = (tempDuration == duration)
                        
                Button(action: {
                            tempDuration = duration
                        }) {
                Text(duration)
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(isSelected ? .white : .secondary)
                    .padding(.horizontal, 24)
                    .frame(height: 44)
                    .glassEffect(
                    .regular
                    .tint(isSelected ? .orange : .clear)
                    .interactive(),
                    in: .capsule)
                        }
                    }
                }
            }
            
            Spacer()
        }
        .padding(.horizontal, 24)
        .navigationBarBackButtonHidden(true)
        .preferredColorScheme(.dark)
        .onAppear {
            tempTopic = vm.topic
            tempDuration = vm.selectedDuration
        }
        .alert("Update goal", isPresented: $showAlert) {
            Button("Dismiss", role: .cancel) {
            }
            Button("Update", role: .destructive) {
                vm.topic = tempTopic
                vm.selectedDuration = tempDuration
                vm.startNewGoal()
                isPresented = false
            }
        } message: {
            Text("If you update now, your streak will start over.")
        }
    }
}

    #Preview {
        OnboardingView()
    }

