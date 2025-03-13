//
//  WeatherService.swift
//  SafeHaven
//
//  Created by Travis Rodriguez on 3/12/25.
//
import Foundation
import SwiftUI
import CloudKit
import WeatherKit
import CoreLocation
import AuthenticationServices

class WeatherService: ObservableObject {
    @Published var currentWeather: WeatherData?
    @Published var error: Error?
    
    private let weatherService = WeatherKit.WeatherService.shared
    
    func fetchWeather(for location: CLLocation) {
        Task {
            do {
                let weather = try await weatherService.weather(for: location)
                
                let weatherData = WeatherData(
                    condition: WeatherCondition(from: weather.currentWeather.condition),
                    temperature: weather.currentWeather.temperature.value,
                    feelsLike: weather.currentWeather.apparentTemperature.value,
                    humidity: weather.currentWeather.humidity,
                    windSpeed: weather.currentWeather.wind.speed.value
                )
                
                await MainActor.run {
                    self.currentWeather = weatherData
                }
            } catch {
                await MainActor.run {
                    self.error = error
                    print("Weather fetch error: \(error.localizedDescription)")
                }
            }
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
        case .wind: return "Windy"
        case .hot: return "Hot"
        case .cold: return "Cold"
        default: return "Unknown"
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
        case .wind: return "wind"
        case .hot: return "thermometer.sun.fill"
        case .cold: return "thermometer.snowflake"
        default: return "questionmark"
        }
    }
}
