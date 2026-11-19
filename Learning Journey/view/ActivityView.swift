import SwiftUI
import Combine


struct ActivityView: View {
    @ObservedObject var vm: LearningViewModel
    @Binding var isPresented: Bool
    
    @Environment(ThemeViewModel.self) var themeVM
    
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
                .foregroundColor(themeVM.primaryColor)
                    
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
                    .tint(vm.todayStatus == "none" ? themeVM.primaryColor : .clear)
                    .interactive(),
                    in: .circle
                )
                }
        .disabled(vm.todayStatus == "freezed")
        
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
                    .foregroundColor(themeVM.primaryColor)
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
                        .tint(themeVM.primaryColor)
                        .interactive(),
                        in: .capsule)
                    }
                    .padding(.bottom, 24)
                    
                } else {
                    VStack(spacing: 14) {
                        Image(systemName: "xmark.seal")
                            .font(.system(size: 54))
                            .foregroundColor(themeVM.primaryColor)
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
                            .tint(themeVM.primaryColor)
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
                .foregroundColor(themeVM.primaryColor)
                }
                .padding(.top, 4)
            }
            .padding(.horizontal, 20)
            .navigationBarBackButtonHidden(true)
            .navigationDestination(isPresented: $showFullCalendar) {
                AllActivitiesCalendarView(vm: vm)
            }
        
        
        
        }
    }
#Preview {
    ActivityView(vm: LearningViewModel(), isPresented: .constant(true))
        .environment(ThemeViewModel.shared)
}
