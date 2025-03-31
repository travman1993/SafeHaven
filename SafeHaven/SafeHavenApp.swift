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
    
    // Add a state variable to track if the app is loaded
    @State private var isLoaded = false
    @State private var hasRequestedLocationPermission = false
    
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
            } else if !hasCompletedOnboarding {
                // Show onboarding on first launch
                OnboardingView(hasCompletedOnboarding: $hasCompletedOnboarding, onComplete: {
                    // Save that onboarding is complete and proceed to main content
                    hasCompletedOnboarding = true
                })
            } else {
                ContentView()
                    .environmentObject(locationService)
                    .environmentObject(weatherService)
                    .onAppear {
                        // Request location immediately when app appears
                        locationService.requestLocation()
                    }
                    .onReceive(locationService.$currentLocation) { location in
                        if let location = location {
                            print("Location updated, fetching weather: \(location.coordinate.latitude), \(location.coordinate.longitude)")
                            weatherService.fetchWeather(for: location)
                        } else {
                            print("Location unavailable, cannot fetch weather")
                        }
                    }
            }
        }
    }
}
