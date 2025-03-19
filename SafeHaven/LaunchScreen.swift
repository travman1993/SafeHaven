//
//  LaunchScreen.swift
//  SafeHaven
//
//  Created by Travis Rodriguez on 3/16/25.
import SwiftUI

struct LaunchScreen: View {
    var body: some View {
        ZStack {
            Color(hex: "F0F2F6")
                .ignoresSafeArea()
            
            VStack(spacing: ResponsiveLayout.padding(20)) {
                // Shield logo similar to login screen
                ZStack {
                    Circle()
                        .fill(LinearGradient(
                            gradient: Gradient(colors: [Color(hex: "5A89CC"), Color(hex: "41B3A3")]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                        .frame(
                            width: ResponsiveLayout.isIPad ? 180 : 130,
                            height: ResponsiveLayout.isIPad ? 180 : 130
                        )
                        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
                    
                    Image(systemName: "shield.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(
                            width: ResponsiveLayout.isIPad ? 100 : 80,
                            height: ResponsiveLayout.isIPad ? 100 : 80
                        )
                        .foregroundColor(.white.opacity(0.9))
                    
                    Image(systemName: "house.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(
                            width: ResponsiveLayout.isIPad ? 50 : 40,
                            height: ResponsiveLayout.isIPad ? 50 : 40
                        )
                        .foregroundColor(.white)
                    
                    Image(systemName: "heart.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(
                            width: ResponsiveLayout.isIPad ? 30 : 20,
                            height: ResponsiveLayout.isIPad ? 30 : 20
                        )
                        .foregroundColor(.white)
                        .offset(y: ResponsiveLayout.isIPad ? 15 : 10)
                }
                
                Text("SafeHaven")
                    .font(.system(
                        size: ResponsiveLayout.fontSize(36),
                        weight: .bold,
                        design: .rounded
                    ))
                    .foregroundColor(AppTheme.textPrimary)
                
                Text("Secure Your Safety")
                    .font(.system(
                        size: ResponsiveLayout.fontSize(18),
                        weight: .medium,
                        design: .rounded
                    ))
                    .foregroundColor(AppTheme.textSecondary)
            }
        }
    }
}
