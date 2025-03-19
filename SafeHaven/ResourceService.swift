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
    
    // Dictionary mapping resource categories to search queries
    private let categoryQueries: [ResourceCategory: String] = [
        .shelter: "homeless shelter",
        .food: "food bank",
        .healthcare: "health clinic hospital",
        .mentalHealth: "mental health services counseling",
        .addiction: "addiction recovery",
        .legal: "legal aid",
        .employment: "employment center",
        .transportation: "public transportation",
        .family: "family support services",
        .education: "education assistance"
    ]
    
    func fetchResources(category: ResourceCategory = .all, near location: CLLocation? = nil, radius: Double = 5000, completion: (() -> Void)? = nil) {
        isLoading = true
        resources = []
        
        guard let location = location else {
            // If no location is provided, use a default location or show an error
            self.isLoading = false
            self.errorMessage = "Location not available"
            completion?()
            return
        }
        
        // If "all" category is selected, fetch multiple categories in sequence
        if category == .all {
            let categoriesToFetch = Array(categoryQueries.keys.prefix(5)) // Limit to 5 categories
            fetchNextCategory(categories: categoriesToFetch, location: location, radius: radius) {
                completion?()
            }
        } else {
            fetchSingleCategory(category: category, location: location, radius: radius) {
                completion?()
            }
        }
    }
    
    private func fetchNextCategory(categories: [ResourceCategory], location: CLLocation, radius: Double, index: Int = 0, completion: @escaping () -> Void) {
        // Base case: if we've processed all categories, stop
        if index >= categories.count {
            DispatchQueue.main.async {
                self.isLoading = false
                completion()
            }
            return
        }
        
        let category = categories[index]
        
        // Create a search request for the current category
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = categoryQueries[category] ?? category.rawValue
        request.region = MKCoordinateRegion(
            center: location.coordinate,
            latitudinalMeters: radius,
            longitudinalMeters: radius
        )
        
        // Perform the search
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
                // Convert MKMapItems to ResourceLocation objects and add to our resources
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
            
            // Continue with the next category
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { // Small delay to avoid rate limiting
                self.fetchNextCategory(categories: categories, location: location, radius: radius, index: index + 1, completion: completion)
            }
        }
    }
    
    private func fetchSingleCategory(category: ResourceCategory, location: CLLocation, radius: Double, completion: @escaping () -> Void) {
        // Create a search request for the specified category
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = categoryQueries[category] ?? category.rawValue
        request.region = MKCoordinateRegion(
            center: location.coordinate,
            latitudinalMeters: radius,
            longitudinalMeters: radius
        )
        
        // Perform the search
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
                
                // Convert MKMapItems to ResourceLocation objects
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
