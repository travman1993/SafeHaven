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
    
    // Enhanced and broadened category queries for better results
    private let categoryQueries: [ResourceCategory: String] = [
        .all: "community resources assistance services support help aid outreach social services center nonprofit",
        .shelter: "shelter housing homeless emergency transitional accommodation lodging motel",
        .food: "food pantry meals soup kitchen free grocery food bank assistance snap ebt",
        .healthcare: "health clinic hospital medical doctor care community medicaid medicare",
        .mentalHealth: "mental health counseling therapy psychiatrist psychology support depression anxiety",
        .substanceSupport: "substance abuse addiction recovery treatment alcohol drug rehab detox",
        .crisis: "crisis center emergency hotline suicide prevention domestic violence abuse victim",
        .legalAid: "legal aid attorney lawyer assistance rights advocate court help representation",
        .employment: "job employment career workforce training vocational resume placement",
        .education: "education school GED ESL adult learning tutoring college scholarship",
        .transportation: "transportation bus transit ride assistance gas voucher carpool",
        .family: "family children youth services childcare parenting support assistance",
        .domesticViolence: "domestic violence abuse shelter safety protection victim services",
        .lgbtq: "LGBTQ LGBT gay lesbian transgender queer support center community resources",
        .veterans: "veteran VA military service deployment benefits disability assistance",
        .youthServices: "youth teen children center services program after school counseling",
        .immigration: "immigration immigrant refugee asylum citizenship visa green card",
        .financial: "financial assistance emergency cash bill pay utility rent counseling debt",
        .communityCenter: "community center neighborhood civic hub space cultural service multipurpose",
        .seniorServices: "senior elder older adult aging center care geriatric retired assistance",
        .disabilityServices: "disability services support resources ADA accessible adaptive intellectual",
        .childcare: "childcare daycare child care early childhood preschool babysitting",
        .utilities: "utility energy assistance water electric gas bill heat cooling payment",
        .clothing: "clothing clothes donation thrift store free bank closet attire",
        .internet: "internet broadband wifi hotspot digital computer technology access",
        .phoneServices: "phone telephone cell wireless free lifeline government assistance",
        .dental: "dental dentist teeth oral health clinic care services assistance",
        .vision: "vision eye glasses contacts exam care optometrist doctor eyeglasses",
        .prescriptions: "prescription medication medicine pharmacy assistance drug cost"
    ]
    
    func fetchResources(category: ResourceCategory = .all, near location: CLLocation? = nil, radius: Double = 20000, completion: (() -> Void)? = nil) {
        // Show loading indicator if resources are empty or it's a new category
        isLoading = true
        
        // Clear previous results to indicate loading state
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
        
        // For "All" category, we need a completely different approach
        if category == .all {
            // Start with a very general search for resources
            fetchAllResources(location: locationToUse, radius: radius, completion: completion)
        } else {
            // For specific categories, use the existing approach
            fetchSingleCategory(category: category, location: locationToUse, radius: radius) {
                print("Category \(category.rawValue) fetched, found \(self.resources.count) resources")
                
                // If few results, try a broader search automatically
                if self.resources.count < 5 {
                    print("Found only \(self.resources.count) results for \(category.rawValue), trying broader search")
                    self.broadenCategorySearch(category: category, location: locationToUse, radius: radius * 1.5) {
                        self.resourceCache[category] = self.resources
                        self.lastCacheUpdateTime[category] = Date()
                        
                        // Try backup search if still not enough results
                        if self.resources.count < 3 {
                            self.fetchBackupResults(category: category, location: locationToUse) {
                                self.isLoading = false
                                completion?()
                            }
                        } else {
                            self.isLoading = false
                            completion?()
                        }
                    }
                } else {
                    self.resourceCache[category] = self.resources
                    self.lastCacheUpdateTime[category] = Date()
                    self.isLoading = false
                    completion?()
                }
            }
        }
    }
    
    // Special method for "All" category to get many different types of resources
    private func fetchAllResources(location: CLLocation, radius: Double, completion: (() -> Void)? = nil) {
        // Clear previous resources
        resources = []
        
        // Define a diverse set of search terms that will find different types of resources
        let generalSearches = [
            "community resources assistance services help center",
            "social services support aid outreach nonprofit",
            "emergency services crisis shelter food health",
            "family assistance community center childcare support",
            "housing food assistance health services",
            "senior youth veterans disability services"
        ]
        
        let totalSearches = generalSearches.count
        var completedSearches = 0
        var allFoundResources: [ResourceLocation] = []
        
        // Function to check if all searches are complete
        func checkCompletion() {
            completedSearches += 1
            if completedSearches >= totalSearches {
                // Remove duplicates by ID
                let uniqueResources = Dictionary(grouping: allFoundResources) { $0.id }
                    .compactMap { $0.value.first }
                
                DispatchQueue.main.async {
                    self.resources = uniqueResources
                    self.resourceCache[.all] = uniqueResources
                    self.lastCacheUpdateTime[.all] = Date()
                    self.isLoading = false
                    print("All resources fetched, found \(uniqueResources.count) total unique resources")
                    completion?()
                }
            }
        }
        
        // Perform multiple searches in parallel
        for (index, searchTerm) in generalSearches.enumerated() {
            let request = MKLocalSearch.Request()
            request.naturalLanguageQuery = searchTerm
            request.resultTypes = .pointOfInterest
            request.region = MKCoordinateRegion(
                center: location.coordinate,
                latitudinalMeters: radius,
                longitudinalMeters: radius
            )
            
            let search = MKLocalSearch(request: request)
            search.start { [weak self] response, error in
                guard let self = self else {
                    checkCompletion()
                    return
                }
                
                if let error = error {
                    print("Error in general search \(index): \(error.localizedDescription)")
                    checkCompletion()
                    return
                }
                
                guard let response = response, !response.mapItems.isEmpty else {
                    print("No results found in general search \(index)")
                    checkCompletion()
                    return
                }
                
                print("Search \(index+1): Found \(response.mapItems.count) resources")
                
                // Convert map items to resources
                let newResources = response.mapItems.map { item in
                    // Try to determine an appropriate category based on place name and type
                    let itemCategory = self.determineBestCategory(for: item, with: searchTerm)
                    
                    return ResourceLocation(
                        id: "all-\(searchTerm.prefix(5))-\(item.placemark.coordinate.latitude)-\(item.placemark.coordinate.longitude)",
                        name: item.name ?? "Resource Location",
                        category: itemCategory,
                        address: self.formatAddress(item.placemark),
                        phoneNumber: item.phoneNumber ?? "No phone available",
                        description: "A local resource providing community services.",
                        coordinate: item.placemark.coordinate,
                        icon: itemCategory.icon,
                        website: item.url?.absoluteString,
                        hours: nil,
                        services: [itemCategory.rawValue]
                    )
                }
                
                // Add to our running list
                allFoundResources.append(contentsOf: newResources)
                checkCompletion()
            }
        }
        
        // Also collect resources from individual categories
        fetchRandomCategoryResources(location: location, radius: radius) { categoryResources in
            allFoundResources.append(contentsOf: categoryResources)
            
            // Force completion after a timeout in case other searches are taking too long
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                if completedSearches < totalSearches {
                    completedSearches = totalSearches // Force completion
                    
                    // Remove duplicates by ID
                    let uniqueResources = Dictionary(grouping: allFoundResources) { $0.id }
                        .compactMap { $0.value.first }
                    
                    DispatchQueue.main.async {
                        self.resources = uniqueResources
                        self.resourceCache[.all] = uniqueResources
                        self.lastCacheUpdateTime[.all] = Date()
                        self.isLoading = false
                        print("All resources fetched (with timeout), found \(uniqueResources.count) total resources")
                        completion?()
                    }
                }
            }
        }
    }
    
    // Fetch resources from a sampling of specific categories to add diversity to "All" results
    private func fetchRandomCategoryResources(location: CLLocation, radius: Double, completion: @escaping ([ResourceLocation]) -> Void) {
        // Get a selection of important categories
        let categoriesToFetch: [ResourceCategory] = [
            .shelter, .food, .healthcare, .crisis, .transportation,
            .family, .veterans, .lgbtq, .financial, .clothing
        ]
        
        var allCategoryResources: [ResourceLocation] = []
        var completedCategories = 0
        
        for category in categoriesToFetch {
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
                    completedCategories += 1
                    if completedCategories >= categoriesToFetch.count {
                        completion(allCategoryResources)
                    }
                    return
                }
                
                if let error = error {
                    print("Error fetching category \(category.rawValue): \(error.localizedDescription)")
                } else if let response = response, !response.mapItems.isEmpty {
                    print("Category \(category.rawValue): Found \(response.mapItems.count) resources")
                    
                    // Take up to 5 resources from each category to avoid overwhelming
                    let categoryResources = response.mapItems.prefix(5).map { item in
                        ResourceLocation(
                            id: "\(category.rawValue)-specific-\(item.placemark.coordinate.latitude)-\(item.placemark.coordinate.longitude)",
                            name: item.name ?? "Resource Location",
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
                    
                    allCategoryResources.append(contentsOf: categoryResources)
                }
                
                completedCategories += 1
                if completedCategories >= categoriesToFetch.count {
                    completion(allCategoryResources)
                }
            }
        }
    }
    
    // Determine the most likely category for a location
    private func determineBestCategory(for mapItem: MKMapItem, with searchQuery: String) -> ResourceCategory {
        let itemName = mapItem.name?.lowercased() ?? ""
        let query = searchQuery.lowercased()
        
        // Check for specific markers in the name
        if itemName.contains("shelter") || itemName.contains("housing") {
            return .shelter
        } else if itemName.contains("food") || itemName.contains("pantry") || itemName.contains("meal") {
            return .food
        } else if itemName.contains("health") || itemName.contains("clinic") || itemName.contains("medical") {
            return .healthcare
        } else if itemName.contains("mental") || itemName.contains("counseling") {
            return .mentalHealth
        } else if itemName.contains("substance") || itemName.contains("addiction") {
            return .substanceSupport
        } else if itemName.contains("crisis") || itemName.contains("emergency") {
            return .crisis
        } else if itemName.contains("legal") || itemName.contains("law") {
            return .legalAid
        } else if itemName.contains("community center") {
            return .communityCenter
        } else if itemName.contains("senior") || itemName.contains("elder") {
            return .seniorServices
        } else if itemName.contains("veteran") {
            return .veterans
        } else if itemName.contains("lgbtq") || itemName.contains("lgbt") {
            return .lgbtq
        } else if itemName.contains("youth") || itemName.contains("teen") {
            return .youthServices
        } else if itemName.contains("family") {
            return .family
        } else if itemName.contains("domestic") || itemName.contains("violence") {
            return .domesticViolence
        }
        
        // Check category keywords against the place name
        for category in ResourceCategory.allCases where category != .all {
            for keyword in category.searchKeywords.prefix(5) {
                if itemName.contains(keyword) || query.contains(keyword) {
                    return category
                }
            }
        }
        
        // Default categories based on common place types
        if itemName.contains("church") || itemName.contains("worship") || itemName.contains("religious") {
            return .communityCenter
        } else if itemName.contains("school") || itemName.contains("education") {
            return .education
        } else if itemName.contains("hospital") || itemName.contains("medical") {
            return .healthcare
        } else if itemName.contains("library") {
            return .communityCenter
        } else if itemName.contains("social service") || itemName.contains("human service") {
            return .communityCenter
        }
        
        // Default to community center which is the most general category
        return .communityCenter
    }
    
    // Backup search that uses category-related generic terms
    private func fetchBackupResults(category: ResourceCategory, location: CLLocation, completion: @escaping () -> Void) {
        // Use the category name and basic terms
        let searchTerms = category.rawValue.lowercased() + " assistance services support help resources"
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchTerms
        request.region = MKCoordinateRegion(
            center: location.coordinate,
            latitudinalMeters: 50000, // Very wide radius to find anything
            longitudinalMeters: 50000
        )
        
        let search = MKLocalSearch(request: request)
        search.start { [weak self] response, error in
            guard let self = self else {
                completion()
                return
            }
            
            if let error = error {
                print("Error in backup search: \(error.localizedDescription)")
                completion()
                return
            }
            
            guard let response = response, !response.mapItems.isEmpty else {
                print("No additional results found in backup search")
                completion()
                return
            }
            
            // Create new resource locations
            let additionalResources = response.mapItems.map { item in
                ResourceLocation(
                    id: "\(category.rawValue)-backup-\(item.placemark.coordinate.latitude)-\(item.placemark.coordinate.longitude)",
                    name: item.name ?? "Resource Location",
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
            
            print("Found \(additionalResources.count) backup resources")
            
            // Add these resources to the existing set
            DispatchQueue.main.async {
                // Filter out duplicates by checking coordinates
                let existingCoordinates = Set(self.resources.map {
                    "\(Int($0.coordinate.latitude * 1000)),\(Int($0.coordinate.longitude * 1000))"
                })
                
                // Filter out resources at the same locations
                let uniqueNewResources = additionalResources.filter { resource in
                    let coordKey = "\(Int(resource.coordinate.latitude * 1000)),\(Int(resource.coordinate.longitude * 1000))"
                    return !existingCoordinates.contains(coordKey)
                }
                
                self.resources.append(contentsOf: uniqueNewResources)
                self.resourceCache[category] = self.resources
                self.lastCacheUpdateTime[category] = Date()
                completion()
            }
        }
    }
    
    // Supplementary search with broadened query to get more results for a specific category
    private func broadenCategorySearch(category: ResourceCategory, location: CLLocation, radius: Double, completion: @escaping () -> Void) {
        // Create a broadened query based on keywords
        let keywords = (category.searchKeywords.prefix(8).joined(separator: " OR "))
        
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
    
    private func fetchSingleCategory(category: ResourceCategory, location: CLLocation, radius: Double, completion: @escaping () -> Void) {
        // Use a query that works best for this category
        let query = categoryQueries[category] ?? category.rawValue
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        request.resultTypes = .pointOfInterest
        request.region = MKCoordinateRegion(
            center: location.coordinate,
            latitudinalMeters: radius,
            longitudinalMeters: radius
        )
        
        let search = MKLocalSearch(request: request)
        search.start { [weak self] response, error in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
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
                        name: item.name ?? "Resource Location",
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
