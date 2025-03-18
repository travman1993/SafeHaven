import Foundation
import SwiftUI
import CoreLocation
import MapKit

// MARK: - Resource Model
struct ResourceLocation: Identifiable, Hashable, Equatable {
    let id: String
    let name: String
    let category: ResourceCategory
    let address: String
    let phoneNumber: String
    let description: String
    let coordinate: CLLocationCoordinate2D
    let icon: String
    let website: String?
    let hours: String?
    let services: [String]

    // Hashable implementation
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(name)
        hasher.combine(category)
        hasher.combine(address)
        hasher.combine(phoneNumber)
    }

    // Equatable implementation
    static func == (lhs: ResourceLocation, rhs: ResourceLocation) -> Bool {
        return lhs.id == rhs.id &&
               lhs.name == rhs.name &&
               lhs.category == rhs.category &&
               lhs.address == rhs.address &&
               lhs.phoneNumber == rhs.phoneNumber
    }
}

// MARK: - Resource Category Enum
enum ResourceCategory: String, CaseIterable, Identifiable {
    case all = "All"
    case shelter = "Shelter"
    case food = "Food"
    case healthcare = "Healthcare"
    case mentalHealth = "Mental Health"
    case support = "Support"
    case legal = "Legal Aid"
    case financial = "Financial"
    case education = "Education"
    case childcare = "Childcare"
    case employment = "Employment"
    case transportation = "Transportation"
    case clothing = "Clothing"
    case veterans = "Veterans"
    case lgbtq = "LGBTQ+"
    case seniors = "Seniors"
    case disabilities = "Disabilities"
    case addiction = "Addiction"
    case domesticViolence = "Domestic Violence"
    case immigrants = "Immigrants"
    case youth = "Youth"
    case women = "Women"
    case men = "Men"
    
    var id: String { rawValue }

    var icon: String {
        switch self {
        case .all: return "square.grid.2x2.fill"
        case .shelter: return "house.fill"
        case .food: return "fork.knife"
        case .healthcare: return "cross.fill"
        case .mentalHealth: return "brain.head.profile"
        case .support: return "person.2.fill"
        case .legal: return "building.columns.fill"
        case .financial: return "dollarsign.circle.fill"
        case .education: return "book.fill"
        case .childcare: return "figure.and.child.holdinghands"
        case .employment: return "briefcase.fill"
        case .transportation: return "car.fill"
        case .clothing: return "tshirt.fill"
        case .veterans: return "shield.fill"
        case .lgbtq: return "person.fill.questionmark"
        case .seniors: return "figure.roll"
        case .disabilities: return "figure.roll.runningpace"
        case .addiction: return "pills.fill"
        case .domesticViolence: return "house.and.flag.fill"
        case .immigrants: return "globe.americas.fill"
        case .youth: return "figure.child"
        case .women: return "figure.dress"
        case .men: return "figure"
        }
    }

    var color: Color {
        switch self {
        case .all: return .gray
        case .shelter: return Color(hex: "6A89CC")
        case .food: return .green
        case .healthcare: return .red
        case .mentalHealth: return Color(hex: "9370DB") // Medium purple
        case .support: return .blue
        case .legal: return .purple
        case .financial: return .orange
        case .education: return .teal
        case .childcare: return Color(hex: "FF6B6B") // Coral
        case .employment: return Color(hex: "4A90E2") // Blue
        case .transportation: return Color(hex: "50C878") // Emerald
        case .clothing: return Color(hex: "FF7F50") // Coral
        case .veterans: return Color(hex: "4682B4") // Steel blue
        case .lgbtq: return Color(hex: "FF1493") // Deep pink
        case .seniors: return Color(hex: "DEB887") // Burlywood
        case .disabilities: return Color(hex: "20B2AA") // Light sea green
        case .addiction: return Color(hex: "9932CC") // Dark orchid
        case .domesticViolence: return Color(hex: "DC143C") // Crimson
        case .immigrants: return Color(hex: "32CD32") // Lime green
        case .youth: return Color(hex: "FFD700") // Gold
        case .women: return Color(hex: "FF69B4") // Hot pink
        case .men: return Color(hex: "1E90FF") // Dodger blue
        }
    }
}

// MARK: - Resource Service
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
        .support: "community support center",
        .legal: "legal aid services",
        .financial: "financial assistance",
        .education: "adult education center",
        .childcare: "childcare services",
        .employment: "employment center job services",
        .transportation: "transportation services",
        .clothing: "clothing donation center",
        .veterans: "veterans services",
        .lgbtq: "lgbtq support center",
        .seniors: "senior services assistance",
        .disabilities: "disability services support",
        .addiction: "addiction recovery services",
        .domesticViolence: "domestic violence shelter",
        .immigrants: "immigrant refugee services",
        .youth: "youth services center",
        .women: "women's services center",
        .men: "men's services support"
    ]
    
    func fetchResources(category: ResourceCategory = .all, near location: CLLocation? = nil, radius: Double = 5000) {
        isLoading = true
        resources = []
        
        guard let location = location else {
            // If no location is provided, use a default location or show an error
            self.isLoading = false
            self.errorMessage = "Location not available"
            return
        }
        
        // If "all" category is selected, fetch multiple categories in sequence
        if category == .all {
            var categoriesToFetch = Array(categoryQueries.keys.prefix(5)) // Limit to 5 categories to avoid too many requests
            fetchNextCategory(categories: categoriesToFetch, location: location, radius: radius)
        } else {
            fetchSingleCategory(category: category, location: location, radius: radius)
        }
    }
    
    private func fetchNextCategory(categories: [ResourceCategory], location: CLLocation, radius: Double, index: Int = 0) {
        // Base case: if we've processed all categories, stop
        if index >= categories.count {
            DispatchQueue.main.async {
                self.isLoading = false
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
            guard let self = self else { return }
            
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
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { // Small delay to avoid rate limiting
                self.fetchNextCategory(categories: categories, location: location, radius: radius, index: index + 1)
            }
        }
    }
    
    private func fetchSingleCategory(category: ResourceCategory, location: CLLocation, radius: Double) {
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
                    return
                }
                
                guard let response = response else {
                    self?.errorMessage = "No results found"
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

// MARK: - Location Manager
class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    @Published var userLocation: CLLocationCoordinate2D?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        userLocation = locations.last?.coordinate
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        if authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways {
            locationManager.startUpdatingLocation()
        }
    }
    
    // Add these methods to LocationManager class
    func requestWhenInUseAuthorization() {
        locationManager.requestWhenInUseAuthorization()
    }

    func startUpdatingLocation() {
        locationManager.startUpdatingLocation()
    }
}

struct CategoryChip: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 12))
                
                Text(title)
                    .font(.system(size: 14, weight: .medium))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(isSelected ? color : color.opacity(0.1))
            )
            .foregroundColor(isSelected ? .white : color)
        }
    }
}

// MARK: - Resources View
struct ResourcesView: View {
    @StateObject private var locationManager = LocationManager()
    @StateObject private var resourceService = ResourceService()
    
    @State private var selectedCategory: ResourceCategory = .all
    @State private var searchText = ""
    @State private var viewMode: ViewMode = .list
    @State private var selectedResource: ResourceLocation?
    
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
                                    selectedCategory = category
                                    loadResources()
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
            }
            .navigationTitle("Resources")
            .navigationBarTitleDisplayMode(.inline)
        }
        .sheet(item: $selectedResource) { resource in
            ResourceDetailView(resource: resource)
        }
        .onAppear {
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
            loadResources()
        }
        .onReceive(locationManager.$userLocation.compactMap { $0 }) { _ in
            loadResources()
        }
    }
    
    private func loadResources() {
        if let userLocation = locationManager.userLocation {
            let location = CLLocation(latitude: userLocation.latitude, longitude: userLocation.longitude)
            resourceService.fetchResources(category: selectedCategory, near: location)
        } else {
            // Request location if we don't have it
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
        }
    }
}

// MARK: - Map Content View
struct MapContentView: View {
    let resources: [ResourceLocation]
    let userLocation: CLLocationCoordinate2D?
    @Binding var selectedResource: ResourceLocation?
    
    var body: some View {
        Map(initialPosition: .region(
            MKCoordinateRegion(
                center: userLocation ?? CLLocationCoordinate2D(latitude: 33.749, longitude: -84.388),
                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            )
        )) {
            ForEach(resources) { resource in
                Annotation(resource.name, coordinate: resource.coordinate) {
                    ResourceMapPin(resource: resource, onTap: {
                        selectedResource = resource
                    })
                }
            }
        }
        .edgesIgnoringSafeArea(.bottom)
    }
}

// MARK: - List Content View
struct ListContentView: View {
    let resources: [ResourceLocation]
    @Binding var selectedResource: ResourceLocation?
    
    var body: some View {
        List(resources) { resource in
            ResourceListItem(resource: resource)
                .onTapGesture {
                    selectedResource = resource
                }
        }
        .listStyle(PlainListStyle())
    }
}

// MARK: - Resource Map Pin
struct ResourceMapPin: View {
    let resource: ResourceLocation
    let onTap: () -> Void
    
    var body: some View {
        ZStack {
            Circle()
                .fill(resource.category.color)
                .frame(width: 40, height: 40)
            
            Image(systemName: resource.icon)
                .foregroundColor(.white)
                .font(.system(size: 18))
        }
        .onTapGesture(perform: onTap)
    }
}

// MARK: - Resource List Item
struct ResourceListItem: View {
    let resource: ResourceLocation
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(resource.category.color.opacity(0.2))
                    .frame(width: 50, height: 50)
                
                Image(systemName: resource.icon)
                    .foregroundColor(resource.category.color)
                    .font(.system(size: 22))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(resource.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(resource.category.rawValue)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }
}
