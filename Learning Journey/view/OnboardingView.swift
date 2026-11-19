import SwiftUI
import Combine

struct OnboardingView: View {
    @StateObject var vm = LearningViewModel()
    @State private var showActivityPage = false
    @Environment(ThemeViewModel.self) var themeVM
    
    var body: some View {
        @Bindable var bindableVM = themeVM
        NavigationStack {
            VStack(alignment: .leading, spacing: 32) {
                
        HStack {
        Spacer()
        Image(systemName: "flame.fill")
                .font(.system(size: 36))
                .foregroundColor(themeVM.primaryColor)
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
                .tint(themeVM.primaryColor)
                    
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
        Spacer()
        VStack(spacing: 14) {
       // NavigationLink(destination: ActivityView(vm: vm)) {
            Button(action: {vm.startNewGoal()
                showActivityPage = true}) {
                Text("Start Learning")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white)
                .padding(.horizontal, 44)
                .padding(.vertical, 14)
                }
                .glassEffect(
                    .regular
                    .tint(themeVM.primaryColor)
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
    }
    }

#Preview {
    OnboardingView(vm: LearningViewModel())
        .environment(ThemeViewModel.shared)
}
