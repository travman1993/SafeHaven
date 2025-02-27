//
//  EmergencyModels.swift
//  SafeHaven
//
//  Created by Travis Rodriguez on 2/26/25.
//
import SwiftUI

// Shared model for emergency contacts
struct EmergencyContact: Identifiable {
    let id = UUID()
    var name: String
    var phoneNumber: String
}
