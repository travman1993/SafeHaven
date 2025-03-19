//
//  OnboardingView.swift
//  SafeHaven
//
//  Created by Travis Rodriguez on 2/26/25.
//
import SwiftUI
import CoreLocation

struct OnboardingView: View {
    @Binding var hasCompletedOnboarding: Bool
    @StateObject private var locationPermission = LocationPermissionManager()
    @State private var currentPage = 0
    var onComplete: () -> Void
    
    // Enhanced pages with more detailed content
    let pages = [
        OnboardingPage(
            title: "Welcome to SafeHaven",
            subtitle: "Your lifeline in times of need",
            image: "hand.raised.fill",
            description: "SafeHaven helps you quickly find resources, emergency assistance, and support services when you need them most."
        ),
        OnboardingPage(
            title: "Emergency SOS",
            subtitle: "Help is just a slide away",
            image: "exclamationmark.shield.fill",
            description: "Our emergency slider lets you quickly call 911 and automatically sends your location to your trusted emergency contacts."
        ),
        OnboardingPage(
            title: "Find Resources",
            subtitle: "Connect with local support services",
            image: "mappin.and.ellipse",
            description: "Locate nearby shelters, food banks, healthcare providers, mental health services, and many other essential resources."
        ),
        OnboardingPage(
            title: "Location Services",
            subtitle: "Privacy & safety under your control",
            image: "location.fill",
            description: "We'll only access your location when you use the emergency feature or when looking for nearby resources. Your location data is never stored or shared without your permission."
        ),
        OnboardingPage(
            title: "Daily Motivation & Journal",
            subtitle: "Track your progress and stay inspired",
            image: "heart.text.square.fill",
            description: "Build resilience with daily motivation quotes and track your journey with our private journal feature."
        ),
        OnboardingPage(
            title: "Ready to Get Started?",
            subtitle: "Everything is completely free!",
            image: "checkmark.shield.fill",
            description: "All features are available with no subscription required. Your data stays on your device for maximum privacy."
        )
    ]
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [Color(hex: "F8F9FA"), Color(hex: "E9ECEF")]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Progress bar
                HStack(spacing: 4) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        Capsule()
                            .fill(currentPage >= index ? AppTheme.primary : Color.gray.opacity(0.3))
                            .frame(height: 4)
                            .animation(.spring(), value: currentPage)
                    }
                }
                .padding(.horizontal, 40)
                .padding(.top, 20)
                
                // Page content
                TabView(selection: $currentPage) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        VStack(spacing: 30) {
                            Spacer()
                            
                            ZStack {
                                Circle()
                                    .fill(LinearGradient(
                                        gradient: Gradient(colors: [AppTheme.primary.opacity(0.8), AppTheme.secondary]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ))
                                    .frame(width: 120, height: 120)
                                
                                Image(systemName: pages[index].image)
                                    .font(.system(size: 50))
                                    .foregroundColor(.white)
                            }
                            .shadow(color: AppTheme.primary.opacity(0.3), radius: 8, x: 0, y: 4)
                            
                            VStack(spacing: 12) {
                                Text(pages[index].title)
                                    .font(.system(size: 28, weight: .bold, design: .rounded))
                                    .foregroundColor(AppTheme.textPrimary)
                                    .multilineTextAlignment(.center)
                                
                                Text(pages[index].subtitle)
                                    .font(.system(size: 18, weight: .medium, design: .rounded))
                                    .foregroundColor(AppTheme.primary)
                                    .multilineTextAlignment(.center)
                            }
                            
                            Text(pages[index].description)
                                .font(.system(size: 16))
                                .foregroundColor(AppTheme.textSecondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 40)
                                .padding(.top, 8)
                            
                            Spacer()
                            
                            // Location permission request button on the location page
                            if index == 3 && !locationPermission.isAuthorized {
                                Button(action: {
                                    locationPermission.requestPermission()
                                }) {
                                    HStack {
                                        Image(systemName: "location.fill")
                                        Text("Allow Location Access")
                                    }
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                                    .padding(.vertical, 16)
                                    .padding(.horizontal, 24)
                                    .background(AppTheme.primary)
                                    .cornerRadius(12)
                                    .shadow(color: AppTheme.primary.opacity(0.3), radius: 5, x: 0, y: 3)
                                }
                                .padding(.bottom, 40)
                            }
                        }
                        .tag(index)
                        .padding(.bottom, 80)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                
                // Navigation buttons
                HStack {
                    // Back button
                    if currentPage > 0 {
                        Button(action: {
                            withAnimation {
                                currentPage -= 1
                            }
                        }) {
                            HStack(spacing: 4) {
                                Image(systemName: "chevron.left")
                                Text("Back")
                            }
                            .foregroundColor(AppTheme.primary)
                            .padding()
                        }
                    } else {
                        Spacer()
                            .frame(width: 80)
                    }
                    
                    Spacer()
                    
                    // Next/Get Started button
                    if currentPage < pages.count - 1 {
                        Button(action: {
                            withAnimation {
                                currentPage += 1
                            }
                        }) {
                            HStack(spacing: 4) {
                                Text("Next")
                                Image(systemName: "chevron.right")
                            }
                            .foregroundColor(AppTheme.primary)
                            .padding()
                        }
                    } else {
                        Button(action: {
                            // Complete onboarding
                            UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
                            hasCompletedOnboarding = true
                            onComplete()  // Call the completion handler
                        }) {
                            Text("Get Started")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                                .padding(.vertical, 16)
                                .padding(.horizontal, 32)
                                .background(AppTheme.secondary)
                                .cornerRadius(12)
                                .shadow(color: AppTheme.secondary.opacity(0.3), radius: 5, x: 0, y: 3)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
        }
    }
}

struct OnboardingPage {
    let title: String
    let subtitle: String
    let image: String
    let description: String
}

// Preview
struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView(hasCompletedOnboarding: .constant(false), onComplete: {})
    }
}
