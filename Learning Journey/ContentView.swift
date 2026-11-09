import SwiftUI

struct OnboardingView: View {
    @State private var topic: String = ""
    @State private var selectedDuration: String = "Week"
    
    let durations = ["Week", "Month", "Year"]
    var maxFreezes: Int {
        if selectedDuration == "Week" {
            return 2
        } else if selectedDuration == "Month" {
            return 8
        } else {
            return 96
        }
    }
    var body: some View {
        VStack(alignment: .leading, spacing: 32) {

            HStack {
                Spacer()
                Image(systemName: "flame.fill")
                    .font(.system(size: 36))
                    .foregroundColor(.orange)
                Spacer()
            }
            
            
            .padding(.top,44 )
            .padding(.bottom, 40)
            
          
            VStack (alignment: .leading) {
                Text("Hello **Learner** ")
                    .fontWeight(.regular)
                    .font(.system(size: 34))
                
                Text("This app will help you learn everyday!")
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
            }
            
            
            VStack(alignment: .leading, spacing: 14) {
                Text("I want to learn")
                    .font(.system(size: 16, weight: .medium))
                TextField("Swift", text: $topic)
                    .font(.system(size: 16))
                    .tint(.orange)
                Divider()
            }
            
          
            VStack(alignment: .leading, spacing: 14) {
                Text("I want to learn it in a")
                    .font(.system(size: 16, weight: .medium))
                
                HStack(spacing: 12) {
                    ForEach(durations, id: \.self) { duration in
                        let isSelected = (selectedDuration == duration)
                        Button(action: {
                            selectedDuration = duration
                        }) {
                            Text(duration)
                                .font(.system(size: 17, weight: .medium))
                                .foregroundColor(isSelected ? .white : .secondary)
                                .padding(.horizontal, 18)
                                .padding(.vertical, 14)
                                .background(
                                    ZStack {
                                        if isSelected {
                                           Color.orange.opacity(0.85)
                    
                                        } else {
                                            Color.white.opacity(0.08)
                                        }
                                    }
                                )
                                .clipShape(Capsule())
                                .overlay(
                                    Capsule()
                                        .stroke(Color.white.opacity(isSelected ? 0.35 : 0.1), lineWidth: 1)
                                )
                        }
                    }
                }
            }
            
            Spacer()
            
            
            
            VStack(spacing: 14) {
                    NavigationLink(destination: ActivityView(maxFreezes: maxFreezes)) {
                        Text("Start Learning")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                            .padding(.horizontal, 44)
                            .padding(.vertical, 14)
                            .background(
                                Color.orange.opacity(0.85))
                            .clipShape(Capsule())
                            .overlay(Capsule()
                                .stroke(Color.white.opacity(0.35), lineWidth: 1))
                    }
                    
                    Text("You can edit your desire later")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.bottom, 20)

        }
        .padding(.horizontal, 24)
        .preferredColorScheme(.dark)
    }
}


struct ActivityView: View {
    // Receives 2, 8, or 96 from Page 1 (defaults to 2 if previewed directly)
    var maxFreezes: Int = 2
    
    // Memory Boxes
    @State private var learnedDays: Int = 4
    @State private var freezedDays: Int = 0
    @State private var todayStatus: String = "none" // "none", "learned", or "freezed"
    
    // Calendar data matching your design
    let weekDays = [
        ("S", 20), ("M", 21), ("T", 22), ("W", 23), ("T", 24), ("F", 25), ("S", 26)
    ]
    
    // Rule: "1 day" vs "4 days"
    func formatDays(_ count: Int) -> String {
        return count == 1 ? "1 day" : "\(count) days"
    }
    
    // Rule: Freeze button is disabled if all freezes are used OR today is already logged
    var isFreezeDisabled: Bool {
        return (freezedDays >= maxFreezes) || (todayStatus != "none")
    }
    
    var body: some View {
        VStack(spacing: 24) {
            
            // 1. TOP HEADER ("Activity" + 2 Top-Right Icon Buttons)
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Activity")
                        .font(.system(size: 34, weight: .bold))
                    
                    Text("Thursday, 24 October")
                        .font(.system(size: 15))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                HStack(spacing: 12) {
                    // Calendar Icon Button
                    Button(action: {}) {
                        Image(systemName: "calendar")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 40, height: 40)
                            .background(Color.white.opacity(0.1))
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.white.opacity(0.15), lineWidth: 1))
                    }
                    
                    // Edit Goal Icon Button
                    Button(action: {}) {
                        Image(systemName: "pencil.and.outline")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 40, height: 40)
                            .background(Color.white.opacity(0.1))
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.white.opacity(0.15), lineWidth: 1))
                    }
                }
            }
            .padding(.top, 8)
            
            // 2. WEEK CALENDAR ROW (20 to 26)
            HStack(spacing: 0) {
                ForEach(weekDays, id: \.1) { day in
                    VStack(spacing: 10) {
                        Text(day.0)
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.white)
                        
                        // Date Number Circle
                        Text("\(day.1)")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(dateTextColor(for: day.1))
                            .frame(width: 40, height: 40)
                            .background(
                                Circle()
                                    .fill(dateCircleColor(for: day.1))
                            )
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            
            // 3. SCORE CARDS ("4 days Learned" & "0 days Freezed")
            HStack(spacing: 16) {
                // Learned Card
                VStack(spacing: 6) {
                    Image(systemName: "flame.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.orange)
                    
                    Text(formatDays(learnedDays))
                        .font(.system(size: 17, weight: .bold))
                    
                    Text("Learned")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 96)
                .background(
                    LinearGradient(
                        colors: [Color.white.opacity(0.12), Color.white.opacity(0.05)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .stroke(Color.white.opacity(0.15), lineWidth: 1)
                )
                
                // Freezed Card
                VStack(spacing: 6) {
                    Image(systemName: "snowflake")
                        .font(.system(size: 20))
                        .foregroundColor(.cyan)
                    
                    Text(formatDays(freezedDays))
                        .font(.system(size: 17, weight: .bold))
                    
                    Text("Freezed")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 96)
                .background(
                    LinearGradient(
                        colors: [Color.white.opacity(0.12), Color.white.opacity(0.05)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .stroke(Color.white.opacity(0.15), lineWidth: 1)
                )
            }
            
            Spacer()
            
            // 4. BIG CENTER BUTTON ("Log as Learned" -> "Logged as Learned")
            Button(action: {
                learnedDays += 1
                todayStatus = "learned"
            }) {
                Text(todayStatus == "learned" ? "Logged as Learned" : "Log as Learned")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(todayStatus == "none" ? .white : .gray)
                    .frame(width: 260, height: 260)
                    .background(
                        Circle()
                            .fill(todayStatus == "none" ? Color.orange : Color.white.opacity(0.08))
                    )
                    .overlay(
                        Circle()
                            .stroke(Color.white.opacity(todayStatus == "none" ? 0.25 : 0.12), lineWidth: 1.5)
                    )
            }
            .disabled(todayStatus != "none")
            
            Spacer()
            
            // 5. BOTTOM FREEZE BUTTON & COUNTER
            VStack(spacing: 12) {
                Button(action: {
                    freezedDays += 1
                    todayStatus = "freezed"
                }) {
                    Text(todayStatus == "freezed" || freezedDays >= maxFreezes ? "Freezed for a day" : "Freeze for a day")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(isFreezeDisabled ? .secondary : .white)
                        .frame(width: 260, height: 50)
                        .background(
                            ZStack {
                                if isFreezeDisabled {
                                    Color.white.opacity(0.08)
                                } else {
                                    LinearGradient(
                                        colors: [Color.cyan.opacity(0.8), Color.cyan],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                }
                            }
                        )
                        .clipShape(Capsule())
                        .overlay(
                            Capsule()
                                .stroke(Color.white.opacity(isFreezeDisabled ? 0.1 : 0.4), lineWidth: 1)
                        )
                }
                .disabled(isFreezeDisabled)
                
                Text("\(freezedDays) out of \(maxFreezes) Freezes used")
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
            }
            .padding(.bottom, 12)
        }
        .padding(.horizontal, 20)
        .background(Color.black.ignoresSafeArea())
        .navigationBarBackButtonHidden(true) // Hides the default blue "< Back" button to match your design
        .preferredColorScheme(.dark)
    }
    
    // MARK: - Helper Rules for Calendar Circle Colors
    func dateCircleColor(for dayNumber: Int) -> Color {
        if dayNumber < 24 {
            // Past learned days (20, 21, 22, 23): Dark translucent orange
            return Color.orange.opacity(0.18)
        } else if dayNumber == 24 {
            // Today (24): Solid orange before logging, dark orange after logging, dark cyan if freezed!
            if todayStatus == "none" {
                return Color.orange
            } else if todayStatus == "learned" {
                return Color.orange.opacity(0.18)
            } else {
                return Color.cyan.opacity(0.18)
            }
        } else {
            // Future days (25, 26): No circle background
            return Color.clear
        }
    }
    
    func dateTextColor(for dayNumber: Int) -> Color {
        if dayNumber < 24 {
            return .orange
        } else if dayNumber == 24 {
            if todayStatus == "none" {
                return .white
            } else if todayStatus == "learned" {
                return .orange
            } else {
                return .cyan
            }
        } else {
            return .white
        }
    }
}


#Preview {
    OnboardingView()
}
