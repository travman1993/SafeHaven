import Foundation
import SwiftUI
import WeatherKit
import CoreLocation

// Reusable components that can be used across the app

struct GradientBackground: View {
    var body: some View {
        LinearGradient(
            gradient: Gradient(colors: [Color(hex: "6A89CC"), Color(hex: "41B3A3")]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
}

struct ActionButton: View {
    var icon: String
    var title: String
    var subtitle: String
    var color: Color
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(.white)
                    .frame(width: 44, height: 44)
                    .background(color)
                    .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color(hex: "2D3748"))
                    
                    Text(subtitle)
                        .font(.system(size: 14))
                        .foregroundColor(Color(hex: "718096"))
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(Color(hex: "A0AEC0"))
            }
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        }
    }
}

struct InfoCard: View {
    var title: String
    var content: String
    var icon: String
    var color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(.white)
                    .frame(width: 36, height: 36)
                    .background(color)
                    .clipShape(Circle())
                
                Text(title)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(Color(hex: "2D3748"))
            }
            
            Text(content)
                .font(.system(size: 14))
                .foregroundColor(Color(hex: "718096"))
                .lineSpacing(4)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

// In ResourcesView.swift or SharedComponents.swift
struct SearchBar: View {
    @Binding var text: String
    var placeholder: String
    var onSubmit: (() -> Void)? = nil
    @FocusState private var isInputFocused: Bool
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(text.isEmpty ? Color(hex: "A0AEC0") : Color(hex: "6A89CC"))
            
            TextField(placeholder, text: $text)
                .font(.system(size: 16))
                .focused($isInputFocused)
                .submitLabel(.search)
                .onSubmit {
                    print("Search submitted: \(text)")
                    isInputFocused = false
                    onSubmit?() // This is where the search function is called
                }
            
            // Add a dedicated search button for clarity
            if !text.isEmpty {
                Button(action: {
                    isInputFocused = false
                    onSubmit?() // Explicitly call search function
                }) {
                    Text("Search")
                        .foregroundColor(Color(hex: "6A89CC"))
                        .padding(.horizontal, 10)
                }
            }
            
            // Clear button
            if !text.isEmpty {
                Button(action: {
                    text = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(Color(hex: "A0AEC0"))
                }
            }
        }
        .padding(12)
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

struct CategoryButton: View {
    var title: String
    var isSelected: Bool
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(isSelected ? Color(hex: "6A89CC") : Color.white)
                )
                .foregroundColor(isSelected ? .white : Color(hex: "6A89CC"))
                .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
        }
    }
}

struct ContactInfoRow: View {
    var icon: String
    var title: String
    var content: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(Color(hex: "6A89CC"))
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 14))
                    .foregroundColor(Color(hex: "718096"))
                
                Text(content)
                    .font(.system(size: 16))
                    .foregroundColor(Color(hex: "2D3748"))
            }
        }
        .padding(.vertical, 8)
    }
}
