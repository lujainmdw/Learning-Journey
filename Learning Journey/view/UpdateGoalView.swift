import SwiftUI
import Combine

struct UpdateGoalView: View {
    @ObservedObject var vm: LearningViewModel
    @Binding var isPresented: Bool
    @Environment(ThemeViewModel.self) var themeVM
    
    @State private var tempTopic: String = ""
    @State private var tempDuration: String = "Week"
    @State private var showAlert = false
    
    var body: some View {
        @Bindable var bindableVM = themeVM
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
                    .foregroundColor(.primary)
                
                Spacer()
                
                Button(action: {showAlert = true}) {
                    Image(systemName: "checkmark")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 40, height: 40)
                        .glassEffect(
                            .regular
                                .tint(themeVM.primaryColor)
                                .interactive(),
                            in: .circle)
                }
            }
            .padding(.top, 8)
            
            VStack(alignment: .leading, spacing: 14) {
                Text("I want to learn")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.primary)
                
                TextField("Swift", text: $tempTopic)
                    .font(.system(size: 16))
                    .tint(themeVM.primaryColor)
                    .foregroundColor(.primary)
                
                Divider()
                    .background(Color.primary.opacity(0.50))
            }
            .padding(.top, 20)
            
            VStack(alignment: .leading, spacing: 14) {
                Text("I want to learn it in a")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.primary)
                
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
                                        .tint(isSelected ? themeVM.primaryColor : .clear)
                                        .interactive(),
                                    in: .capsule)
                        }
                    }
                }
                VStack(alignment: .leading, spacing: 14) {
                    ColorPicker(
                        "I want the theme to be",
                        selection: $bindableVM.theme.primaryColor,
                        supportsOpacity: false
                    )
                    .font(.system(size: 16, weight: .medium))
                }
            }
            
            Spacer()
        }
        .padding(.horizontal, 24)
        .navigationBarBackButtonHidden(true)
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
    UpdateGoalView(vm: LearningViewModel(), isPresented: .constant(true))
        .environment(ThemeViewModel.shared)
}
