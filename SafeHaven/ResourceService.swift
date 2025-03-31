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
    // Enhanced category queries for better results
        private let categoryQueries: [ResourceCategory: String] = [
            .all: "help assistance services community resources support",
            .shelter: "homeless shelter housing emergency transitional",
            .food: "food bank pantry meals soup kitchen free grocery",
            .healthcare: "clinic hospital medical health doctor urgent care",
            .mentalHealth: "counseling therapy mental health crisis psychiatrist",
            .substanceSupport: "addiction recovery rehab substance treatment",
            .crisis: "crisis center emergency hotline suicide prevention",
            .legalAid: "legal aid attorney law assistance rights",
            .employment: "job employment career workforce training",
            .family: "family children youth services childcare",
            .domesticViolence: "domestic violence shelter abuse victim services",
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
            
            print("Fetching resources for category: \(category.rawValue) near \(location.coordinate.latitude), \(location.coordinate.longitude)")
            
            // If "all" category is selected, fetch multiple categories in sequence
            if category == .all {
                // Make sure we fetch all categories, including .all which contains general resources
                var categoriesToFetch = Array(categoryQueries.keys)
                // Ensure we're not fetching .all twice
                if let index = categoriesToFetch.firstIndex(of: .all) {
                    categoriesToFetch.remove(at: index)
                }
                // Add key categories we want to make sure we include
                if !categoriesToFetch.contains(.shelter) { categoriesToFetch.append(.shelter) }
                if !categoriesToFetch.contains(.food) { categoriesToFetch.append(.food) }
                if !categoriesToFetch.contains(.healthcare) { categoriesToFetch.append(.healthcare) }
                
                print("Will fetch these categories: \(categoriesToFetch.map { $0.rawValue }.joined(separator: ", "))")
                
                fetchNextCategory(categories: categoriesToFetch, location: location, radius: radius) {
                    print("All categories fetched, found \(self.resources.count) total resources")
                    completion?()
                }
            } else {
                fetchSingleCategory(category: category, location: location, radius: radius) {
                    print("Category \(category.rawValue) fetched, found \(self.resources.count) resources")
                    completion?()
                }
            }
        }
    
    // Enhanced search function with broader results
    func searchAnyPlace(query: String, near location: CLLocation, radius: Double = 25000, completion: (() -> Void)? = nil) {
            isLoading = true
            resources = []
            
            // Enhance search query for better results
            let enhancedQuery = query + " assistance services support resources help"
            
            print("Searching for: \"\(enhancedQuery)\" near \(location.coordinate.latitude), \(location.coordinate.longitude)")
            
            let request = MKLocalSearch.Request()
            request.naturalLanguageQuery = enhancedQuery
            request.region = MKCoordinateRegion(
                center: location.coordinate,
                latitudinalMeters: radius,
                longitudinalMeters: radius
            )
            
            // Try to determine a specific category based on the search query
            let possibleCategory = determineCategoryFromSearch(query, placeName: "")
            let queryCategory = possibleCategory != .all ? possibleCategory : .all
            
            let search = MKLocalSearch(request: request)
            search.start { [weak self] response, error in
                DispatchQueue.main.async {
                    guard let self = self else { return }
                    
                    if let error = error {
                        self.errorMessage = error.localizedDescription
                        print("Search error: \(error.localizedDescription)")
                        self.isLoading = false
                        completion?()
                        return
                    }
                    
                    guard let response = response, !response.mapItems.isEmpty else {
                        // If no results found with the enhanced query, try a broader search
                        print("No results found for query: \(enhancedQuery). Trying broader search...")
                        self.tryBroaderSearch(originalQuery: query, location: location, radius: radius * 1.5, completion: completion)
                        return
                    }
                    
                    print("Found \(response.mapItems.count) results for query: \(enhancedQuery)")
                    
                    // Convert MKMapItems to ResourceLocation objects
                    self.resources = response.mapItems.map { item in
                        // Try to determine a more specific category based on place name
                        let itemCategory = determineCategoryFromSearch(query, placeName: item.name ?? "")
                        
                        return ResourceLocation(
                            id: "search-\(item.placemark.coordinate.latitude)-\(item.placemark.coordinate.longitude)",
                            name: item.name ?? "Unknown Location",
                            category: itemCategory != .all ? itemCategory : queryCategory,
                            address: self.formatAddress(item.placemark),
                            phoneNumber: item.phoneNumber ?? "No phone available",
                            description: "Search result for '\(query)'",
                            coordinate: item.placemark.coordinate,
                            icon: itemCategory.icon,
                            website: item.url?.absoluteString,
                            hours: nil,
                            services: [query]
                        )
                    }
                    
                    self.isLoading = false
                    completion?()
                }
            }
        }
        
        // Try a broader search if initial search returns no results
        private func tryBroaderSearch(originalQuery: String, location: CLLocation, radius: Double, completion: (() -> Void)? = nil) {
            // Select some general terms based on the original query
            var broadTerms = ["community resources", "assistance", "services", "support"]
            
            // Try to match original query to categories and add related terms
            let lowerQuery = originalQuery.lowercased()
            for category in ResourceCategory.allCases {
                for keyword in category.searchKeywords.prefix(3) {
                    if lowerQuery.contains(keyword.lowercased()) {
                        // If we find a relevant keyword, add the category's top keywords
                        broadTerms.append(contentsOf: category.searchKeywords.prefix(2))
                        break
                    }
                }
            }
            
            // Join with OR to make search broader
            let broadQuery = broadTerms.joined(separator: " OR ")
            print("Trying broader search: \(broadQuery)")
            
            let request = MKLocalSearch.Request()
            request.naturalLanguageQuery = broadQuery
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
                        print("Broader search error: \(error.localizedDescription)")
                        completion?()
                        return
                    }
                    
                    guard let response = response, !response.mapItems.isEmpty else {
                        self.errorMessage = "No results found"
                        print("No results found for broader search either")
                        completion?()
                        return
                    }
                    
                    print("Broader search found \(response.mapItems.count) results")
                    
                    // Convert MKMapItems to ResourceLocation objects
                    self.resources = response.mapItems.map { item in
                        // Try to determine a more specific category
                        let itemCategory = determineCategoryFromSearch("assistance services", placeName: item.name ?? "")
                        
                        return ResourceLocation(
                            id: "search-\(item.placemark.coordinate.latitude)-\(item.placemark.coordinate.longitude)",
                            name: item.name ?? "Unknown Location",
                            category: itemCategory,
                            address: self.formatAddress(item.placemark),
                            phoneNumber: item.phoneNumber ?? "No phone available",
                            description: "Resource that may provide assistance",
                            coordinate: item.placemark.coordinate,
                            icon: itemCategory.icon,
                            website: item.url?.absoluteString,
                            hours: nil,
                            services: ["assistance"]
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
                    // Remove any potential duplicates by ID
                    let uniqueResources = Dictionary(grouping: self.resources, by: { $0.id })
                        .compactMap { $0.value.first }
                    self.resources = uniqueResources
                    
                    print("Finished fetching all categories. Total unique resources: \(self.resources.count)")
                    completion()
                }
                return
            }
            
            let category = categories[index]
            
            // Skip if no query defined for this category
            guard let query = categoryQueries[category] ?? (category == .all ? "resources help assistance" : nil) else {
                print("Skipping category \(category.rawValue) - no query defined")
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.fetchNextCategory(categories: categories, location: location, radius: radius, index: index + 1, completion: completion)
                }
                return
            }
            
            print("Fetching category \(index+1)/\(categories.count): \(category.rawValue) with query: \(query)")
            
            let request = MKLocalSearch.Request()
            request.naturalLanguageQuery = query
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
                    let categoryResults = response.mapItems.count
                    print("Found \(categoryResults) results for category \(category.rawValue)")
                    
                    if categoryResults > 0 {
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
                            print("Total resources so far: \(self.resources.count)")
                        }
                    }
                }
                
                // Add a slight delay between requests to prevent rate limiting
                let delay: TimeInterval = categoryQueries.count > 5 ? 0.3 : 0.1
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
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
