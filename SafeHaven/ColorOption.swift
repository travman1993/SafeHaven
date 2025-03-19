//
//  ColorOption.swift
//  SafeHaven
//
//  Created by Travis Rodriguez on 3/19/25.
//
import Foundation
import SwiftUI

// Single definition of ColorOption to be used throughout the app
struct ColorOption: Identifiable {
    let id = UUID()
    let name: String
    let hex: String
}
