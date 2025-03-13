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
    
    let pages = [
        OnboardingPage(
            title: "Welcome to Safe Haven",
            subtitle: "Find safety and support when you need it most",
            image: "house.fill",
            description: "Safe Haven is designed to help you quickly find resources and emergency assistance when you need them."
        ),
        OnboardingPage(
            title: "Emergency SOS",
            subtitle: "Quick access to emergency services",
            image: "exclamationmark.shield.fill",
            description: "Our emergency slider lets you quickly call 911 and send pre-configured emergency texts to your trusted contacts with your location."
        ),
        OnboardingPage(
            title: "Location Services",
            subtitle: "Share your location only when needed",
            image: "location.fill",
            description: "We'll only access your location when you use the emergency feature or when looking for nearby resources."
        ),
        OnboardingPage(
            title: "Ready to Get Started?",
            subtitle: "Let's set up your emergency contacts",
            image: "checkmark.circle.fill",
            description: "Add up to 5 emergency contacts who will receive your custom message with your location during an emergency."
        )
    ]
    
    var body: some View {
        VStack {
            TabView(selection: $currentPage) {
                ForEach(0..<pages.count, id: \.self) { index in
                    VStack(spacing: 30) {
                        Spacer()
                        
                        Image(systemName: pages[index].image)
                            .font(.system(size: 80))
                            .foregroundColor(Color(hex: "6A89CC"))
                        
                        Text(pages[index].title)
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(Color(hex: "2D3748"))
                        
                        Text(pages[index].subtitle)
                            .font(.system(size: 18, weight: .medium, design: .rounded))
                            .foregroundColor(Color(hex: "6A89CC"))
                        
                        Text(pages[index].description)
                            .font(.system(size: 16))
                            .foregroundColor(Color(hex: "718096"))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 30)
                        
                        Spacer()
                        
                        // Location permission request button on the location page
                        if index == 2 && !locationPermission.isAuthorized {
                            Button(action: {
                                locationPermission.requestPermission()
                            }) {
                                Text("Allow Location Access")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.white)
                                    .padding(.vertical, 16)
                                    .padding(.horizontal, 24)
                                    .background(Color(hex: "6A89CC"))
                                    .cornerRadius(12)
                            }
                            .padding(.bottom, 20)
                        }
                    }
                    .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
            
            // Navigation buttons
            HStack {
                if currentPage > 0 {
                    Button(action: {
                        withAnimation {
                            currentPage -= 1
                        }
                    }) {
                        HStack {
                            Image(systemName: "chevron.left")
                            Text("Back")
                        }
                        .foregroundColor(Color(hex: "6A89CC"))
                        .padding()
                    }
                } else {
                    Spacer()
                }
                
                Spacer()
                
                if currentPage < pages.count - 1 {
                    Button(action: {
                        withAnimation {
                            currentPage += 1
                        }
                    }) {
                        HStack {
                            Text("Next")
                            Image(systemName: "chevron.right")
                        }
                        .foregroundColor(Color(hex: "6A89CC"))
                        .padding()
                    }
                } else {
                    Button(action: {
                        // Complete onboarding
                        withAnimation {
                            hasCompletedOnboarding = true
                        }
                    }) {
                        Text("Get Started")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.vertical, 16)
                            .padding(.horizontal, 32)
                            .background(Color(hex: "41B3A3"))
                            .cornerRadius(12)
                    }
                    .padding()
                }
            }
            .padding(.bottom, 20)
        }
        .background(Color(hex: "F5F7FA").ignoresSafeArea())
    }
}

struct OnboardingPage {
    let title: String
    let subtitle: String
    let image: String
    let description: String
}
