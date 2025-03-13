//
//  NotificationManager.swift
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

class NotificationManager {
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
    
    private init() {}
    
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
    
    func scheduleMotivationNotification(at time: Date, enabled: Bool = true) {
        // Remove existing notifications first
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["dailyMotivation"])
        
        guard enabled else { return }
        
        // Create notification content
        let content = UNMutableNotificationContent()
        content.title = "Daily Motivation"
        content.body = "Time for your daily dose of inspiration!"
        content.sound = .default
        
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
    
    func scheduleRandomQuoteNotification() {
        let content = UNMutableNotificationContent()
        
        // Get a random quote
        let randomQuote = quotes.randomElement()!
        
        content.title = "Inspiration for Today"
        content.body = "\"\(randomQuote.text)\" — \(randomQuote.author)"
        content.sound = .default
        
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
