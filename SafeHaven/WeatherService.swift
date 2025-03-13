//
//  WeatherService.swift
//  SafeHaven
//
//  Created by Travis Rodriguez on 3/12/25.
//  WeatherService.swift
//  SafeHaven
//
//  Created by Travis Rodriguez on 3/12/25.

import Foundation
import WeatherKit
import CoreLocation

class WeatherService: ObservableObject {
    static let shared = WeatherService()

    @Published var currentWeather: WeatherData?
    @Published var error: Error?
    @Published var isLoading = false  // Add this property
    
    private let weatherKitService = WeatherKit.WeatherService.shared
    
    private init() {} // Private initializer to enforce singleton

    func fetchWeather(for location: CLLocation) {
        isLoading = true  // Set loading to true when fetching starts
        
        Task {
            do {
                let weather = try await weatherKitService.weather(for: location)
                
                let weatherData = WeatherData(
                    condition: WeatherCondition(from: weather.currentWeather.condition),
                    temperature: weather.currentWeather.temperature.value,
                    feelsLike: weather.currentWeather.apparentTemperature.value,
                    humidity: weather.currentWeather.humidity,
                    windSpeed: weather.currentWeather.wind.speed.value
                )
                
                await MainActor.run {
                    self.currentWeather = weatherData
                    self.isLoading = false  // Set loading to false when done
                }
            } catch {
                await MainActor.run {
                    self.error = error
                    self.isLoading = false  // Set loading to false on error
                    print("Weather fetch error: \(error.localizedDescription)")
                }
            }
        }
    }
}
