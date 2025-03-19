//
//  ResponsiveHelpers.swift
//  SafeHaven
//
//  Created by Travis Rodriguez on 3/19/25.
//

import SwiftUI

// Responsive sizing and layout utilities
struct ResponsiveLayout {
    // Determine device type
    static var isIPad: Bool {
        return UIDevice.current.userInterfaceIdiom == .pad
    }
    
    // Adaptive font sizing
    static func fontSize(_ baseSize: CGFloat) -> CGFloat {
        let screenWidth = UIScreen.main.bounds.width
        return isIPad ? baseSize * 1.2 : baseSize * (screenWidth / 375.0)
    }
    
    // Adaptive padding
    static func padding(_ basePadding: CGFloat = 16) -> CGFloat {
        return isIPad ? basePadding * 1.5 : basePadding
    }
    
    // Responsive column count for grid layouts
    static func gridColumns() -> [GridItem] {
        return isIPad
            ? Array(repeating: GridItem(.flexible()), count: 3)
            : [GridItem(.flexible()), GridItem(.flexible())]
    }
}

// Custom preference key for device size tracking
struct DeviceSizeKey: PreferenceKey {
    static var defaultValue: CGSize = .zero
    
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}

// Extensible view modifier for responsive layouts
struct ResponsiveViewModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(ResponsiveLayout.padding())
            .background(
                GeometryReader { geometry in
                    Color.clear.preference(
                        key: DeviceSizeKey.self,
                        value: geometry.size
                    )
                }
            )
    }
}

// Extension to make responsive modifier easily applicable
extension View {
    func responsive() -> some View {
        self.modifier(ResponsiveViewModifier())
    }
}
