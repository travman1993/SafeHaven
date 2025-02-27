//
//  MotivationView.swift
//  SafeHaven
//
//  Created by Travis Rodriguez on 2/27/25.
//
import SwiftUI
import UIKit

// Simple placeholder for NotificationSettingsView reference
struct NotificationSettingsViewRef: View {
    var body: some View {
        Text("Notifications Settings")
    }
}

// Simple placeholder for FavoritesView reference
struct FavoritesViewRef: View {
    var body: some View {
        Text("Favorites")
    }
}

struct MotivationView: View {
    // Sample quotes for the view
    let quotes = [
        (text: "The only way to do great work is to love what you do.", author: "Steve Jobs", tags: ["Work", "Passion"]),
        (text: "Life is 10% what happens to you and 90% how you react to it.", author: "Charles R. Swindoll", tags: ["Life", "Attitude"]),
        (text: "Believe you can and you're halfway there.", author: "Theodore Roosevelt", tags: ["Belief", "Motivation"]),
        (text: "It does not matter how slowly you go as long as you do not stop.", author: "Confucius", tags: ["Perseverance"])
    ]
    
    @State private var currentQuoteIndex = 0
    @State private var isAnimating = false
    @State private var showShareSheet = false
    @State private var favoriteQuotes: Set<Int> = []
    
    var currentQuote: (text: String, author: String, tags: [String]) {
        return quotes[currentQuoteIndex]
    }
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [Color(hex: "6A89CC"), Color(hex: "41B3A3")]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 30) {
                // Header
                Text("Daily Motivation")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                    .padding(.top, 30)
                
                Spacer()
                
                // Quote card
                VStack(spacing: 24) {
                    // Quote text
                    Text(currentQuote.text)
                        .font(.system(size: 14, weight: .medium, design: .serif))
                        .foregroundColor(Color(hex: "2D3748"))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                        .opacity(isAnimating ? 1 : 0)
                        .offset(y: isAnimating ? 0 : 20)
                        .animation(.easeInOut(duration: 0.5), value: isAnimating)
                    
                    // Author
                    Text("— \(currentQuote.author)")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color(hex: "6A89CC"))
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .padding(.trailing, 30)
                        .padding(.top, -10)
                        .opacity(isAnimating ? 1 : 0)
                        .animation(.easeInOut(duration: 0.5).delay(0.3), value: isAnimating)
                    
                    // Tags/Categories
                    HStack {
                        ForEach(currentQuote.tags, id: \.self) { tag in
                            Text(tag)
                                .font(.system(size: 12, weight: .medium))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(
                                    Capsule()
                                        .fill(Color(hex: "6A89CC").opacity(0.1))
                                )
                                .foregroundColor(Color(hex: "6A89CC"))
                        }
                    }
                    .padding(.top, 10)
                    .opacity(isAnimating ? 1 : 0)
                    .animation(.easeInOut(duration: 0.5).delay(0.5), value: isAnimating)
                }
                .padding(.vertical, 40)
                .padding(.horizontal, 20)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white)
                        .shadow(color: Color.black.opacity(0.1), radius: 15, x: 0, y: 10)
                )
                .padding(.horizontal, 30)
                .rotation3DEffect(
                    .degrees(isAnimating ? 0 : -5),
                    axis: (x: 1.0, y: 0.0, z: 0.0)
                )
                .animation(.easeInOut(duration: 0.7), value: isAnimating)
                
                Spacer()
                
                // Action buttons
                HStack(spacing: 30) {
                    // Share button
                    Button(action: {
                        showShareSheet = true
                    }) {
                        VStack {
                            Image(systemName: "square.and.arrow.up")
                                .font(.system(size: 20))
                                .foregroundColor(.white)
                                .frame(width: 50, height: 50)
                                .background(Color(hex: "E8505B"))
                                .clipShape(Circle())
                                .shadow(color: Color(hex: "E8505B").opacity(0.4), radius: 5, x: 0, y: 3)
                            
                            Text("Share")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white)
                        }
                    }
                    
                    // New quote button
                    Button(action: {
                        withAnimation {
                            isAnimating = false
                        }
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            currentQuoteIndex = (currentQuoteIndex + 1) % quotes.count
                            withAnimation {
                                isAnimating = true
                            }
                        }
                    }) {
                        VStack {
                            Image(systemName: "arrow.2.squarepath")
                                .font(.system(size: 20))
                                .foregroundColor(.white)
                                .frame(width: 70, height: 70)
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color(hex: "6A89CC"), Color(hex: "41B3A3")]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .clipShape(Circle())
                                .shadow(color: Color(hex: "6A89CC").opacity(0.4), radius: 8, x: 0, y: 4)
                            
                            Text("New Quote")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white)
                        }
                    }
                    
                    // Favorite button
                    Button(action: {
                        // Toggle favorite status
                        if favoriteQuotes.contains(currentQuoteIndex) {
                            favoriteQuotes.remove(currentQuoteIndex)
                        } else {
                            favoriteQuotes.insert(currentQuoteIndex)
                        }
                    }) {
                        VStack {
                            Image(systemName: favoriteQuotes.contains(currentQuoteIndex) ? "heart.fill" : "heart")
                                .font(.system(size: 20))
                                .foregroundColor(.white)
                                .frame(width: 50, height: 50)
                                .background(Color(hex: "6A89CC"))
                                .clipShape(Circle())
                                .shadow(color: Color(hex: "6A89CC").opacity(0.4), radius: 5, x: 0, y: 3)
                            
                            Text("Favorite")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white)
                        }
                    }
                }
                .padding(.bottom, 40)
            }
            .padding()
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation {
                    isAnimating = true
                }
            }
        }
        .sheet(isPresented: $showShareSheet) {
            let textToShare = "\"\(currentQuote.text)\"\n— \(currentQuote.author)"
            ShareSheet(activityItems: [textToShare])
        }
        .navigationTitle("Daily Motivation")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarItems(trailing:
            HStack {
                NavigationLink(destination: NotificationSettingsViewRef()) {
                    Image(systemName: "bell.badge")
                        .font(.system(size: 18))
                        .foregroundColor(Color(hex: "6A89CC"))
                        .padding(.trailing, 16)
                }
                
                NavigationLink(destination: FavoritesViewRef()) {
                    Image(systemName: "heart.text.square.fill")
                        .font(.system(size: 18))
                        .foregroundColor(Color(hex: "6A89CC"))
                }
            }
        )
    }
}

// ShareSheet for iOS sharing functionality
struct ShareSheet: UIViewControllerRepresentable {
    var activityItems: [Any]
    var applicationActivities: [UIActivity]? = nil
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: applicationActivities
        )
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
