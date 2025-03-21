//
//  ResourceService.swift
//  SafeHaven
//
//  Created by Travis Rodriguez on 3/19/25.
//
import Foundation
import CoreLocation
import MapKit
import SwiftUI

class ResourceService: ObservableObject {
    @Published var resources: [ResourceLocation] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // Only include categories we're sure exist in your project
    private let categoryQueries: [ResourceCategory: String] = [
        .all: "help assistance services support",
        .shelter: "homeless shelter housing emergency",
        .food: "food bank pantry meals soup kitchen",
        .healthcare: "clinic hospital medical health doctor urgent care",
        .transportation: "transportation bus fare ride transit"
    ]
    
    func fetchResources(category: ResourceCategory = .all, near location: CLLocation? = nil, radius: Double = 15000, completion: (() -> Void)? = nil) {
        isLoading = true
        resources = []
        
        guard let location = location else {
            self.isLoading = false
            self.errorMessage = "Location not available"
            completion?()
            return
        }
        
        // If "all" category is selected, fetch multiple categories in sequence
        if category == .all {
            let categoriesToFetch = Array(categoryQueries.keys.filter { $0 != .all })
            fetchNextCategory(categories: categoriesToFetch, location: location, radius: radius) {
                completion?()
            }
        } else {
            fetchSingleCategory(category: category, location: location, radius: radius) {
                completion?()
            }
        }
    }
    
    // Enhanced search function with broader results
    func searchAnyPlace(query: String, near location: CLLocation, radius: Double = 25000, completion: (() -> Void)? = nil) {
        isLoading = true
        resources = []
        
        // Enhance search query for better results
        let enhancedQuery = query + " assistance services support help"
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = enhancedQuery
        request.region = MKCoordinateRegion(
            center: location.coordinate,
            latitudinalMeters: radius,
            longitudinalMeters: radius
        )
        
        let search = MKLocalSearch(request: request)
        search.start { [weak self] response, error in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                self.isLoading = false
                
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    print("Search error: \(error.localizedDescription)")
                    completion?()
                    return
                }
                
                guard let response = response else {
                    self.errorMessage = "No results found"
                    print("No results found for query: \(query)")
                    completion?()
                    return
                }
                
                print("Found \(response.mapItems.count) results for query: \(enhancedQuery)")
                
                // Convert MKMapItems to ResourceLocation objects
                self.resources = response.mapItems.map { item in
                    ResourceLocation(
                        id: "search-\(item.placemark.coordinate.latitude)-\(item.placemark.coordinate.longitude)",
                        name: item.name ?? "Unknown Location",
                        category: .all, // Default to "all" category for search results
                        address: self.formatAddress(item.placemark),
                        phoneNumber: item.phoneNumber ?? "No phone available",
                        description: "Search result for '\(query)'",
                        coordinate: item.placemark.coordinate,
                        icon: "mappin.circle",
                        website: item.url?.absoluteString,
                        hours: nil,
                        services: []
                    )
                }
                
                completion?()
            }
        }
    }
    
    private func fetchNextCategory(categories: [ResourceCategory], location: CLLocation, radius: Double, index: Int = 0, completion: @escaping () -> Void) {
        if index >= categories.count {
            DispatchQueue.main.async {
                self.isLoading = false
                completion()
            }
            return
        }
        
        let category = categories[index]
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = categoryQueries[category] ?? category.rawValue
        request.region = MKCoordinateRegion(
            center: location.coordinate,
            latitudinalMeters: radius,
            longitudinalMeters: radius
        )
        
        let search = MKLocalSearch(request: request)
        search.start { [weak self] response, error in
            guard let self = self else {
                completion()
                return
            }
            
            if let error = error {
                print("Error searching for \(category.rawValue): \(error.localizedDescription)")
            }
            
            if let response = response {
                let newResources = response.mapItems.map { item in
                    ResourceLocation(
                        id: "\(category.rawValue)-\(item.placemark.coordinate.latitude)-\(item.placemark.coordinate.longitude)",
                        name: item.name ?? "Unknown Location",
                        category: category,
                        address: self.formatAddress(item.placemark),
                        phoneNumber: item.phoneNumber ?? "No phone available",
                        description: "A local resource providing \(category.rawValue.lowercased()) services.",
                        coordinate: item.placemark.coordinate,
                        icon: category.icon,
                        website: item.url?.absoluteString,
                        hours: nil,
                        services: [category.rawValue]
                    )
                }
                
                DispatchQueue.main.async {
                    self.resources.append(contentsOf: newResources)
                }
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.fetchNextCategory(categories: categories, location: location, radius: radius, index: index + 1, completion: completion)
            }
        }
    }
    
    private func fetchSingleCategory(category: ResourceCategory, location: CLLocation, radius: Double, completion: @escaping () -> Void) {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = categoryQueries[category] ?? category.rawValue
        request.region = MKCoordinateRegion(
            center: location.coordinate,
            latitudinalMeters: radius,
            longitudinalMeters: radius
        )
        
        let search = MKLocalSearch(request: request)
        search.start { [weak self] response, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                    completion()
                    return
                }
                
                guard let response = response else {
                    self?.errorMessage = "No results found"
                    completion()
                    return
                }
                
                self?.resources = response.mapItems.map { item in
                    ResourceLocation(
                        id: "\(category.rawValue)-\(item.placemark.coordinate.latitude)-\(item.placemark.coordinate.longitude)",
                        name: item.name ?? "Unknown Location",
                        category: category,
                        address: self?.formatAddress(item.placemark) ?? "No address",
                        phoneNumber: item.phoneNumber ?? "No phone available",
                        description: "A local resource providing \(category.rawValue.lowercased()) services.",
                        coordinate: item.placemark.coordinate,
                        icon: category.icon,
                        website: item.url?.absoluteString,
                        hours: nil,
                        services: [category.rawValue]
                    )
                }
                
                completion()
            }
        }
    }
    
    private func formatAddress(_ placemark: MKPlacemark) -> String {
        var addressComponents: [String] = []
        
        if let subThoroughfare = placemark.subThoroughfare {
            addressComponents.append(subThoroughfare)
        }
        
        if let thoroughfare = placemark.thoroughfare {
            addressComponents.append(thoroughfare)
        }
        
        if let locality = placemark.locality {
            addressComponents.append(locality)
        }
        
        if let administrativeArea = placemark.administrativeArea {
            addressComponents.append(administrativeArea)
        }
        
        if let postalCode = placemark.postalCode {
            addressComponents.append(postalCode)
        }
        
        return addressComponents.joined(separator: ", ")
    }
}
