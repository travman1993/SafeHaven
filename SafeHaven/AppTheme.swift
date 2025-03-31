import SwiftUI

struct AppTheme {
    // Original properties
    static var primary = Color(hex: "4A76D4")  // More vibrant blue
    static var secondary = Color(hex: "36A599")  // Richer teal
    static var accent = Color(hex: "FF5062")  // Brighter accent
    static var background = Color(hex: "F5F7FA")  // Slightly cooler background

    static var textPrimary = Color(hex: "2D3748")
    static var textSecondary = Color(hex: "718096")
    static var textLight = Color.white
    
    // Updated adaptive properties to use @Environment colorScheme
    static var adaptiveBackground: Color {
        Color("backgroundAdaptive")
    }
    
    static var adaptiveTextPrimary: Color {
        Color("textPrimaryAdaptive")
    }
    
    static var adaptiveTextSecondary: Color {
        Color("textSecondaryAdaptive")
    }
    
    static var adaptivePrimary: Color {
        Color("primaryAdaptive")
    }
    
    static var adaptiveSecondary: Color {
        Color("secondaryAdaptive")
    }
    
    static var adaptiveAccent: Color {
        Color("accentAdaptive")
    }
    
    static var adaptiveCardBackground: Color {
        Color("cardBackgroundAdaptive")
    }
    
    // Original methods
    static func responsiveFont(baseSize: CGFloat) -> CGFloat {
        let screenWidth = UIScreen.main.bounds.width
        let isPad = UIDevice.current.userInterfaceIdiom == .pad
        
        if isPad {
            return baseSize * 1.2 // Slightly larger on iPad
        } else {
            // Scale font size based on iPhone screen width
            return baseSize * (screenWidth / 375.0)
        }
    }
    
    static func responsivePadding() -> CGFloat {
        return UIDevice.current.userInterfaceIdiom == .pad ? 24 : 16
    }
    
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

// Helper extension to use adaptive colors based on color scheme
extension View {
    func adaptiveBackground() -> some View {
        self.background(AppTheme.adaptiveBackground)
    }
    
    func adaptiveCardBackground() -> some View {
        self.background(AppTheme.adaptiveCardBackground)
    }
    
    func adaptiveTextColor(_ isPrimary: Bool = true) -> some View {
        self.foregroundColor(isPrimary ? AppTheme.adaptiveTextPrimary : AppTheme.adaptiveTextSecondary)
    }
}
