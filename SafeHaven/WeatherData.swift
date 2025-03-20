//
//  WeatherData.swift
//  SafeHaven
//
//  Created by Travis Rodriguez on 3/12/25.
//

import Foundation

struct WeatherData {
    let condition: WeatherCondition
    let temperature: Double
    let feelsLike: Double
    let humidity: Double
    let windSpeed: Double
    
    var temperatureString: String {
        return String(format: "%.1f°F", temperature)
    }
    
    var feelsLikeString: String {
        return String(format: "%.1f°F", feelsLike)
    }
    
    var humidityString: String {
        return String(format: "%.0f%%", humidity * 100)
    }
    
    var windSpeedString: String {
        return String(format: "%.1f mph", windSpeed)
    }
}
