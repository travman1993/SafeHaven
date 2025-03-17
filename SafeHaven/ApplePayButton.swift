//
//  ApplePayButton.swift
//  SafeHaven
//
//  Created by Travis Rodriguez on 3/17/25.
//
import SwiftUI
import PassKit

// Apple Pay button
struct ApplePayButton: View {
    var type: PKPaymentButtonType
    var style: PKPaymentButtonStyle
    var action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            action()
        }) {
            ZStack {
                PKPaymentButton(type, style)
                    .frame(minWidth: 100, maxWidth: .infinity)
                    .frame(height: 45)
                    .opacity(0.01) // Make the actual button invisible but still clickable
                
                // Custom styling to match Apple Pay button
                HStack {
                    if style == .black {
                        Image("apple-pay-logo")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 20)
                            .foregroundColor(.white)
                    } else {
                        Image("apple-pay-logo-black")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 20)
                            .foregroundColor(.black)
                    }
                }
                .padding()
                .frame(minWidth: 100, maxWidth: .infinity)
                .frame(height: 45)
                .background(style == .black ? Color.black : Color.white)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(style == .black ? Color.clear : Color.black, lineWidth: 1)
                )
                .scaleEffect(isPressed ? 0.98 : 1.0)
            }
        }
        .buttonStyle(PlainButtonStyle())
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    withAnimation(.easeInOut(duration: 0.1)) {
                        isPressed = true
                    }
                }
                .onEnded { _ in
                    withAnimation(.easeInOut(duration: 0.1)) {
                        isPressed = false
                    }
                }
        )
    }
}
