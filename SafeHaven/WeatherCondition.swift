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

enum WeatherCondition: String {
    case clear, cloudy, fog, mist, haze, rain, snow, thunderstorms, wind, breezy, hot, heat, cold, chilly
    case sunFlurries, sunShowers, sleet, blowingSnow, blizzard, unknown

    init(from weatherKitCondition: WeatherKit.WeatherCondition) {
        switch weatherKitCondition {
        case .clear: self = .clear
        case .cloudy: self = .cloudy
        case .haze: self = .haze
        case .rain: self = .rain
        case .snow: self = .snow
        case .thunderstorms: self = .thunderstorms
        case .breezy: self = .breezy
        case .hot: self = .hot
        case .sunFlurries: self = .sunFlurries
        case .sunShowers: self = .sunShowers
        case .sleet: self = .sleet
        case .blowingSnow: self = .blowingSnow
        case .blizzard: self = .blizzard
        default: self = .unknown
        }
    }
}
