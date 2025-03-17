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

// Update WeatherService.swift
class WeatherService: ObservableObject {
    static let shared = WeatherService()
    
    @Published var currentWeather: WeatherData?
    @Published var error: Error?
    @Published var isLoading = false
    
    private let weatherKitService = WeatherKit.WeatherService.shared
    
    private init() {} // Private initializer to enforce singleton
    
    func fetchWeather(for location: CLLocation) {
        isLoading = true
        
        let task = Task { @MainActor in
            do {
                let weather = try await weatherKitService.weather(for: location)
                
                let weatherData = WeatherData(
                    condition: WeatherCondition(from: weather.currentWeather.condition),
                    temperature: weather.currentWeather.temperature.value,
                    feelsLike: weather.currentWeather.apparentTemperature.value,
                    humidity: weather.currentWeather.humidity,
                    windSpeed: weather.currentWeather.wind.speed.value
                )
                
                self.currentWeather = weatherData
                self.isLoading = false
            } catch {
                self.error = error
                self.isLoading = false
                print("Weather fetch error: \(error.localizedDescription)")
            }
        }
        
        // Set a timeout
        let deadline: DispatchTime = .now() + 10
        
        DispatchQueue.main.asyncAfter(deadline: deadline) { [weak self] in
            guard let self = self else { return }
            
            if self.isLoading {
                task.cancel()
                self.isLoading = false
                self.error = NSError(
                    domain: "WeatherService",
                    code: -1,
                    userInfo: [NSLocalizedDescriptionKey: "Request timed out"]
                )
            }
        }
    }
}
