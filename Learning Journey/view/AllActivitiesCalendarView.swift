import SwiftUI
import Combine

struct AllActivitiesCalendarView: View {
    @ObservedObject var vm: LearningViewModel
    @Environment(\.dismiss) private var dismiss
    
    @Environment(ThemeViewModel.self) var themeVM
    
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
    }
}

#Preview {
    AllActivitiesCalendarView(vm: LearningViewModel())
        .environment(ThemeViewModel.shared)
}

