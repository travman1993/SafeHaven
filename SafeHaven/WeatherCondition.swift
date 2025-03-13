//
//  WeatherCondition.swift
//  SafeHaven
//
//  Created by Travis Rodriguez on 3/12/25.
//
import Foundation
import WeatherKit
import CoreLocation

// Define WeatherData first
struct WeatherData: Codable {
    let condition: WeatherCondition
    let temperature: Double
    let feelsLike: Double
    let humidity: Double
    let windSpeed: Double
}

// Define WeatherCondition enum
enum WeatherCondition: Codable {
    case clear
    case cloudy
    case fog
    case haze
    case rain
    case snow
    case thunderstorms
    case windy
    case hot
    case cold
    // existing cases...

    // Static methods to resolve 'no member' errors
    static func fog(_ condition: WeatherCondition) -> Bool {
        return condition == .fog
    }

    static func wind(_ condition: WeatherCondition) -> Bool {
        return condition == .windy
    }

    static func cold(_ condition: WeatherCondition) -> Bool {
        return condition == .cold
    }
}
    
    // Conversion initializer from WeatherKit's condition
    init(from weatherKitCondition: WeatherKit.WeatherCondition) {
        switch weatherKitCondition {
        case .clear: self = .clear
        case .cloudy: self = .cloudy
        case .fog: self = .fog
        case .haze: self = .haze
        case .rain: self = .rain
        case .snow: self = .snow
        case .thunderstorms: self = .thunderstorms
        case .wind: self = .windy
        case .hot: self = .hot
        case .cold: self = .cold
        case .sunFlurries: self = .sunFlurries
        case .sunShowers: self = .sunShowers
        case .sleet: self = .sleet
        case .blowingSnow: self = .blowingSnow
        case .blizzard: self = .blizzard
        @unknown default: self = .unknown
        }
    }
}

// SafeHaven custom Weather Service
class SafeHavenWeatherService {
    // Singleton instance
    static let shared = SafeHavenWeatherService()
    
    // Private initializer to prevent multiple instances
    private init() {}
    
    // Weather fetching method
    func fetchWeather(for location: CLLocation) async throws -> WeatherData {
        // Use WeatherKit's actual weather service
        let weatherService = WeatherService.shared
        
        do {
            let weather = try await weatherService.weather(for: location)
            
            return WeatherData(
                condition: WeatherCondition(from: weather.currentWeather.condition),
                temperature: weather.currentWeather.temperature.value,
                feelsLike: weather.currentWeather.apparentTemperature.value,
                humidity: weather.currentWeather.humidity,
                windSpeed: weather.currentWeather.wind.speed.value
            )
        } catch {
            throw error
        }
    }
    
    // Utility methods
    func weatherDescription(for condition: WeatherCondition) -> String {
        switch condition {
        case .clear: return "Clear"
        case .cloudy: return "Cloudy"
        case .fog: return "Foggy"
        case .rain: return "Rainy"
        case .snow: return "Snowy"
        case .thunderstorms: return "Thunderstorms"
        case .windy: return "Windy"
        case .hot: return "Hot"
        case .cold: return "Cold"
        case .unknown: return "Unknown"
        default: return "Other Condition"
        }
    }
    
    func weatherIcon(for condition: WeatherCondition) -> String {
        switch condition {
        case .clear: return "sun.max.fill"
        case .cloudy: return "cloud.fill"
        case .fog: return "cloud.fog.fill"
        case .rain: return "cloud.rain.fill"
        case .snow: return "cloud.snow.fill"
        case .thunderstorms: return "cloud.bolt.rain.fill"
        case .windy: return "wind"
        case .hot: return "thermometer.sun.fill"
        case .cold: return "thermometer.snowflake"
        case .unknown: return "questionmark"
        default: return "ellipsis"
        }
    }
}
