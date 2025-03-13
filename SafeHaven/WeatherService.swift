//
//  WeatherService.swift
//  SafeHaven
//
//  Created by Travis Rodriguez on 3/12/25.
//
import Foundation
import WeatherKit
import CoreLocation

class WeatherService: ObservableObject {
    static let shared = WeatherService()
    
    @Published var currentWeather: WeatherData?
    @Published var error: Error?
    
    private let weatherKitService = WeatherKit.WeatherService.shared
    
    private init() {} // Private initializer
    
    func fetchWeather(for location: CLLocation) {
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
                }
            } catch {
                await MainActor.run {
                    self.error = error
                    print("Weather fetch error: \(error.localizedDescription)")
                }
            }
        }
    }
}
