//
//  EmergencyModels.swift
//  SafeHaven
//
//  Created by Travis Rodriguez on 2/26/25.
//
import Foundation
import SwiftUI
import CloudKit
import WeatherKit
import CoreLocation
import AuthenticationServices

// Shared model for emergency contacts
struct EmergencyContact: Identifiable {
    let id = UUID()
    var name: String
    var phoneNumber: String
}
