//
//  WeatherService.swift
//  SafeHaven
//
//  Created by Travis Rodriguez on 3/12/25.
import Foundation
import WeatherKit
import CoreLocation
import SwiftUI

// A completely standalone weather service implementation
class WeatherService: ObservableObject {
    static let shared = WeatherService()
    
    // Simply provide the raw data that views can use
    @Published var currentTemperature: Double?
    @Published var currentFeelsLike: Double?
    @Published var currentCondition: String = ""
    @Published var currentHumidity: Double?
    @Published var currentWindSpeed: Double?
    
    // Forecast as simple data arrays
    @Published var forecastDates: [Date] = []
    @Published var forecastHighs: [Double] = []
    @Published var forecastLows: [Double] = []
    @Published var forecastConditions: [String] = []
    
    @Published var error: Error?
    @Published var isLoading = false
    
    private let weatherService = WeatherKit.WeatherService.shared
    private var lastFetchLocation: CLLocation?
    private var lastFetchTimestamp: Date?
    
    private var isFetchingWeather = false
    private var fetchDebounceWorkItem: DispatchWorkItem?
    
    private init() {}
    
    // Returns a formatted temperature string
    func temperatureString(_ temp: Double?) -> String {
        guard let temp = temp else { return "N/A" }
        return String(format: "%.1f°F", temp)
    }
    
    // Returns a formatted humidity string
    func humidityString(_ humidity: Double?) -> String {
        guard let humidity = humidity else { return "N/A" }
        return String(format: "%.0f%%", humidity * 100)
    }
    
    // Returns a formatted wind speed string
    func windSpeedString(_ windSpeed: Double?) -> String {
        guard let windSpeed = windSpeed else { return "N/A" }
        return String(format: "%.1f mph", windSpeed)
    }
    
    // Returns a day of week string for a date
    func dayOfWeek(for date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        return dateFormatter.string(from: date)
    }
    
    func fetchWeather(for location: CLLocation) {
        fetchDebounceWorkItem?.cancel()
        
        let workItem = DispatchWorkItem { [weak self] in
            guard let self = self, !self.isFetchingWeather else { return }
            self.performFetchWeather(for: location)
        }
        
        fetchDebounceWorkItem = workItem
        
        if !isLoading {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: workItem)
        }
    }
    
    private func performFetchWeather(for location: CLLocation) {
        guard shouldFetchWeather(for: location), !isFetchingWeather else {
            print("Skipping fetch: Recent data exists or already fetching.")
            return
        }
        
        isLoading = true
        isFetchingWeather = true
        
        Task {
            do {
                let weather = try await weatherService.weather(for: location)
                
                // Add debug print
                print("WEATHERKIT DATA RECEIVED:")
                let forecastItems = weather.dailyForecast.forecast.prefix(5)
                for (i, item) in forecastItems.enumerated() {
                    print("Day \(i) - Date: \(item.date), High: \(item.highTemperature.value)°C, Low: \(item.lowTemperature.value)°C, Condition: \(item.condition)")
                }
                
                await MainActor.run {
                    // Update current weather values
                    self.currentTemperature = celsiusToFahrenheit(weather.currentWeather.temperature.value)
                    self.currentFeelsLike = celsiusToFahrenheit(weather.currentWeather.apparentTemperature.value)
                    self.currentCondition = mapConditionToString(weather.currentWeather.condition)
                    self.currentHumidity = weather.currentWeather.humidity
                    self.currentWindSpeed = weather.currentWeather.wind.speed.value
                    
                    // Update forecast arrays
                    self.forecastDates = forecastItems.map { $0.date }
                    self.forecastHighs = forecastItems.map { celsiusToFahrenheit($0.highTemperature.value) }
                    self.forecastLows = forecastItems.map { celsiusToFahrenheit($0.lowTemperature.value) }
                    self.forecastConditions = forecastItems.map { mapConditionToString($0.condition) }
                    
                    self.lastFetchLocation = location
                    self.lastFetchTimestamp = Date()
                    self.error = nil
                    
                    self.isLoading = false
                    self.isFetchingWeather = false
                }
            } catch {
                await MainActor.run {
                    self.error = error
                    print("Weather fetch error: \(error.localizedDescription)")
                    
                    // Add debug print to know when fallback is used
                    print("Using fallback weather data due to error")
                    
                    if self.currentTemperature == nil {
                        self.setFallbackWeather()
                    }
                    
                    self.isLoading = false
                    self.isFetchingWeather = false
                }
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) { [weak self] in
            guard let self = self, self.isFetchingWeather else { return }
            
            self.isLoading = false
            self.isFetchingWeather = false
            
            if self.currentTemperature == nil {
                self.error = NSError(
                    domain: "WeatherService",
                    code: -1,
                    userInfo: [NSLocalizedDescriptionKey: "Weather request timed out"]
                )
                print("Weather request timed out - using fallback data")
                self.setFallbackWeather()
            }
        }
    }
    
    private func shouldFetchWeather(for location: CLLocation) -> Bool {
        guard let lastLocation = lastFetchLocation,
              let lastFetchTime = lastFetchTimestamp else {
            return true
        }
        
        let distanceThreshold: CLLocationDistance = 5000 // 5 km
        let timeThreshold: TimeInterval = 7200 // 2 hours
        
        let distance = location.distance(from: lastLocation)
        let timeSinceLastFetch = Date().timeIntervalSince(lastFetchTime)
        
        return distance > distanceThreshold || timeSinceLastFetch > timeThreshold
    }
    
    private func setFallbackWeather() {
        // Set fallback weather data
        self.currentTemperature = celsiusToFahrenheit(21.0)
        self.currentFeelsLike = celsiusToFahrenheit(21.0)
        self.currentCondition = "Clear"
        self.currentHumidity = 0.5
        self.currentWindSpeed = 5.0
        
        // Set fallback forecast with VARIED data
        if self.forecastDates.isEmpty {
            let today = Date()
            self.forecastDates = (0..<5).map { Calendar.current.date(byAdding: .day, value: $0, to: today) ?? today }
            
            // Varied high temperatures
            self.forecastHighs = [
                celsiusToFahrenheit(24.0),  // Today
                celsiusToFahrenheit(25.5),  // Tomorrow
                celsiusToFahrenheit(23.0),  // Day 3
                celsiusToFahrenheit(26.0),  // Day 4
                celsiusToFahrenheit(24.5)   // Day 5
            ]
            
            // Varied low temperatures
            self.forecastLows = [
                celsiusToFahrenheit(18.0),  // Today
                celsiusToFahrenheit(17.5),  // Tomorrow
                celsiusToFahrenheit(16.0),  // Day 3
                celsiusToFahrenheit(18.5),  // Day 4
                celsiusToFahrenheit(17.0)   // Day 5
            ]
            
            // Varied conditions
            self.forecastConditions = [
                "Clear",      // Today
                "Clear",      // Tomorrow
                "Cloudy",     // Day 3
                "Rainy",      // Day 4
                "Clear"       // Day 5
            ]
            
            print("Set varied fallback forecast data")
        }
    }
    
    // Convert Celsius to Fahrenheit
    private func celsiusToFahrenheit(_ celsius: Double) -> Double {
        return (celsius * 9/5) + 32
    }
    
    // Maps WeatherKit condition to a simple string
    private func mapConditionToString(_ condition: WeatherKit.WeatherCondition) -> String {
        switch condition {
        case .clear:
            return "Clear"
        case .cloudy, .mostlyCloudy, .partlyCloudy:
            return "Cloudy"
        case .foggy:
            return "Foggy"
        case .haze:
            return "Hazy"
        case .rain, .drizzle, .heavyRain, .isolatedThunderstorms:
            return "Rainy"
        case .snow, .flurries, .heavySnow:
            return "Snowy"
        case .thunderstorms:
            return "Thunderstorms"
        case .windy:
            return "Windy"
        case .breezy:
            return "Breezy"
        case .hot:
            return "Hot"
        case .frigid, .blizzard:
            return "Cold"
        default:
            return "Unknown"
        }
    }
}
