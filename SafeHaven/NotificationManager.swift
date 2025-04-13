import Foundation
import UserNotifications
import UIKit

class NotificationManager: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationManager()
    
    // Sample motivational quotes for notifications
    private let quotes = [
        (text: "The only way to do great work is to love what you do.", author: "Steve Jobs"),
        (text: "Life is 10% what happens to you and 90% how you react to it.", author: "Charles R. Swindoll"),
        (text: "Believe you can and you're halfway there.", author: "Theodore Roosevelt"),
        (text: "It does not matter how slowly you go as long as you do not stop.", author: "Confucius"),
        (text: "The future belongs to those who believe in the beauty of their dreams.", author: "Eleanor Roosevelt"),
        (text: "Success is not final, failure is not fatal: It is the courage to continue that counts.", author: "Winston Churchill")
    ]
    
    override private init() {
        super.init()
        // Configure notification center delegate
        UNUserNotificationCenter.current().delegate = self
    }
    
    // MARK: - UNUserNotificationCenterDelegate Methods
    func userNotificationCenter(_ center: UNUserNotificationCenter, 
                                willPresent notification: UNNotification, 
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Customize how notifications are handled when the app is in the foreground
        completionHandler([.banner, .sound, .badge])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, 
                                didReceive response: UNNotificationResponse, 
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        // Clear the badge when a notification is tapped
        center.removeAllDeliveredNotifications()
        
        // Set badge count to 0
        center.setBadgeCount(0) { error in
            if let error = error {
                print("Error setting badge count: \(error)")
            }
            completionHandler()
        }
    }
    
    // MARK: - Meditation Notifications
    func scheduleMeditationNotifications(firstTime: Date, count: Int, enabled: Bool = true) {
        // Remove existing meditation notifications first
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers:
            (0..<6).map { "meditation\($0)" })
        
        guard enabled && count > 0 else { return }
        
        // Extract hour and minute from first time
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: firstTime)
        let firstHour = components.hour ?? 9
        let firstMinute = components.minute ?? 0
        
        // Calculate meditation times throughout the day
        let wakeHour = firstHour
        let sleepHour = 22 // Assume 10PM as default end time
        let activeHours = sleepHour - wakeHour
        
        // Ensure at least 1 hour between notifications
        let interval = max(1, min(activeHours / count, activeHours))
        
        for i in 0..<count {
            // Create notification for each meditation time
            let meditationTime = calendar.date(bySettingHour: firstHour + (i * interval),
                                              minute: firstMinute,
                                              second: 0,
                                              of: firstTime) ?? firstTime
            
            scheduleSingleMeditationNotification(at: meditationTime, index: i)
        }
        
        print("Scheduled \(count) meditation notifications starting at \(firstTime)")
    }

    private func scheduleSingleMeditationNotification(at time: Date, index: Int) {
        let content = UNMutableNotificationContent()
        content.title = "Mindfulness Reminder"
        
        // Vary the message based on time of day
        if index == 0 {
            content.body = "Start your day with a moment of calm breathing."
        } else if index == 1 {
            content.body = "Take a break for a quick breathing exercise."
        } else if index >= 2 {
            let messages = [
                "Pause and breathe. You deserve this moment of peace.",
                "It's time to center yourself with some mindful breathing.",
                "Remember to breathe and reconnect with yourself.",
                "Take a mindful moment to breathe and reset."
            ]
            content.body = messages[index % messages.count]
        }
        
        content.sound = .default
        content.badge = 1
        
        // Create a daily trigger
        var dateComponents = Calendar.current.dateComponents([.hour, .minute], from: time)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        // Create the request
        let request = UNNotificationRequest(
            identifier: "meditation\(index)",
            content: content,
            trigger: trigger
        )
        
        // Add the request
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling meditation notification: \(error)")
            }
        }
    }

    // MARK: - Notification Management
    func cancelMeditationNotifications() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: (0..<6).map { "meditation\($0)" }
        )
        print("Cancelled all meditation notifications")
    }

    func scheduleMeditationTestNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Mindfulness Reminder"
        content.body = "This is a test reminder for your breathing exercise."
        content.sound = .default
        content.badge = 1
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        let request = UNNotificationRequest(identifier: "meditationTest", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling test meditation notification: \(error)")
            }
        }
    }
    
    // MARK: - Authorization
    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            DispatchQueue.main.async {
                completion(granted)
            }
            
            if let error = error {
                print("Error requesting notification authorization: \(error)")
            }
        }
    }
    
    // MARK: - Motivation Notifications
    func scheduleMotivationNotification(at time: Date, enabled: Bool = true) {
        // Remove existing notifications first
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["dailyMotivation"])
        
        guard enabled else { return }
        
        // Create notification content
        let content = UNMutableNotificationContent()
        content.title = "Daily Motivation"
        content.body = "Time for your daily dose of inspiration!"
        content.sound = .default
        content.badge = 1
        
        // Extract hour and minute components from the date
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: time)
        let minute = calendar.component(.minute, from: time)
        
        // Create a trigger that repeats daily at the specified time
        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute
        
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
    
    // MARK: - Random Quote Notifications
    func scheduleRandomQuoteNotification() {
        let content = UNMutableNotificationContent()
        
        // Get a random quote
        let randomQuote = quotes.randomElement()!
        
        content.title = "Inspiration for Today"
        content.body = "\"\(randomQuote.text)\" — \(randomQuote.author)"
        content.sound = .default
        content.badge = 1
        
        // Create a trigger for a random time today
        let currentDate = Date()
        let calendar = Calendar.current
        
        // Get a random time between 9am and 6pm
        let hour = Int.random(in: 9...18)
        let minute = Int.random(in: 0...59)
        
        var dateComponents = calendar.dateComponents([.year, .month, .day], from: currentDate)
        dateComponents.hour = hour
        dateComponents.minute = minute
        
        guard let triggerDate = calendar.date(from: dateComponents) else { return }
        
        // If the time has already passed today, schedule for tomorrow
        var finalTriggerDate = triggerDate
        if triggerDate < currentDate {
            finalTriggerDate = calendar.date(byAdding: .day, value: 1, to: triggerDate) ?? triggerDate
        }
        
        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: finalTriggerDate.timeIntervalSince(currentDate),
            repeats: false
        )
        
        // Create and schedule the request
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling random quote notification: \(error)")
            }
        }
    }
}
