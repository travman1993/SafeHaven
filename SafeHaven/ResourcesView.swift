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

    init?(documentID: String, data: [String: Any]) {
        guard let name = data["name"] as? String,
              let categoryString = data["category"] as? String,
              let address = data["address"] as? String,
              let phoneNumber = data["phoneNumber"] as? String,
              let description = data["description"] as? String,
              let latitude = data["latitude"] as? Double,
              let longitude = data["longitude"] as? Double else { return nil }
        
        let category = ResourceCategory(rawValue: categoryString) ?? .all
        
        self.id = documentID
        self.name = name
        self.category = category
        self.address = address
        self.phoneNumber = phoneNumber
        self.description = description
        self.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        self.icon = category.icon
        self.website = data["website"] as? String
        self.hours = data["hours"] as? String
        self.services = data["services"] as? [String] ?? []
    }

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
    case support = "Support"
    case legal = "Legal Aid"
    case financial = "Financial"
    case education = "Education"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .all: return "square.grid.2x2.fill"
        case .shelter: return "house.fill"
        case .food: return "fork.knife"
        case .healthcare: return "cross.fill"
        case .support: return "person.2.fill"
        case .legal: return "building.columns.fill"
        case .financial: return "dollarsign.circle.fill"
        case .education: return "book.fill"
        }
    }

    var color: Color {
        switch self {
        case .all: return .gray
        case .shelter: return Color(hex: "6A89CC")
        case .food: return .green
        case .healthcare: return .red
        case .support: return .blue
        case .legal: return .purple
        case .financial: return .orange
        case .education: return .teal
        }
    }
}

// MARK: - Firestore Service
class ResourceService: ObservableObject {
    private let db = Firestore.firestore()
    @Published var resources: [ResourceLocation] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    func fetchResources() {
        isLoading = true
        db.collection("resources").getDocuments { [weak self] snapshot, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                if let error = error {
                    self?.errorMessage = "Error loading resources: \(error.localizedDescription)"
                    return
                }
                
                self?.resources = snapshot?.documents.compactMap { doc in
                    ResourceLocation(documentID: doc.documentID, data: doc.data())
                } ?? []
            }
        }
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
            resourceService.fetchResources()
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
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Category Chip
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
