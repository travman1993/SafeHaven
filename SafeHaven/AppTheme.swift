import SwiftUI

struct AppTheme {
    // Original properties
    static var primary = Color(hex: "4A76D4")  // More vibrant blue
    static var secondary = Color(hex: "36A599")  // Richer teal
    static var accent = Color(hex: "FF5062")  // Brighter accent
    static var background = Color(hex: "F0F2F6")  // Slightly cooler background

    static var textPrimary = Color(hex: "2D3748")
    static var textSecondary = Color(hex: "718096")
    static var textLight = Color.white
    
    // New adaptive properties
    static func adaptiveColor(light: String, dark: String) -> Color {
        let isDarkMode = UITraitCollection.current.userInterfaceStyle == .dark
        return isDarkMode ? Color(hex: dark) : Color(hex: light)
    }
    
    static var adaptiveBackground: Color {
        return adaptiveColor(light: "F0F2F6", dark: "1A202C")
    }
    
    static var adaptiveTextPrimary: Color {
        return adaptiveColor(light: "2D3748", dark: "F7FAFC")
    }
    
    static var adaptiveTextSecondary: Color {
        return adaptiveColor(light: "718096", dark: "CBD5E0")
    }
    
    static var adaptivePrimary: Color {
        return adaptiveColor(light: "4A76D4", dark: "5A85E0")
    }
    
    static var adaptiveSecondary: Color {
        return adaptiveColor(light: "36A599", dark: "3CBFB0")
    }
    
    static var adaptiveAccent: Color {
        return adaptiveColor(light: "FF5062", dark: "FF6B7D")
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

// Helper method to determine if the device is in dark mode
extension View {
    func isDarkMode() -> Bool {
        @Environment(\.colorScheme) var colorScheme
        return colorScheme == .dark
    }
    
    // New modifier to apply adaptive styling
    func adaptiveBackground() -> some View {
        self.background(AppTheme.adaptiveBackground)
    }
    
    func adaptiveTextColor(_ isPrimary: Bool = true) -> some View {
        self.foregroundColor(isPrimary ? AppTheme.adaptiveTextPrimary : AppTheme.adaptiveTextSecondary)
    }
}
