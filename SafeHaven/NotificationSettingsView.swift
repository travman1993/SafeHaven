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
    @State private var firstMeditationTime = Date()
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
                            clearAllNotifications()
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
            
            // ... rest of the existing code remains the same
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
        NotificationManager.shared.requestAuthorization { granted in
            DispatchQueue.main.async {
                if !granted {
                    self.showingAuthAlert = true
                    self.notificationsEnabled = false
                } else {
                    self.updateNotificationSettings()
                }
            }
        }
    }
    
    private func updateNotificationSettings() {
        // Remove existing notifications first
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["dailyMotivation"])
        
        guard notificationsEnabled else { return }
        
        // Schedule motivation notification
        var dateComponents = DateComponents()
        dateComponents.hour = notificationHour
        dateComponents.minute = notificationMinute
        
        let date = Calendar.current.date(from: dateComponents) ?? Date()
        NotificationManager.shared.scheduleMotivationNotification(at: date)
    }
    
    private func scheduleTestNotification() {
        NotificationManager.shared.scheduleRandomQuoteNotification()
    }
    
    private func clearAllNotifications() {
        // Remove all pending notifications
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        
        // Clear the app icon badge
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
}
