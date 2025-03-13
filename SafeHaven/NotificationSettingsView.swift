//
//  NotificationSettingsView.swift
//  SafeHaven
//
//  Created by Travis Rodriguez on 2/27/25.
//
import Foundation
import SwiftUI
import CloudKit
import WeatherKit
import CoreLocation
import AuthenticationServices
import UserNotifications

struct NotificationSettingsView: View {
    @AppStorage("motivationNotificationsEnabled") private var notificationsEnabled = false
    @AppStorage("motivationNotificationHour") private var notificationHour = 9
    @AppStorage("motivationNotificationMinute") private var notificationMinute = 0
    @State private var showingAuthAlert = false
    @State private var selectedDate = Date()
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        Form {
            Section(header: Text("Daily Motivation")) {
                Toggle("Enable Daily Notifications", isOn: $notificationsEnabled)
                    .onChange(of: notificationsEnabled) { oldValue, newValue in
                        if newValue {
                            requestNotificationPermission()
                        } else {
                            updateNotificationSettings()
                        }
                    }
                
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
                    
                    Button(action: {
                        // Schedule a test notification for 5 seconds from now
                        scheduleTestNotification()
                    }) {
                        Text("Send Test Notification")
                    }
                }
            }
            
            Section(header: Text("About"), footer: Text("Notifications deliver daily motivation quotes to help inspire you throughout your day.")) {
                Text("You'll receive motivational quotes daily at your preferred time.")
                    .font(.subheadline)
                    .foregroundColor(Color(hex: "718096"))
            }
        }
        .navigationTitle("Notification Settings")
        .navigationBarTitleDisplayMode(.inline)
        .alert(isPresented: $showingAuthAlert) {
            Alert(
                title: Text("Enable Notifications"),
                message: Text("Please enable notifications for SafeHaven in your device settings to receive daily motivation."),
                dismissButton: .default(Text("OK"))
            )
        }
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
