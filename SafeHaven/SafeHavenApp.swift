//
//  SafeHavenApp.swift
//  SafeHaven
//
//  Created by Travis Rodriguez on 2/23/25.
//

//
//  SafeHavenApp.swift
//  SafeHaven
//
//  Created by Travis Rodriguez on 2/23/25.
//

import SwiftUI

@main
struct SafeHavenApp: App {
    // State to track if the user has completed onboarding
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    
    var body: some Scene {
        WindowGroup {
            if hasCompletedOnboarding {
                ContentView()
            } else {
                OnboardingView(hasCompletedOnboarding: $hasCompletedOnboarding)
            }
        }
    }
}
