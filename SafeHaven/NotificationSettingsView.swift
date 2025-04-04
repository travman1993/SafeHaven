//
//  NotificationSettingsView.swift
//  SafeHaven
//
//  Created by Travis Rodriguez on 2/27/25.
//
import SwiftUI
import UserNotifications

struct NotificationSettingsView: View {
    @AppStorage("motivationNotificationsEnabled") private var notificationsEnabled = false
    @AppStorage("motivationNotificationHour") private var notificationHour = 9
    @AppStorage("motivationNotificationMinute") private var notificationMinute = 0
    @AppStorage("resourceUpdateNotificationsEnabled") private var resourceUpdateNotificationsEnabled = false
    @AppStorage("weatherWarningsEnabled") private var weatherWarningsEnabled = false
    @AppStorage("locationBasedAlertsEnabled") private var locationBasedAlertsEnabled = false
    @AppStorage("meditationNotificationsEnabled") private var meditationNotificationsEnabled = false
    @AppStorage("dailyMeditationCount") private var dailyMeditationCount = 3
    @AppStorage("firstMeditationTime") private var firstMeditationTimeStamp = Date().timeIntervalSince1970
    
    @State private var selectedDate = Date()
    @State private var showingAuthAlert = false
    @Environment(\.dismiss) var dismiss
    
    
    var body: some View {
        Form {
            Section(
                header: Text("Daily Motivation")
                    .foregroundColor(AppTheme.adaptiveTextPrimary)
            ) {
                Toggle("Enable Daily Notifications", isOn: $notificationsEnabled)
                    .onChange(of: notificationsEnabled) { oldValue, newValue in
                        if newValue {
                            requestNotificationPermission()
                        } else {
                            updateNotificationSettings()
                        }
                    }
                    .toggleStyle(SwitchToggleStyle(tint: AppTheme.primary))

                if notificationsEnabled {
                    DatePicker("Notification Time", selection: $selectedDate, displayedComponents: .hourAndMinute)
                        .onChange(of: selectedDate) { oldValue, newValue in
                            let components = Calendar.current.dateComponents([.hour, .minute], from: newValue)
                            if let hour = components.hour, let minute = components.minute {
                                notificationHour = hour
                                notificationMinute = minute
                                updateNotificationSettings()
                            }
                        }
                        .onAppear {
                            // Set the date picker to show the stored time
                            var components = DateComponents()
                            components.hour = notificationHour
                            components.minute = notificationMinute
                            if let date = Calendar.current.date(from: components) {
                                selectedDate = date
                            }
                        }
                        .foregroundColor(AppTheme.adaptiveTextPrimary)
                    
                    Button(action: {
                        // Schedule a test notification for 5 seconds from now
                        scheduleTestNotification()
                    }) {
                        Text("Send Test Notification")
                            .foregroundColor(AppTheme.adaptiveTextPrimary)
                    }
                }
            }
            
            Section(
                header: Text("Emergency Alerts")
                    .foregroundColor(AppTheme.adaptiveTextPrimary)
            ) {
                Toggle("Resource Updates", isOn: $resourceUpdateNotificationsEnabled)
                    .toggleStyle(SwitchToggleStyle(tint: AppTheme.primary))
                
                Toggle("Weather Warnings", isOn: $weatherWarningsEnabled)
                    .toggleStyle(SwitchToggleStyle(tint: AppTheme.primary))
                
                Toggle("Location-based Alerts", isOn: $locationBasedAlertsEnabled)
                    .toggleStyle(SwitchToggleStyle(tint: AppTheme.primary))
            }
            
            Section(
                header: Text("About")
                    .foregroundColor(AppTheme.adaptiveTextPrimary),
                footer: Text("Notifications deliver daily motivation quotes and important safety alerts to help you stay informed and inspired.")
                    .foregroundColor(AppTheme.adaptiveTextSecondary)
            ) {
                Text("You'll receive motivational quotes daily at your preferred time.")
                    .font(.subheadline)
                    .foregroundColor(AppTheme.adaptiveTextSecondary)
            }
            Section(
                header: Text("Breathing & Meditation")
                    .foregroundColor(AppTheme.adaptiveTextPrimary)
            ) {
                Toggle("Enable Meditation Reminders", isOn: $meditationNotificationsEnabled)
                    .onChange(of: meditationNotificationsEnabled) { oldValue, newValue in
                        if newValue {
                            requestNotificationPermission()
                        } else {
                            cancelMeditationNotifications()
                        }
                    }
                    .toggleStyle(SwitchToggleStyle(tint: AppTheme.primary))

                if meditationNotificationsEnabled {
                    Stepper(value: $dailyMeditationCount, in: 1...6) {
                        Text("Daily reminders: \(dailyMeditationCount)")
                            .foregroundColor(AppTheme.adaptiveTextPrimary)
                    }
                    
                    DatePicker("First reminder", selection: $firstMeditationTime, displayedComponents: .hourAndMinute)
                        .onChange(of: firstMeditationTime) { oldValue, newValue in
                            updateMeditationNotifications()
                        }
                        .foregroundColor(AppTheme.adaptiveTextPrimary)
                    
                    Button(action: {
                        scheduleMeditationTestNotification()
                    }) {
                        Text("Send Test Reminder")
                            .foregroundColor(AppTheme.adaptiveTextPrimary)
                    }
                }
            }

        }
        .navigationTitle("Notification Settings")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Enable Notifications", isPresented: $showingAuthAlert) {
            Button("OK", role: .cancel) { }
            Button("Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
        } message: {
            Text("Please enable notifications for SafeHaven in your device settings to receive daily motivation and important safety alerts.")
        }
    }
    
    private var firstMeditationTime: Date {
        get {
            return Date(timeIntervalSince1970: firstMeditationTimeStamp)
        }
        set {
            firstMeditationTimeStamp = newValue.timeIntervalSince1970
        }
    }
    
    private func updateMeditationNotifications() {
        guard meditationNotificationsEnabled else { return }
        
        NotificationManager.shared.scheduleMeditationNotifications(
            firstTime: firstMeditationTime,
            count: dailyMeditationCount,
            enabled: true
        )
    }

    private func cancelMeditationNotifications() {
        NotificationManager.shared.cancelMeditationNotifications()
    }

    private func scheduleMeditationTestNotification() {
        NotificationManager.shared.scheduleMeditationTestNotification()
    }
    
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            DispatchQueue.main.async {
                if !granted {
                    showingAuthAlert = true
                    notificationsEnabled = false
                } else {
                    updateNotificationSettings()
                }
            }
            
            if let error = error {
                print("Error requesting notification authorization: \(error)")
            }
        }
    }
    
    private func updateNotificationSettings() {
        // Remove existing notifications first
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["dailyMotivation"])
        
        guard notificationsEnabled else { return }
        
        // Create notification content
        let content = UNMutableNotificationContent()
        content.title = "Daily Motivation"
        content.body = "Time for your daily dose of inspiration!"
        content.sound = .default
        
        // Extract hour and minute components from the date
        var dateComponents = DateComponents()
        dateComponents.hour = notificationHour
        dateComponents.minute = notificationMinute
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        // Create the request
        let request = UNNotificationRequest(identifier: "dailyMotivation", content: content, trigger: trigger)
        
        // Add the request to the notification center
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            }
        }
    }
    
    private func scheduleTestNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Daily Motivation"
        content.body = "This is a test notification. Your daily motivation will arrive at your scheduled time."
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        let request = UNNotificationRequest(identifier: "testNotification", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling test notification: \(error)")
            }
        }
    }
}
