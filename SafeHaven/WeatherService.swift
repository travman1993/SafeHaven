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
    @Published var error: Error?
    @Published var isLoading = false
    
    private let weatherService = WeatherKit.WeatherService.shared
    
    private init() {} // Private initializer to enforce singleton
    
    func fetchWeather(for location: CLLocation) {
        isLoading = true
        currentWeather = nil
        error = nil
        
        Task {
            do {
                let weather = try await weatherService.weather(for: location)
                
                // Process data on the main thread
                await MainActor.run {
                    let weatherData = WeatherData(
                        condition: getCondition(from: weather.currentWeather.condition),
                        temperature: weather.currentWeather.temperature.value,
                        feelsLike: weather.currentWeather.apparentTemperature.value,
                        humidity: weather.currentWeather.humidity,
                        windSpeed: weather.currentWeather.wind.speed.value
                    )
                    
                    self.currentWeather = weatherData
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.error = error
                    self.isLoading = false
                    print("Weather fetch error: \(error.localizedDescription)")
                }
            }
        }
        
        // Add a timeout to ensure we don't get stuck loading
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) { [weak self] in
            if self?.isLoading == true {
                self?.isLoading = false
                self?.error = NSError(
                    domain: "WeatherService",
                    code: -1,
                    userInfo: [NSLocalizedDescriptionKey: "Request timed out"]
                )
                
                // Set a fallback weather condition if we time out
                self?.currentWeather = WeatherData(
                    condition: .clear,
                    temperature: 21.0,
                    feelsLike: 21.0,
                    humidity: 0.5,
                    windSpeed: 5.0
                )
            }
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
