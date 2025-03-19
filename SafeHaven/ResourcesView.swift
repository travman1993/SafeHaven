import SwiftUI
import CoreLocation
import MapKit

struct ResourcesView: View {
    @StateObject private var locationManager = LocationManager()
    @StateObject private var resourceService = ResourceService()
    
    @State private var selectedCategory: ResourceCategory = .all
    @State private var searchText = ""
    @State private var viewMode: ViewMode = .list
    @State private var selectedResource: ResourceLocation?
    @State private var isLoading = false
    
    enum ViewMode {
        case map, list
    }
    
    var filteredResources: [ResourceLocation] {
        resourceService.resources.filter { resource in
            (selectedCategory == .all || resource.category == selectedCategory) &&
            (searchText.isEmpty ||
             resource.name.localizedCaseInsensitiveContains(searchText) ||
             resource.category.rawValue.localizedCaseInsensitiveContains(searchText))
        }
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search and Filter Section
                VStack(spacing: 12) {
                    // Search Bar
                    SearchBar(text: $searchText, placeholder: "Search resources...")
                        .padding(.horizontal)
                    
                    // Category Scroll View
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(ResourceCategory.allCases) { category in
                                CategoryChip(
                                    title: category.rawValue,
                                    icon: category.icon,
                                    isSelected: selectedCategory == category,
                                    color: category.color
                                ) {
                                    // Prevent multiple reloads when tapping the same category
                                    if selectedCategory != category {
                                        selectedCategory = category
                                        loadResources()
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // View Mode Toggle
                    Picker("View Mode", selection: $viewMode) {
                        Image(systemName: "list.bullet").tag(ViewMode.list)
                        Image(systemName: "map").tag(ViewMode.map)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal)
                }
                .padding(.vertical)
                .background(Color(hex: "F5F7FA"))
                
                // Content View
                ZStack {
                    switch viewMode {
                    case .map:
                        MapContentView(
                            resources: filteredResources,
                            userLocation: locationManager.userLocation,
                            selectedResource: $selectedResource
                        )
                    case .list:
                        ListContentView(
                            resources: filteredResources,
                            selectedResource: $selectedResource
                        )
                    }
                    
                    // Loading Indicator
                    if isLoading {
                        ProgressView()
                            .scaleEffect(1.5)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(Color.black.opacity(0.1))
                    }
                }
            }
            .navigationTitle("Resources")
            .navigationBarTitleDisplayMode(.inline)
        }
        .sheet(item: $selectedResource) { resource in
            ResourceDetailView(resource: resource)
        }
        .onAppear {
            // Only request permissions and load resources if we don't already have them
            if locationManager.authorizationStatus == .notDetermined {
                locationManager.requestWhenInUseAuthorization()
            }
            
            if resourceService.resources.isEmpty {
                loadResources()
            }
        }
    }
    
    private func loadResources() {
        guard !isLoading else { return } // Prevent multiple simultaneous loads
        
        isLoading = true
        
        if let userLocation = locationManager.userLocation {
            let location = CLLocation(latitude: userLocation.latitude, longitude: userLocation.longitude)
            
            // Add a small delay to ensure UI updates properly
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                resourceService.fetchResources(category: selectedCategory, near: location) {
                    isLoading = false
                }
            }
        } else {
            // If location not available, try to use a default location or ask for permission
            if locationManager.authorizationStatus == .authorizedWhenInUse ||
               locationManager.authorizationStatus == .authorizedAlways {
                // Location permission granted but no location yet - start updates
                locationManager.startUpdatingLocation()
                
                // Wait briefly then check again
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    if let userLocation = locationManager.userLocation {
                        let location = CLLocation(latitude: userLocation.latitude, longitude: userLocation.longitude)
                        resourceService.fetchResources(category: selectedCategory, near: location) {
                            isLoading = false
                        }
                    } else {
                        // Use a default location if we still don't have one
                        let defaultLocation = CLLocation(latitude: 37.7749, longitude: -122.4194) // San Francisco
                        resourceService.fetchResources(category: selectedCategory, near: defaultLocation) {
                            isLoading = false
                        }
                    }
                }
            } else {
                // No authorization yet - use default location
                let defaultLocation = CLLocation(latitude: 37.7749, longitude: -122.4194) // San Francisco
                resourceService.fetchResources(category: selectedCategory, near: defaultLocation) {
                    isLoading = false
                }
            }
        }
    }
}

// MARK: - Update ResourceService to include a completion handler
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
        // ... other categories ...
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
            var categoriesToFetch = Array(categoryQueries.keys.prefix(5)) // Limit to 5 categories
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
