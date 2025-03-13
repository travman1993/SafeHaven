//
//  WeatherCondition.swift
//  SafeHaven
//
//  Created by Travis Rodriguez on 3/12/25.
//
//
//  WeatherCondition.swift
//  SafeHaven
//
//  Created by Travis Rodriguez on 3/12/25.
//
import Foundation
import WeatherKit

enum WeatherCondition: String, Codable {
    case clear, cloudy, fog, haze, rain, snow, thunderstorms, windy, hot, cold
    case sunFlurries, sunShowers, sleet, blowingSnow, blizzard, unknown

    init(from weatherKitCondition: WeatherKit.WeatherCondition) {
        switch weatherKitCondition {
        case .clear: self = .clear
        case .cloudy: self = .cloudy
        case .fog, .mist: self = .fog  // ✅ Some versions use `.mist`
        case .haze: self = .haze
        case .rain: self = .rain
        case .snow: self = .snow
        case .thunderstorms: self = .thunderstorms
        case .wind, .breezy: self = .windy  // ✅ Some versions use `.breezy`
        case .hot, .heat: self = .hot  // ✅ Check for `.heat`
        case .cold, .chilly: self = .cold  // ✅ Some versions use `.chilly`
        case .sunFlurries: self = .sunFlurries
        case .sunShowers: self = .sunShowers
        case .sleet: self = .sleet
        case .blowingSnow: self = .blowingSnow
        case .blizzard: self = .blizzard
        @unknown default: self = .unknown
        }
    }
}

