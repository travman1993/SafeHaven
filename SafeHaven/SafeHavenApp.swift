//
//  SafeHavenApp.swift
//  SafeHaven
import SwiftUI
import CoreLocation

@main
struct SafeHavenApp: App {
    @StateObject private var locationService = LocationService()
    
    // First launch detection for onboarding
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    
    // Add state variable to track if the app is loaded
    @State private var isLoaded = false
    @State private var hasRequestedLocationPermission = false
    
    // Add a state object to track app appearance
    @AppStorage("useSystemTheme") private var useSystemTheme = true
    @AppStorage("darkModeEnabled") private var darkModeEnabled = false
    
    init() {
        // Check if this is the first launch ever
        if !UserDefaults.standard.bool(forKey: "hasLaunchedBefore") {
            // This is the first launch
            hasCompletedOnboarding = false
            UserDefaults.standard.set(true, forKey: "hasLaunchedBefore")
            
            // Set default appearance values
            useSystemTheme = true
            darkModeEnabled = false
        }
    }
    
    var body: some Scene {
        WindowGroup {
            if !isLoaded {
                // Show your existing launch screen while loading
                LaunchScreen()
                    .onAppear {
                        // Simulate a delay to show the launch screen
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                            withAnimation(.easeInOut(duration: 0.7)) {
                                isLoaded = true
                            }
                        }
                    }
                    // Apply preferred color scheme based on settings
                    .preferredColorScheme(colorScheme)
            } else if !hasCompletedOnboarding {
                // Show onboarding on first launch
                OnboardingView(hasCompletedOnboarding: $hasCompletedOnboarding, onComplete: {
                    // Save that onboarding is complete and proceed to main content
                    hasCompletedOnboarding = true
                })
                .preferredColorScheme(colorScheme)
            } else {
                ContentView()
                    .environmentObject(locationService)
                    .onAppear {
                        // Request location immediately when app appears
                        locationService.requestLocation()
                    }
                    // Apply preferred color scheme based on settings
                    .preferredColorScheme(colorScheme)
            }
        }
    }
    
    // Compute the color scheme based on app settings
    private var colorScheme: ColorScheme? {
        if useSystemTheme {
            return nil // Use system setting
        } else {
            return darkModeEnabled ? .dark : .light
        }
    }
}
