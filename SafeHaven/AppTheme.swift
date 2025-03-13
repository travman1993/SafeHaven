import SwiftUI

struct AppTheme {
    // More prominent primary blue color
        static let primary = Color(hex: "4A76D4")  // More vibrant blue
        static let secondary = Color(hex: "36A599")  // Richer teal
        static let accent = Color(hex: "FF5062")  // Brighter accent
        static let background = Color(hex: "F0F2F6")  // Slightly cooler background

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
