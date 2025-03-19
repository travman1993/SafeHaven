//
//  WeatherService.swift
//  SafeHaven
//
//  Created by Travis Rodriguez on 3/12/25.
import Foundation
import WeatherKit
import CoreLocation
import SwiftUI

class WeatherService: ObservableObject {
    static let shared = WeatherService()
    
    @Published var currentWeather: WeatherData?
    @Published var dailyForecast: [DailyWeatherData] = []
    @Published var error: Error?
    @Published var isLoading = false
    
    private let weatherService = WeatherKit.WeatherService.shared
    private var lastFetchLocation: CLLocation?
    private var lastFetchTimestamp: Date?
    
    private init() {} // Private initializer to enforce singleton
    
    func fetchWeather(for location: CLLocation) {
        // Prevent repeated fetches for the same location within a short time
        if let lastLocation = lastFetchLocation,
           let lastFetchTime = lastFetchTimestamp,
           location.distance(from: lastLocation) < 1000 &&
           Date().timeIntervalSince(lastFetchTime) < 3600 {
            return
        }
        
        isLoading = true
        currentWeather = nil
        dailyForecast = []
        error = nil
        
        Task {
            do {
                let weather = try await weatherService.weather(for: location)
                
                // Process data on the main thread
                await MainActor.run {
                    // Current Weather
                    let weatherData = WeatherData(
                        condition: getCondition(from: weather.currentWeather.condition),
                        temperature: weather.currentWeather.temperature.value,
                        feelsLike: weather.currentWeather.apparentTemperature.value,
                        humidity: weather.currentWeather.humidity,
                        windSpeed: weather.currentWeather.wind.speed.value
                    )
                    
                    // Daily Forecast
                    let forecast = weather.dailyForecast.forecast.prefix(5).map { dailyForecast in
                        DailyWeatherData(
                            date: dailyForecast.date,
                            condition: getCondition(from: dailyForecast.condition),
                            highTemperature: dailyForecast.highTemperature.value,
                            lowTemperature: dailyForecast.lowTemperature.value
                        )
                    }
                    
                    self.currentWeather = weatherData
                    self.dailyForecast = forecast
                    self.lastFetchLocation = location
                    self.lastFetchTimestamp = Date()
                    self.isLoading = false
                    self.error = nil
                }
            } catch {
                await MainActor.run {
                    self.error = error
                    self.isLoading = false
                    print("Weather fetch error: \(error.localizedDescription)")
                    
                    // Set fallback data
                    self.setFallbackWeather()
                }
            }
        }
        
        // Add a timeout to ensure we don't get stuck loading
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) { [weak self] in
                    guard let self = self else { return }
                    if self.isLoading {
                        self.isLoading = false
                        self.error = NSError(
                            domain: "WeatherService",
                            code: -1,
                            userInfo: [NSLocalizedDescriptionKey: "Weather request timed out"]
                        )
                        self.setFallbackWeather()
                    }
                }
            }
            
            private func shouldFetchWeather(for location: CLLocation) -> Bool {
                guard let lastLocation = lastFetchLocation,
                      let lastFetchTime = lastFetchTimestamp else {
                    return true
                }
                
                let distanceThreshold: CLLocationDistance = 1000 // 1 km
                let timeThreshold: TimeInterval = 3600 // 1 hour
                
                let distance = location.distance(from: lastLocation)
                let timeSinceLastFetch = Date().timeIntervalSince(lastFetchTime)
                
                return distance > distanceThreshold || timeSinceLastFetch > timeThreshold
            }
            
            private func setFallbackWeather() {
                // Predefined fallback weather data
                self.currentWeather = WeatherData(
                    condition: .clear,
                    temperature: 21.0,
                    feelsLike: 21.0,
                    humidity: 0.5,
                    windSpeed: 5.0
                )
                
                // Generate fallback daily forecast
                let today = Date()
                self.dailyForecast = (0..<5).map { offset in
                    let date = Calendar.current.date(byAdding: .day, value: offset, to: today) ?? today
                    return DailyWeatherData(
                        date: date,
                        condition: .clear,
                        highTemperature: 24.0,
                        lowTemperature: 18.0
                    )
                }
            }
    
    // Convert from WeatherKit condition to our custom condition
    private func getCondition(from weatherKitCondition: WeatherKit.WeatherCondition) -> WeatherCondition {
        switch weatherKitCondition {
        case .clear:
            return .clear
        case .cloudy, .mostlyCloudy, .partlyCloudy:
            return .cloudy
        case .foggy:
            return .fog
        case .haze:
            return .haze
        case .rain, .drizzle, .heavyRain, .isolatedThunderstorms:
            return .rain
        case .snow, .flurries, .heavySnow:
            return .snow
        case .thunderstorms:
            return .thunderstorms
        case .windy:
            return .wind
        case .breezy:
            return .breezy
        case .hot:
            return .hot
        case .frigid, .blizzard:
            return .cold
        default:
            return .unknown
        }
    }
}

// Extend existing WeatherData struct to include daily forecast
struct DailyWeatherData {
    let date: Date
    let condition: WeatherCondition
    let highTemperature: Double
    let lowTemperature: Double
    
    var highTemperatureString: String {
        return String(format: "%.1f°C", highTemperature)
    }
    
    var lowTemperatureString: String {
        return String(format: "%.1f°C", lowTemperature)
    }
    
    var dayOfWeek: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        return dateFormatter.string(from: date)
    }
}
