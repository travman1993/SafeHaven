import SwiftUI
import MapKit
import CoreLocation
import Firebase
import FirebaseFirestore

// MARK: - Resource Model
struct ResourceLocation: Identifiable {
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
}

// MARK: - Firestore Service
class ResourceService: ObservableObject {
    private let db = Firestore.firestore()
    @Published var resources: [ResourceLocation] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    func fetchResources() {
        isLoading = true
        db.collection("resources").getDocuments { snapshot, error in
            DispatchQueue.main.async {
                self.isLoading = false
                if let error = error {
                    self.errorMessage = "Error loading resources: \(error.localizedDescription)"
                    return
                }
                
                self.resources = snapshot?.documents.compactMap { doc in
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
    @State private var searchText: String = ""
    @State private var viewMode: String = "map"
    @State private var selectedResource: ResourceLocation?
    
    var filteredResources: [ResourceLocation] {
        resourceService.resources.filter { resource in
            (selectedCategory == .all || resource.category == selectedCategory) &&
            (searchText.isEmpty ||
             resource.name.localizedCaseInsensitiveContains(searchText) ||
             resource.category.rawValue.localizedCaseInsensitiveContains(searchText))
        }
    }

    var body: some View {
        VStack {
            // Search Bar
            TextField("Search resources...", text: $searchText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            // Category Selection
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(ResourceCategory.allCases) { category in
                        Button(action: { selectedCategory = category }) {
                            VStack {
                                Image(systemName: category.icon)
                                Text(category.rawValue)
                            }
                            .padding()
                            .background(selectedCategory == category ? Color.blue : Color.gray.opacity(0.3))
                            .cornerRadius(8)
                        }
                    }
                }
                .padding(.horizontal)
            }

            // Toggle Map / List View
            Picker("View Mode", selection: $viewMode) {
                Text("Map").tag("map")
                Text("List").tag("list")
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal)

            // Map or List View
            if viewMode == "map" {
                VStack {
                    Map(initialPosition: MapCameraPosition.region(MKCoordinateRegion(
                        center: locationManager.userLocation ?? CLLocationCoordinate2D(latitude: 33.749, longitude: -84.388),
                        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                    ))) {
                        ForEach(filteredResources) { resource in
                            Annotation(resource.name, coordinate: resource.coordinate) {
                                VStack {
                                    Image(systemName: resource.icon)
                                        .foregroundColor(.blue)
                                        .padding()
                                        .background(Color.white)
                                        .clipShape(Circle())
                                }
                                .onTapGesture {
                                    selectedResource = resource
                                }
                            }
                        }
                    }
                    .frame(height: 400)

                    // Map Controls
                    HStack {
                        MapUserLocationButton()
                        MapCompass()
                        MapScaleView()
                    }
                    .padding()
                }
            } else {
                List(filteredResources) { resource in
                    HStack {
                        Image(systemName: resource.icon).foregroundColor(.blue)
                        VStack(alignment: .leading) {
                            Text(resource.name).font(.headline)
                            Text(resource.category.rawValue).font(.subheadline).foregroundColor(.gray)
                        }
                    }
                    .onTapGesture {
                        selectedResource = resource
                    }
                }
            }
        }
        .sheet(item: $selectedResource) { resource in
            ResourceDetailView(resource: resource)
        }
        .onAppear {
            resourceService.fetchResources()
        }
    }
}
