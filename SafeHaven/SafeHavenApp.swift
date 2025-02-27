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
import UserNotifications

@main
struct SafeHavenApp: App {
    // State to track if the user has completed onboarding
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    
    init() {
        // Initialize notifications when the app launches
        initializeNotifications()
    }
    
    var body: some Scene {
        WindowGroup {
            if hasCompletedOnboarding {
                ContentView()
            } else {
                OnboardingView(hasCompletedOnboarding: $hasCompletedOnboarding)
            }
        }
    }
    
    private func initializeNotifications() {
        // Check if notifications are enabled and schedule them if needed
        let notificationsEnabled = UserDefaults.standard.bool(forKey: "motivationNotificationsEnabled")
        
        if notificationsEnabled {
            let hour = UserDefaults.standard.integer(forKey: "motivationNotificationHour")
            let minute = UserDefaults.standard.integer(forKey: "motivationNotificationMinute")
            
            var components = DateComponents()
            components.hour = hour
            components.minute = minute
            
            if let date = Calendar.current.date(from: components) {
                NotificationManager.shared.scheduleMotivationNotification(at: date, enabled: true)
            }
        }
    }
}
