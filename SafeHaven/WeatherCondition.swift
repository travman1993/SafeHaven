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

    var iconName: String {
        switch self {
        case .clear: return "sun.max.fill"
        case .cloudy: return "cloud.fill"
        case .fog, .mist: return "cloud.fog.fill"
        case .haze: return "sun.haze.fill"
        case .rain: return "cloud.rain.fill"
        case .snow: return "cloud.snow.fill"
        case .thunderstorms: return "cloud.bolt.fill"
        case .wind, .breezy: return "wind"
        case .hot, .heat: return "thermometer.sun.fill"
        case .cold, .chilly: return "thermometer.snowflake"
        case .sunFlurries: return "sun.snow.fill"
        case .sunShowers: return "sun.rain.fill"
        case .sleet: return "cloud.sleet.fill"
        case .blowingSnow: return "wind.snow"
        case .blizzard: return "snowflake"
        default: return "questionmark.diamond"
        }
    }
    
    var description: String {
        return self.rawValue.capitalized
    }
    
    init(from weatherKitCondition: WeatherKit.WeatherCondition) {
        switch weatherKitCondition {
        case .clear: self = .clear
        case .cloudy, .mostlyCloudy, .partlyCloudy: self = .cloudy
        case .foggy: self = .fog
        case .haze: self = .haze
        case .rain, .drizzle, .heavyRain, .isolatedThunderstorms: self = .rain
        case .snow, .flurries, .heavySnow: self = .snow
        case .thunderstorms: self = .thunderstorms
        case .windy: self = .wind
        case .breezy: self = .breezy
        case .hot: self = .hot
        case .frigid, .blizzard: self = .cold
        case .sunFlurries: self = .sunFlurries
        case .sunShowers: self = .sunShowers
        case .sleet: self = .sleet
        case .blowingSnow: self = .blowingSnow
        default: self = .unknown
        }
    }
}
