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

// MARK: - Resource Service (Mock Implementation)
class ResourceService: ObservableObject {
    @Published var resources: [ResourceLocation] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    func fetchResources() {
        isLoading = true
        
        // Simulate network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.isLoading = false
            
            // Sample data instead of Firestore
            self?.resources = [
                ResourceLocation(
                    id: "1",
                    name: "Downtown Shelter",
                    category: .shelter,
                    address: "123 Main St, Anytown, USA",
                    phoneNumber: "555-123-4567",
                    description: "Emergency shelter providing temporary housing, meals, and basic necessities for individuals and families in crisis.",
                    coordinate: CLLocationCoordinate2D(latitude: 33.749, longitude: -84.388),
                    icon: "house.fill",
                    website: "www.downtownshelter.org",
                    hours: "Open 24/7",
                    services: ["Emergency Housing", "Meals", "Clothing", "Counseling"]
                ),
                ResourceLocation(
                    id: "2",
                    name: "Community Food Bank",
                    category: .food,
                    address: "456 Oak Ave, Anytown, USA",
                    phoneNumber: "555-987-6543",
                    description: "Provides free groceries, prepared meals, and nutrition education to those experiencing food insecurity.",
                    coordinate: CLLocationCoordinate2D(latitude: 33.753, longitude: -84.393),
                    icon: "fork.knife",
                    website: "www.communityfoodbank.org",
                    hours: "Mon-Fri: 9am-5pm, Sat: 10am-2pm",
                    services: ["Food Packages", "Hot Meals", "Nutrition Education"]
                ),
                ResourceLocation(
                    id: "3",
                    name: "Free Health Clinic",
                    category: .healthcare,
                    address: "789 Elm St, Anytown, USA",
                    phoneNumber: "555-789-0123",
                    description: "Provides free or reduced-cost medical care, medications, and mental health services to uninsured individuals.",
                    coordinate: CLLocationCoordinate2D(latitude: 33.755, longitude: -84.383),
                    icon: "cross.fill",
                    website: "www.freehealthclinic.org",
                    hours: "Mon-Sat: 8am-8pm",
                    services: ["Medical Exams", "Prescriptions", "Mental Health", "Dental Care"]
                ),
                ResourceLocation(
                    id: "4",
                    name: "Crisis Support Center",
                    category: .support,
                    address: "101 Pine St, Anytown, USA",
                    phoneNumber: "555-321-6789",
                    description: "Provides crisis intervention, counseling, and support services for individuals experiencing trauma or emotional distress.",
                    coordinate: CLLocationCoordinate2D(latitude: 33.748, longitude: -84.376),
                    icon: "person.2.fill",
                    website: "www.crisissupport.org",
                    hours: "Open 24/7 - Crisis Hotline Available",
                    services: ["Crisis Counseling", "Support Groups", "Referral Services"]
                ),
                ResourceLocation(
                    id: "5",
                    name: "Legal Aid Society",
                    category: .legal,
                    address: "222 Maple Ave, Anytown, USA",
                    phoneNumber: "555-456-7890",
                    description: "Provides free legal assistance to low-income individuals for civil matters including housing, family law, and public benefits.",
                    coordinate: CLLocationCoordinate2D(latitude: 33.760, longitude: -84.390),
                    icon: "building.columns.fill",
                    website: "www.legalaid.org",
                    hours: "Mon-Fri: 9am-5pm",
                    services: ["Legal Consultation", "Document Preparation", "Court Representation"]
                ),
                ResourceLocation(
                    id: "6",
                    name: "Financial Assistance Center",
                    category: .financial,
                    address: "333 Birch Blvd, Anytown, USA",
                    phoneNumber: "555-234-5678",
                    description: "Provides emergency financial assistance for rent, utilities, and other basic needs, as well as financial education and counseling.",
                    coordinate: CLLocationCoordinate2D(latitude: 33.745, longitude: -84.395),
                    icon: "dollarsign.circle.fill",
                    website: "www.financialhelp.org",
                    hours: "Mon-Fri: 9am-4pm",
                    services: ["Emergency Assistance", "Financial Counseling", "Budgeting Classes"]
                ),
                ResourceLocation(
                    id: "7",
                    name: "Adult Education Center",
                    category: .education,
                    address: "444 Cedar St, Anytown, USA",
                    phoneNumber: "555-876-5432",
                    description: "Offers free adult education classes including GED preparation, English language learning, and job skills training.",
                    coordinate: CLLocationCoordinate2D(latitude: 33.757, longitude: -84.378),
                    icon: "book.fill",
                    website: "www.adulteducation.org",
                    hours: "Mon-Thu: 8am-8pm, Fri: 8am-5pm",
                    services: ["GED Classes", "ESL Classes", "Computer Skills", "Job Training"]
                )
            ]
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
        }
    }
}
