import SwiftUI
import Combine
import Observation


@Observable
final class ThemeViewModel {
    static let shared = ThemeViewModel()
    private static let storageKey = "saved_theme_color_rgba"
    
    var theme: AppTheme {
        didSet {
            saveColor(theme.primaryColor)
        }
    }
    
    init() {
        if let savedColor = Self.loadColor() {
            self.theme = AppTheme(primaryColor: savedColor)
        } else {
            self.theme = .defaultTheme
        }
    }
        
    var primaryColor: Color {
        theme.primaryColor
    }
    
    var surfaceBackground: Color {
        theme.primaryColor.opacity(0.18)
    }
    
    var borderColor: Color {
        theme.primaryColor.opacity(0.40)
    }
        
    func selectPreset(_ color: Color) {
        withAnimation(.easeInOut(duration: 0.2)) {
            theme.primaryColor = color
        }
    }
    
    func resetToDefault() {
        withAnimation(.easeInOut(duration: 0.2)) {
            theme = .defaultTheme
        }
    }
        
    private func saveColor(_ color: Color) {
        let uiColor = UIColor(color)
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        
        if uiColor.getRed(&r, green: &g, blue: &b, alpha: &a) {
            UserDefaults.standard.set(
                [Double(r), Double(g), Double(b), Double(a)],
                forKey: Self.storageKey
            )
        }
    }
    
    private static func loadColor() -> Color? {
        guard let components = UserDefaults.standard.array(forKey: storageKey) as? [Double],
              components.count == 4 else {
            return nil
        }
        return Color(
            red: components[0],
            green: components[1],
            blue: components[2],
            opacity: components[3]
        )
    }
}
