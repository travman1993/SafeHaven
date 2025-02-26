import SwiftUI

struct AppTheme {
    // Main colors
    static let primary = Color(hex: "6A89CC")
    static let secondary = Color(hex: "41B3A3")
    static let accent = Color(hex: "E8505B")
    static let background = Color(hex: "F5F7FA")
    
    // Text colors
    static let textPrimary = Color(hex: "2D3748")
    static let textSecondary = Color(hex: "718096")
    static let textLight = Color.white
    
    // Component styles
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
    
    struct CardStyle: ViewModifier {
        func body(content: Content) -> some View {
            content
                .padding()
                .background(Color.white)
                .cornerRadius(16)
                .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
        }
    }
    
    struct SectionTitleStyle: ViewModifier {
        func body(content: Content) -> some View {
            content
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 8)
        }
    }
}

// Convenience extensions
extension View {
    func primaryButton(isLarge: Bool = false) -> some View {
        self.modifier(AppTheme.ButtonStyle(bgColor: AppTheme.primary, isLarge: isLarge))
    }
    
    func secondaryButton(isLarge: Bool = false) -> some View {
        self.modifier(AppTheme.ButtonStyle(bgColor: AppTheme.secondary, isLarge: isLarge))
    }
    
    func accentButton(isLarge: Bool = false) -> some View {
        self.modifier(AppTheme.ButtonStyle(bgColor: AppTheme.accent, isLarge: isLarge))
    }
    
    func cardStyle() -> some View {
        self.modifier(AppTheme.CardStyle())
    }
    
    func sectionTitle() -> some View {
        self.modifier(AppTheme.SectionTitleStyle())
    }
}
