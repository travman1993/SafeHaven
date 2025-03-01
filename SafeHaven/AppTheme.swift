import SwiftUI

struct AppTheme {
    static let primary = Color(hex: "6A89CC")
    static let secondary = Color(hex: "41B3A3")
    static let accent = Color(hex: "E8505B")
    static let background = Color(hex: "F5F7FA")

    static let textPrimary = Color(hex: "2D3748")
    static let textSecondary = Color(hex: "718096")
    static let textLight = Color.white

    struct ButtonStyle: ViewModifier {
        var bgColor: Color
        var isLarge: Bool = false
        
        func body(content: Content) -> some View {
            content
                .font(.system(size: isLarge ? 18 : 16, weight: .semibold, design: .rounded))
                .padding(.vertical, isLarge ? 18 : 14)
                .padding(.horizontal, isLarge ? 32 : 24)
                .frame(maxWidth: .infinity)
                .background(bgColor)
                .foregroundColor(.white)
                .cornerRadius(12)
                .shadow(color: bgColor.opacity(0.3), radius: 8, x: 0, y: 4)
        }
    }
}

extension View {
    func primaryButton(isLarge: Bool = false) -> some View {
        self.modifier(AppTheme.ButtonStyle(bgColor: AppTheme.primary, isLarge: isLarge))
    }
}
