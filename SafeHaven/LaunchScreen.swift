//
//  LaunchScreen.swift
//  SafeHaven
//
//  Created by Travis Rodriguez on 3/16/25.
//
// LaunchScreen.swift
import SwiftUI

struct LaunchScreen: View {
    var body: some View {
        ZStack {
            Color(hex: "F0F2F6")
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Shield logo similar to login screen
                ZStack {
                    Circle()
                        .fill(LinearGradient(
                            gradient: Gradient(colors: [Color(hex: "5A89CC"), Color(hex: "41B3A3")]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                        .frame(width: 130, height: 130)
                        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
                    
                    Image(systemName: "shield.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 80, height: 80)
                        .foregroundColor(.white.opacity(0.9))
                    
                    Image(systemName: "house.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 40, height: 40)
                        .foregroundColor(.white)
                    
                    Image(systemName: "heart.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 20, height: 20)
                        .foregroundColor(.white)
                        .offset(y: 10)
                }
                
                Text("SafeHaven")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundColor(AppTheme.textPrimary)
                
                Text("Secure Your Safety")
                    .font(.system(size: 18, weight: .medium, design: .rounded))
                    .foregroundColor(AppTheme.textSecondary)
            }
        }
    }
}
