import Foundation
import CoreLocation
import MapKit
import SwiftUI

class ResourceService: ObservableObject {
    @Published var resources: [ResourceLocation] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // Cache resources by category to reduce API calls
    private var resourceCache: [ResourceCategory: [ResourceLocation]] = [:]
    private var lastCacheUpdateTime: [ResourceCategory: Date] = [:]
    private let cacheExpirationTime: TimeInterval = 1800 // 30 minutes
    
    // Default cities for when location services are disabled
    let defaultCities: [DefaultLocation] = [
        DefaultLocation(name: "New York", location: CLLocation(latitude: 40.7128, longitude: -74.0060)),
        DefaultLocation(name: "Los Angeles", location: CLLocation(latitude: 34.0522, longitude: -118.2437)),
        DefaultLocation(name: "Chicago", location: CLLocation(latitude: 41.8781, longitude: -87.6298)),
        DefaultLocation(name: "Houston", location: CLLocation(latitude: 29.7604, longitude: -95.3698)),
        DefaultLocation(name: "Phoenix", location: CLLocation(latitude: 33.4484, longitude: -112.0740)),
        DefaultLocation(name: "Philadelphia", location: CLLocation(latitude: 39.9526, longitude: -75.1652)),
        DefaultLocation(name: "San Antonio", location: CLLocation(latitude: 29.4241, longitude: -98.4936)),
        DefaultLocation(name: "San Diego", location: CLLocation(latitude: 32.7157, longitude: -117.1611)),
        DefaultLocation(name: "Dallas", location: CLLocation(latitude: 32.7767, longitude: -96.7970)),
        DefaultLocation(name: "San Francisco", location: CLLocation(latitude: 37.7749, longitude: -122.4194))
    ]

    // User's selected default city
    @Published var selectedCity: DefaultLocation? = nil
    
    // Rest of the ResourceService code follows...
    // Enhanced and broadened category queries for better results
    private let categoryQueries: [ResourceCategory: String] = [
        .all: "help assistance services community resources support aid outreach social services center",
        .shelter: "homeless shelter housing emergency transitional lodging accommodation motel hotel temporary home",
        .food: "food bank pantry meals soup kitchen free grocery meal program hunger assistance snap ebt food stamps",
        .healthcare: "clinic hospital medical health doctor urgent care free clinic community health medical assistance medicaid",
        .mentalHealth: "counseling therapy mental health crisis psychiatrist psychology support group depression anxiety trauma",
        .substanceSupport: "addiction recovery rehab substance treatment alcohol drug detox sober AA NA sobriety",
        .crisis: "crisis center emergency hotline suicide prevention domestic violence abuse victim services emergency assistance",
        .legalAid: "legal aid attorney law assistance rights lawyer legal services court help advocate paralegal pro bono",
        .employment: "job employment career workforce training unemployment job search resume career center vocational",
        .family: "family children youth services childcare parenting family support head start WIC children assistance",
        .domesticViolence: "domestic violence shelter abuse victim services protection safety women's shelter safe house",
        .transportation: "transportation bus fare ride transit assistance rideshare car voucher gas voucher metro subway",
        .lgbtq: "LGBTQ LGBT gay lesbian transgender queer support center pride resource community",
        .veterans: "veteran VA military service member deployment benefits disability",
        .education: "education GED ESL adult learning classroom tutor school college university",
        .youthServices: "youth teen children youth center after school daycare child services juvenile",
        .immigration: "immigration immigrant refugee asylum documentation citizenship green card visa deportation"
    ]
    
    func fetchResources(category: ResourceCategory = .all, near location: CLLocation? = nil, radius: Double = 20000, completion: (() -> Void)? = nil) {
        // Check if we need to show loading indicators
        let showLoading = resources.isEmpty || resourceCache.isEmpty
        if showLoading {
            isLoading = true
        }
        
        // Clear previous results if visible
        DispatchQueue.main.async {
            self.resources = []
        }
        
        // Determine which location to use
        let locationToUse: CLLocation
        if let location = location {
            // Use the provided location if available
            locationToUse = location
        } else if let selected = selectedCity {
            // Fall back to the selected city if no location provided
            locationToUse = selected.location
            print("Using selected city location: \(selected.name)")
        } else {
            // Default to San Francisco if nothing else is available
            locationToUse = defaultCities[9].location // San Francisco
            print("Using default location (San Francisco)")
        }
        
        // Check if we have a cached result that's still valid
        if let cachedResources = resourceCache[category],
           let lastUpdate = lastCacheUpdateTime[category],
           Date().timeIntervalSince(lastUpdate) < cacheExpirationTime,
           !cachedResources.isEmpty {
            
            print("Using cached resources for category: \(category.rawValue) (\(cachedResources.count) resources)")
            DispatchQueue.main.async {
                self.resources = cachedResources
                self.isLoading = false
                completion?()
            }
            return
        }
        
        print("Fetching resources for category: \(category.rawValue) near \(locationToUse.coordinate.latitude), \(locationToUse.coordinate.longitude)")
        
        // If "all" category is selected, fetch multiple categories in sequence
        if category == .all {
            // Make sure we fetch all categories with relevant services
            var categoriesToFetch = Array(categoryQueries.keys)
            // Ensure we're not fetching .all twice
            if let index = categoriesToFetch.firstIndex(of: .all) {
                categoriesToFetch.remove(at: index)
            }
            
            // Always include high-priority categories
            if !categoriesToFetch.contains(.shelter) { categoriesToFetch.append(.shelter) }
            if !categoriesToFetch.contains(.food) { categoriesToFetch.append(.food) }
            if !categoriesToFetch.contains(.healthcare) { categoriesToFetch.append(.healthcare) }
            if !categoriesToFetch.contains(.crisis) { categoriesToFetch.append(.crisis) }
            
            print("Will fetch these categories: \(categoriesToFetch.map { $0.rawValue }.joined(separator: ", "))")
            
            // Use increased radius for "all" to get more results
            fetchNextCategory(categories: categoriesToFetch, location: locationToUse, radius: radius * 1.2) {
                print("All categories fetched, found \(self.resources.count) total resources")
                
                // Cache the comprehensive results
                self.resourceCache[.all] = self.resources
                self.lastCacheUpdateTime[.all] = Date()
                
                DispatchQueue.main.async {
                    self.isLoading = false
                }
                
                completion?()
            }
        } else {
            // Add a supplementary query if it's a regular category
            fetchSingleCategory(category: category, location: locationToUse, radius: radius) {
                print("Category \(category.rawValue) fetched, found \(self.resources.count) resources")
                
                // If few results, try a broader search automatically
                if self.resources.count < 5 {
                    print("Found only \(self.resources.count) results for \(category.rawValue), trying broader search")
                    self.broadenCategorySearch(category: category, location: locationToUse, radius: radius * 1.5) {
                        self.resourceCache[category] = self.resources
                        self.lastCacheUpdateTime[category] = Date()
                        completion?()
                    }
                } else {
                    self.resourceCache[category] = self.resources
                    self.lastCacheUpdateTime[category] = Date()
                    completion?()
                }
            }
        }
    }
    
    // Supplementary search with broadened query to get more results for a specific category
    private func broadenCategorySearch(category: ResourceCategory, location: CLLocation, radius: Double, completion: @escaping () -> Void) {
        // Create a broadened query based on keywords
        let keywords = category.searchKeywords.prefix(5).joined(separator: " OR ")
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = keywords
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
                print("Error in supplementary search: \(error.localizedDescription)")
                completion()
                return
            }
            
            guard let response = response, !response.mapItems.isEmpty else {
                print("No additional results found in supplementary search")
                completion()
                return
            }
            
            // Create new resource locations
            let additionalResources = response.mapItems.map { item in
                ResourceLocation(
                    id: "\(category.rawValue)-broad-\(item.placemark.coordinate.latitude)-\(item.placemark.coordinate.longitude)",
                    name: item.name ?? "Unknown Location",
                    category: category,
                    address: self.formatAddress(item.placemark),
                    phoneNumber: item.phoneNumber ?? "No phone available",
                    description: "A local resource that may provide \(category.rawValue.lowercased()) services.",
                    coordinate: item.placemark.coordinate,
                    icon: category.icon,
                    website: item.url?.absoluteString,
                    hours: nil,
                    services: [category.rawValue]
                )
            }
            
            print("Found \(additionalResources.count) additional resources in supplementary search")
            
            // Add these resources to the existing set, avoiding duplicates
            DispatchQueue.main.async {
                // Create a set of existing coordinates to avoid duplicates
                let existingCoordinates = Set(self.resources.map {
                    "\(Int($0.coordinate.latitude * 1000)),\(Int($0.coordinate.longitude * 1000))"
                })
                
                // Filter out resources at the same locations
                let uniqueNewResources = additionalResources.filter { resource in
                    let coordKey = "\(Int(resource.coordinate.latitude * 1000)),\(Int(resource.coordinate.longitude * 1000))"
                    return !existingCoordinates.contains(coordKey)
                }
                
                self.resources.append(contentsOf: uniqueNewResources)
                print("Total resources after supplementary search: \(self.resources.count)")
                completion()
            }
        }
    }
    
    // Modified searchAnyPlace to use default location when location is nil
    func searchAnyPlace(query: String, near location: CLLocation? = nil, radius: Double = 25000, completion: (() -> Void)? = nil) {
        isLoading = true
        
        // Clear previous results
        DispatchQueue.main.async {
            self.resources = []
        }
        
        // Determine which location to use
        let locationToUse: CLLocation
        if let location = location {
            // Use the provided location if available
            locationToUse = location
        } else if let selected = selectedCity {
            // Fall back to the selected city if no location provided
            locationToUse = selected.location
            print("Using selected city location for search: \(selected.name)")
        } else {
            // Default to San Francisco if nothing else is available
            locationToUse = defaultCities[9].location // San Francisco
            print("Using default location for search (San Francisco)")
        }
        
        // Generate search cache key (simplified query + region)
        let simplifiedQuery = query.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        let cacheKey = "search-\(simplifiedQuery)-\(Int(locationToUse.coordinate.latitude*100))-\(Int(locationToUse.coordinate.longitude*100))"
        
        // Check search cache using a custom key
        if let cachedResults = getCachedSearchResults(for: simplifiedQuery, near: locationToUse),
           !cachedResults.isEmpty {
            
            print("Using cached search results for '\(query)' (\(cachedResults.count) results)")
            DispatchQueue.main.async {
                self.resources = cachedResults
                self.isLoading = false
                completion?()
            }
            return
        }
            
        // Enhance search query for better results
        let enhancedQuery = query + " assistance services support resources help community center"
            
        print("Searching for: \"\(enhancedQuery)\" near \(locationToUse.coordinate.latitude), \(locationToUse.coordinate.longitude)")
            
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = enhancedQuery
        request.region = MKCoordinateRegion(
            center: locationToUse.coordinate,
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
                    self.tryBroaderSearch(originalQuery: query, location: locationToUse, radius: radius * 1.8, completion: completion)
                    return
                }
                    
                print("Found \(response.mapItems.count) results for query: \(enhancedQuery)")
                    
                // Convert MKMapItems to ResourceLocation objects
                let searchResults = response.mapItems.map { item in
                    // Try to determine a more specific category based on place name
                    let itemCategory = determineCategoryFromSearch(query, placeName: item.name ?? "")
                    
                    // Use the cache key in the ID to help with future caching
                    let resourceId = "search-\(simplifiedQuery)-\(item.placemark.coordinate.latitude)-\(item.placemark.coordinate.longitude)"
                        
                    return ResourceLocation(
                        id: resourceId,
                        name: item.name ?? "Unknown Location",
                        category: itemCategory != .all ? itemCategory : queryCategory,
                        address: self.formatAddress(item.placemark),
                        phoneNumber: item.phoneNumber ?? "No phone available",
                        description: "Search result for '\(query)'",
                        coordinate: item.placemark.coordinate,
                        icon: (itemCategory != .all ? itemCategory : queryCategory).icon,
                        website: item.url?.absoluteString,
                        hours: nil,
                        services: [query]
                    )
                }
                
                self.resources = searchResults
                
                // Cache the search results in a custom cache slot
                self.cacheSearchResults(searchResults, for: simplifiedQuery)
                
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
            for keyword in category.searchKeywords.prefix(5) {
                if lowerQuery.contains(keyword.lowercased()) {
                    // If we find a relevant keyword, add the category's top keywords
                    broadTerms.append(contentsOf: category.searchKeywords.prefix(3))
                    // Also add the category name
                    broadTerms.append(category.rawValue)
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
        
        // Generate broad search cache key
        let simplifiedQuery = originalQuery.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
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
                let broadSearchResults = response.mapItems.map { item in
                    // Try to determine a more specific category
                    let itemCategory = determineCategoryFromSearch("assistance services", placeName: item.name ?? "")
                    
                    return ResourceLocation(
                        id: "search-broad-\(simplifiedQuery)-\(item.placemark.coordinate.latitude)-\(item.placemark.coordinate.longitude)",
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
                
                self.resources = broadSearchResults
                
                // Cache the search results using a special broad search key
                self.cacheSearchResults(broadSearchResults, for: "broad-" + simplifiedQuery)
                
                completion?()
            }
        }
    }
    
    // Cache management for search results
    private func cacheSearchResults(_ results: [ResourceLocation], for query: String) {
        // Store with a custom key in resourceCache
        let cacheKey = ResourceCategory.all
        var allSearchResults = resourceCache[cacheKey] ?? []
        
        // Remove any existing results with the same search query
        allSearchResults.removeAll { resource in
            resource.id.contains(query)
        }
        
        // Add new results and update the cache
        allSearchResults.append(contentsOf: results)
        resourceCache[cacheKey] = allSearchResults
        lastCacheUpdateTime[cacheKey] = Date()
    }
    
    // Retrieve cached search results
    private func getCachedSearchResults(for query: String, near location: CLLocation) -> [ResourceLocation]? {
        guard let allResources = resourceCache[.all],
              let lastUpdate = lastCacheUpdateTime[.all],
              Date().timeIntervalSince(lastUpdate) < cacheExpirationTime / 2 else { // Shorter expiration for searches
            return nil
        }
        
        // Filter resources that match this search query
        let matchingResources = allResources.filter { resource in
            resource.id.contains(query)
        }
        
        // Only return cache if we found something
        return matchingResources.isEmpty ? nil : matchingResources
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
        
        // Check if we have a cached result for this specific category
        if let cachedResources = resourceCache[category],
           let lastUpdate = lastCacheUpdateTime[category],
           Date().timeIntervalSince(lastUpdate) < cacheExpirationTime,
           !cachedResources.isEmpty {
           
            print("Using cached resources for category: \(category.rawValue) (\(cachedResources.count) resources)")
            
            // Add the cached resources to our result set
            DispatchQueue.main.async {
                self.resources.append(contentsOf: cachedResources)
                // Continue with next category
                self.fetchNextCategory(categories: categories, location: location, radius: radius, index: index + 1, completion: completion)
            }
            return
        }
        
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
                    
                    // Cache this category's results
                    self.resourceCache[category] = newResources
                    self.lastCacheUpdateTime[category] = Date()
                    
                    DispatchQueue.main.async {
                        self.resources.append(contentsOf: newResources)
                        print("Total resources so far: \(self.resources.count)")
                    }
                }
            }
            
            // Add a slight delay between requests to prevent rate limiting
            let delay: TimeInterval = self.categoryQueries.count > 5 ? 0.3 : 0.1
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                self.fetchNextCategory(categories: categories, location: location, radius: radius, index: index + 1, completion: completion)
            }
        }
    }
    
    private func fetchSingleCategory(category: ResourceCategory, location: CLLocation, radius: Double, completion: @escaping () -> Void) {
        // Use a query that works best for this category
        let query = categoryQueries[category] ?? category.rawValue
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
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
                    completion()
                    return
                }
                
                guard let response = response else {
                    self.errorMessage = "No results found"
                    completion()
                    return
                }
                
                let categoryResources = response.mapItems.map { item in
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
                
                self.resources = categoryResources
                completion()
            }
        }
    }
    
    // Clears all cached resources
    func clearCache() {
        resourceCache = [:]
        lastCacheUpdateTime = [:]
        print("Resource cache cleared")
    }
    
    // Clears cache for a specific category
    func clearCache(for category: ResourceCategory) {
        resourceCache[category] = nil
        lastCacheUpdateTime[category] = nil
        print("Resource cache cleared for category: \(category.rawValue)")
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
