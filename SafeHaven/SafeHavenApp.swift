//
//  SafeHavenApp.swift
//  SafeHaven
//
import SwiftUI
import WeatherKit
import CoreLocation

@main
struct SafeHavenApp: App {
    @StateObject private var locationService = LocationService()
    @StateObject private var weatherService = WeatherService.shared
    
    // First launch detection for onboarding
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    
    init() {
        // Check if this is the first launch ever
        if !UserDefaults.standard.bool(forKey: "hasLaunchedBefore") {
            // This is the first launch
            hasCompletedOnboarding = false
            UserDefaults.standard.set(true, forKey: "hasLaunchedBefore")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            if !hasCompletedOnboarding {
                // Show onboarding on first launch
                OnboardingView(hasCompletedOnboarding: $hasCompletedOnboarding, onComplete: {
                    // Save that onboarding is complete and proceed to main content
                    hasCompletedOnboarding = true
                })
            } else {
                ContentView()
                    .environmentObject(locationService)
                    .environmentObject(weatherService)
                    .onReceive(locationService.$currentLocation) { location in
                        if let location = location {
                            weatherService.fetchWeather(for: location)
                        }
                    }
            }
        }
    }
}
