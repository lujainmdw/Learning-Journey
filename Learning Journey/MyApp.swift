import SwiftUI

@main
struct MyApp: App {
    @State private var themeVM = ThemeViewModel.shared


    var body: some Scene {
        WindowGroup {
            OnboardingView()
                .environment(themeVM)
        }
    }
}


