//
//  TodoItem.swift
//  SafeHaven
//
//  Created by Travis Rodriguez on 3/1/25.
//
import Foundation
import SwiftUI
import CloudKit
import WeatherKit
import CoreLocation
import AuthenticationServices

struct TodoItem: Identifiable, Codable {
    let id: UUID
    var title: String
    var isCompleted: Bool
    let createdAt: Date
    
    init(title: String) {
        self.id = UUID()
        self.title = title
        self.isCompleted = false
        self.createdAt = Date()
    }
}
