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
    
    private var fetchDebounceWorkItem: DispatchWorkItem?

    func fetchWeather(for location: CLLocation) {
        fetchDebounceWorkItem?.cancel() // Cancel any previous fetch request
        
        let workItem = DispatchWorkItem { [weak self] in
            self?.performFetchWeather(for: location)
        }
        
        fetchDebounceWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: workItem) // Delay fetch by 2 seconds
    }

    private func performFetchWeather(for location: CLLocation) {
        guard shouldFetchWeather(for: location) else {
            print("Skipping fetch: Recent data exists.")
            return
        }
        
        isLoading = true
        currentWeather = nil
        dailyForecast = []
        error = nil

        Task {
            do {
                let weather = try await weatherService.weather(for: location)
                
                await MainActor.run {
                    let weatherData = WeatherData(
                        condition: getCondition(from: weather.currentWeather.condition),
                        temperature: celsiusToFahrenheit(weather.currentWeather.temperature.value),
                        feelsLike: celsiusToFahrenheit(weather.currentWeather.apparentTemperature.value),
                        humidity: weather.currentWeather.humidity,
                        windSpeed: weather.currentWeather.wind.speed.value
                    )
                    
                    let forecast = weather.dailyForecast.forecast.prefix(5).map { dailyForecast in
                        DailyWeatherData(
                            date: dailyForecast.date,
                            condition: getCondition(from: dailyForecast.condition),
                            highTemperature: celsiusToFahrenheit(dailyForecast.highTemperature.value),
                            lowTemperature: celsiusToFahrenheit(dailyForecast.lowTemperature.value)
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
            temperature: celsiusToFahrenheit(21.0),
            feelsLike: celsiusToFahrenheit(21.0),
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
                highTemperature: celsiusToFahrenheit(24.0),
                lowTemperature: celsiusToFahrenheit(18.0)
            )
        }
    }

    // Convert Celsius to Fahrenheit
    private func celsiusToFahrenheit(_ celsius: Double) -> Double {
        return (celsius * 9/5) + 32
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

// Daily forecast data structure
struct DailyWeatherData {
    let date: Date
    let condition: WeatherCondition
    let highTemperature: Double
    let lowTemperature: Double
    
    var highTemperatureString: String {
        return String(format: "%.1f°F", highTemperature)
    }
    
    var lowTemperatureString: String {
        return String(format: "%.1f°F", lowTemperature)
    }
    
    var dayOfWeek: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        return dateFormatter.string(from: date)
    }
}
