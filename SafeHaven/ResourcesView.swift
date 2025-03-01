import SwiftUI
import MapKit
import CoreLocation
import Firebase
import FirebaseFirestore

// Resource Category Enum
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

// Resource model
struct ResourceLocation: Identifiable {
    let id: String
    let name: String
    let category: ResourceCategory
    let address: String
    let phoneNumber: String
    let description: String
    let coordinate: CLLocationCoordinate2D
    let icon: String
    
    // Optional fields
    let website: String?
    let hours: String?
    let services: [String]
    
    init(id: String = UUID().uuidString,
         name: String,
         category: ResourceCategory,
         address: String,
         phoneNumber: String,
         description: String,
         latitude: Double,
         longitude: Double,
         website: String? = nil,
         hours: String? = nil,
         services: [String] = []) {
        
        self.id = id
        self.name = name
        self.category = category
        self.address = address
        self.phoneNumber = phoneNumber
        self.description = description
        self.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        self.icon = category.icon
        self.website = website
        self.hours = hours
        self.services = services
    }
    
    // Initialize from Firestore data
    init?(documentID: String, data: [String: Any]) {
        guard let name = data["name"] as? String,
              let categoryString = data["category"] as? String,
              let address = data["address"] as? String,
              let phoneNumber = data["phoneNumber"] as? String,
              let description = data["description"] as? String,
              let latitude = data["latitude"] as? Double,
              let longitude = data["longitude"] as? Double else {
            return nil
        }
        
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

// Location Manager
class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    @Published var userLocation: CLLocationCoordinate2D?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func requestLocationPermission() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    func startUpdatingLocation() {
        locationManager.startUpdatingLocation()
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        
        if authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways {
            startUpdatingLocation()
        }
        
        print("Location authorization status: \(authorizationStatus.rawValue)")
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        print("Location updated: \(location.coordinate.latitude), \(location.coordinate.longitude)")
        userLocation = location.coordinate
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error: \(error.localizedDescription)")
    }
}

// Firestore Service
class ResourceService: ObservableObject {
    private let db = Firestore.firestore()
    @Published var resources: [ResourceLocation] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    func fetchResources(near coordinate: CLLocationCoordinate2D, radius: Double = 50.0) {
        isLoading = true
        errorMessage = nil
        
        // For simulator testing - add these print statements
        print("Fetching resources near: \(coordinate.latitude), \(coordinate.longitude)")
        
        // Convert to miles (approximate)
        let radiusInMiles = radius * 0.621371
        
        // Firestore doesn't support geospatial queries directly in this way
        // This is a simplified version - in a real app you might use Firebase GeoFirestore
        // or implement server-side filtering
        
        db.collection("resources")
            .getDocuments { [weak self] snapshot, error in
                guard let self = self else { return }
                
                self.isLoading = false
                
                if let error = error {
                    self.errorMessage = "Error fetching resources: \(error.localizedDescription)"
                    print(self.errorMessage ?? "")
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    self.errorMessage = "No resources found"
                    return
                }
                
                // Process results
                var fetchedResources: [ResourceLocation] = []
                
                for document in documents {
                    if let resource = ResourceLocation(documentID: document.documentID, data: document.data()) {
                        // Here we calculate distance to filter resources
                        // In a proper implementation this would be done server-side
                        let resourceLocation = CLLocation(latitude: resource.coordinate.latitude,
                                                         longitude: resource.coordinate.longitude)
                        let userLocation = CLLocation(latitude: coordinate.latitude,
                                                     longitude: coordinate.longitude)
                        
                        let distanceInMiles = resourceLocation.distance(from: userLocation) / 1609.344 // convert meters to miles
                        
                        if distanceInMiles <= radiusInMiles {
                            fetchedResources.append(resource)
                        }
                    }
                }
                
                self.resources = fetchedResources
                print("Fetched \(fetchedResources.count) resources within \(radiusInMiles) miles")
                
                // For testing in simulator when no resources are available near test location
                if fetchedResources.isEmpty {
                    self.addLocalTestResources(near: coordinate)
                }
            }
    }
    
    // Add local test resources for simulator testing when no Firebase data is available
    private func addLocalTestResources(near coordinate: CLLocationCoordinate2D) {
        print("Adding local test resources near \(coordinate.latitude), \(coordinate.longitude)")
        
        // Create resources near the given coordinate
        let resources = [
            ResourceLocation(
                name: "Local Food Bank",
                category: .food,
                address: "123 Main St",
                phoneNumber: "(555) 123-4567",
                description: "Community food bank providing assistance to those in need.",
                latitude: coordinate.latitude + 0.01,
                longitude: coordinate.longitude - 0.01,
                hours: "Mon-Fri 9am-5pm",
                services: ["Food pantry", "Meal service", "Grocery assistance"]
            ),
            ResourceLocation(
                name: "Emergency Shelter",
                category: .shelter,
                address: "456 Oak Avenue",
                phoneNumber: "(555) 987-6543",
                description: "Emergency shelter providing temporary housing for individuals and families.",
                latitude: coordinate.latitude - 0.005,
                longitude: coordinate.longitude + 0.008,
                hours: "24/7",
                services: ["Emergency shelter", "Case management", "Referrals"]
            ),
            ResourceLocation(
                name: "Community Health Clinic",
                category: .healthcare,
                address: "789 Elm Street",
                phoneNumber: "(555) 456-7890",
                description: "Nonprofit clinic providing healthcare services to underserved populations.",
                latitude: coordinate.latitude + 0.003,
                longitude: coordinate.longitude + 0.005,
                hours: "Mon-Sat 8am-8pm",
                services: ["Primary care", "Mental health", "Dental services"]
            ),
            ResourceLocation(
                name: "Youth Support Center",
                category: .support,
                address: "101 Pine Road",
                phoneNumber: "(555) 234-5678",
                description: "Support services for youth including counseling, education, and job training.",
                latitude: coordinate.latitude - 0.008,
                longitude: coordinate.longitude - 0.003,
                hours: "Mon-Fri 10am-6pm",
                services: ["Counseling", "Education support", "Job readiness"]
            )
        ]
        
        self.resources = resources
    }
}

struct ResourcesView: View {
    @StateObject private var locationManager = LocationManager()
    @StateObject private var resourceService = ResourceService()
    
    @State private var selectedCategory: ResourceCategory = .all
    @State private var searchText: String = ""
    @State private var viewMode: String = "map" // "map" or "list"
    @State private var selectedResource: ResourceLocation?
    @State private var showingResourceDetails = false
    
    // Default to a reasonable location until we get user's location
    @State private var region = MKCoordinateRegion(
        // Default to Atlanta for testing
        center: CLLocationCoordinate2D(latitude: 33.749, longitude: -84.388),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    
    var filteredResources: [ResourceLocation] {
        resourceService.resources.filter { resource in
            (selectedCategory == .all || resource.category == selectedCategory) &&
            (searchText.isEmpty ||
             resource.name.lowercased().contains(searchText.lowercased()) ||
             resource.category.rawValue.lowercased().contains(searchText.lowercased()) ||
             resource.services.joined(separator: " ").lowercased().contains(searchText.lowercased()))
        }
    }
    
    var body: some View {
        ZStack {
            // Background color
            Color(hex: "F5F7FA")
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Search bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    
                    TextField("Search resources...", text: $searchText)
                        .font(.system(size: 16))
                }
                .padding(12)
                .background(Color.white)
                .cornerRadius(10)
                .padding(.horizontal)
                .padding(.top)
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                
                // Categories scroll
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(ResourceCategory.allCases) { category in
                            Button(action: {
                                selectedCategory = category
                            }) {
                                VStack(spacing: 6) {
                                    ZStack {
                                        Circle()
                                            .fill(selectedCategory == category ? Color(hex: "6A89CC") : Color.white)
                                            .frame(width: 50, height: 50)
                                            .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
                                        
                                        Image(systemName: category.icon)
                                            .font(.system(size: 20))
                                            .foregroundColor(selectedCategory == category ? .white : Color(hex: "6A89CC"))
                                    }
                                    
                                    Text(category.rawValue)
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(Color(hex: "2D3748"))
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 12)
                }
                .background(Color.white)
                .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 2)
                
                // Toggle between list and map view
                Picker("View Mode", selection: $viewMode) {
                    Text("Map").tag("map")
                    Text("List").tag("list")
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                .padding(.vertical, 8)
                
                if resourceService.isLoading {
                    Spacer()
                    ProgressView("Loading resources...")
                        .progressViewStyle(CircularProgressViewStyle())
                    Spacer()
                } else if let errorMessage = resourceService.errorMessage {
                    Spacer()
                    VStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.orange)
                            .padding()
                        
                        Text(errorMessage)
                            .font(.headline)
                            .multilineTextAlignment(.center)
                            .padding()
                        
                        Button("Retry") {
                            if let userLocation = locationManager.userLocation {
                                resourceService.fetchResources(near: userLocation)
                            } else {
                                // Use default location if user location is not available
                                resourceService.fetchResources(near: region.center)
                            }
                        }
                        .padding()
                        .background(Color(hex: "6A89CC"))
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }
                    .padding()
                    Spacer()
                } else                 if viewMode == "map" {
                    // Map view with iOS 17 compatible API
                    #if swift(>=5.9) && canImport(MapKit)
                    if #available(iOS 17.0, *) {
                        Map(initialPosition: MapCameraPosition.region(region)) {
                            UserLocation()
                            ForEach(filteredResources) { resource in
                                Annotation(resource.name, coordinate: resource.coordinate) {
                                    VStack {
                                        ZStack {
                                            Circle()
                                                .fill(Color(hex: "6A89CC"))
                                                .frame(width: 44, height: 44)
                                                .shadow(radius: 3)
                                            
                                            Image(systemName: resource.icon)
                                                .font(.system(size: 20))
                                                .foregroundColor(.white)
                                        }
                                        
                                        Text(resource.name)
                                            .font(.caption)
                                            .fontWeight(.medium)
                                            .foregroundColor(.black)
                                            .padding(6)
                                            .background(Color.white.opacity(0.9))
                                            .cornerRadius(4)
                                            .shadow(radius: 1)
                                    }
                                    .onTapGesture {
                                        selectedResource = resource
                                        showingResourceDetails = true
                                    }
                                }
                            }
                        }
                    } else {
                        // Fallback for iOS 16 and earlier
                        Map(coordinateRegion: $region, showsUserLocation: true, annotationItems: filteredResources) { resource in
                            MapAnnotation(coordinate: resource.coordinate) {
                                VStack {
                                    ZStack {
                                        Circle()
                                            .fill(Color(hex: "6A89CC"))
                                            .frame(width: 44, height: 44)
                                            .shadow(radius: 3)
                                        
                                        Image(systemName: resource.icon)
                                            .font(.system(size: 20))
                                            .foregroundColor(.white)
                                    }
                                    
                                    Text(resource.name)
                                        .font(.caption)
                                        .fontWeight(.medium)
                                        .foregroundColor(.black)
                                        .padding(6)
                                        .background(Color.white.opacity(0.9))
                                        .cornerRadius(4)
                                        .shadow(radius: 1)
                                }
                                .onTapGesture {
                                    selectedResource = resource
                                    showingResourceDetails = true
                                }
                            }
                        }
                    }
                    #else
                    // Fallback for older Swift versions
                    Map(coordinateRegion: $region, showsUserLocation: true, annotationItems: filteredResources) { resource in
                        MapAnnotation(coordinate: resource.coordinate) {
                            VStack {
                                ZStack {
                                    Circle()
                                        .fill(Color(hex: "6A89CC"))
                                        .frame(width: 44, height: 44)
                                        .shadow(radius: 3)
                                    
                                    Image(systemName: resource.icon)
                                        .font(.system(size: 20))
                                        .foregroundColor(.white)
                                }
                                
                                Text(resource.name)
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .foregroundColor(.black)
                                    .padding(6)
                                    .background(Color.white.opacity(0.9))
                                    .cornerRadius(4)
                                    .shadow(radius: 1)
                            }
                            .onTapGesture {
                                selectedResource = resource
                                showingResourceDetails = true
                            }
                        }
                    }
                    #endif
                } else {
                    // List view
                    if filteredResources.isEmpty {
                        Spacer()
                        VStack {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 50))
                                .foregroundColor(Color(hex: "6A89CC"))
                                .padding()
                            
                            Text("No resources found")
                                .font(.headline)
                                .padding(.bottom, 4)
                            
                            Text("Try adjusting your filters or search terms")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        Spacer()
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 16) {
                                ForEach(filteredResources) { resource in
                                    ResourceCard(resource: resource)
                                        .onTapGesture {
                                            selectedResource = resource
                                            showingResourceDetails = true
                                        }
                                }
                            }
                            .padding()
                        }
                    }
                }
            }
            
            // Location permission request overlay
            if locationManager.authorizationStatus == .denied || locationManager.authorizationStatus == .restricted {
                VStack(spacing: 20) {
                    Image(systemName: "location.slash.fill")
                        .font(.system(size: 60))
                        .foregroundColor(Color(hex: "6A89CC"))
                    
                    Text("Location Access Required")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(Color(hex: "2D3748"))
                    
                    Text("SafeHaven needs access to your location to find resources near you. Please enable location access in your device settings.")
                        .font(.system(size: 16))
                        .foregroundColor(Color(hex: "718096"))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    Button(action: {
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(url)
                        }
                    }) {
                        Text("Open Settings")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                            .padding(.vertical, 12)
                            .padding(.horizontal, 24)
                            .background(Color(hex: "6A89CC"))
                            .cornerRadius(8)
                    }
                }
                .padding()
                .background(Color.white)
                .cornerRadius(16)
                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                .padding()
            }
        }
        .navigationTitle("Find Resources")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingResourceDetails) {
            if let resource = selectedResource {
                ResourceDetailView(resource: resource)
            }
        }
        .onAppear {
            print("ResourcesView appeared")
            
            // Request location if not already authorized
            if locationManager.authorizationStatus == .notDetermined {
                locationManager.requestLocationPermission()
            } else if locationManager.authorizationStatus == .authorizedWhenInUse ||
                      locationManager.authorizationStatus == .authorizedAlways {
                locationManager.startUpdatingLocation()
            }
            
            // For simulator testing, force location to Atlanta
            #if targetEnvironment(simulator)
            print("Running in simulator - setting default location to Atlanta")
            let atlantaLocation = CLLocationCoordinate2D(latitude: 33.749, longitude: -84.388)
            region = MKCoordinateRegion(
                center: atlantaLocation,
                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            )
            
            // Also fetch resources near this location
            resourceService.fetchResources(near: atlantaLocation)
            #endif
        }
        // Using onReceive instead of onChange because CLLocationCoordinate2D is not Equatable
        .onReceive(locationManager.$userLocation.compactMap { $0 }) { location in
            print("User location updated to: \(location.latitude), \(location.longitude)")
            region = MKCoordinateRegion(
                center: location,
                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            )
            
            // Fetch resources near this location
            resourceService.fetchResources(near: location)
        }
    }
}

// Helper components remain mostly the same
struct ResourceCard: View {
    let resource: ResourceLocation
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                // Category icon
                ZStack {
                    Circle()
                        .fill(Color(hex: "6A89CC").opacity(0.2))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: resource.icon)
                        .font(.system(size: 18))
                        .foregroundColor(Color(hex: "6A89CC"))
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(resource.name)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(Color(hex: "2D3748"))
                    
                    Text(resource.category.rawValue)
                        .font(.system(size: 14))
                        .foregroundColor(Color(hex: "6A89CC"))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(
                            Capsule()
                                .fill(Color(hex: "6A89CC").opacity(0.1))
                        )
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(Color(hex: "A0AEC0"))
            }
            
            Text(resource.address)
                .font(.system(size: 14))
                .foregroundColor(Color(hex: "718096"))
            
            Text(resource.phoneNumber)
                .font(.system(size: 14))
                .foregroundColor(Color(hex: "718096"))
            
            // Show hours if available
            if let hours = resource.hours {
                HStack(spacing: 6) {
                    Image(systemName: "clock.fill")
                        .font(.system(size: 12))
                        .foregroundColor(Color(hex: "6A89CC"))
                    
                    Text(hours)
                        .font(.system(size: 14))
                        .foregroundColor(Color(hex: "718096"))
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

struct ResourceDetailView: View {
    let resource: ResourceLocation
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header with icon
                    HStack {
                        ZStack {
                            Circle()
                                .fill(Color(hex: "6A89CC").opacity(0.2))
                                .frame(width: 60, height: 60)
                            
                            Image(systemName: resource.icon)
                                .font(.system(size: 30))
                                .foregroundColor(Color(hex: "6A89CC"))
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(resource.name)
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(Color(hex: "2D3748"))
                            
                            Text(resource.category.rawValue)
                                .font(.system(size: 16))
                                .foregroundColor(Color(hex: "6A89CC"))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 3)
                                .background(
                                    Capsule()
                                        .fill(Color(hex: "6A89CC").opacity(0.1))
                                )
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.white)
                    .cornerRadius(12)
                    
                    // Contact info
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Contact Information")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(Color(hex: "2D3748"))
                        
                        HStack(spacing: 12) {
                            Image(systemName: "mappin.circle.fill")
                                .font(.system(size: 22))
                                .foregroundColor(Color(hex: "6A89CC"))
                            
                            Text(resource.address)
                                .font(.system(size: 16))
                                .foregroundColor(Color(hex: "2D3748"))
                        }
                        
                        HStack(spacing: 12) {
                            Image(systemName: "phone.circle.fill")
                                .font(.system(size: 22))
                                .foregroundColor(Color(hex: "6A89CC"))
                            
                            Text(resource.phoneNumber)
                                .font(.system(size: 16))
                                .foregroundColor(Color(hex: "2D3748"))
                        }
                        
                        if let hours = resource.hours {
                            HStack(spacing: 12) {
                                Image(systemName: "clock.fill")
                                    .font(.system(size: 22))
                                    .foregroundColor(Color(hex: "6A89CC"))
                                
                                Text(hours)
                                    .font(.system(size: 16))
                                    .foregroundColor(Color(hex: "2D3748"))
                            }
                        }
                        
                        // Action buttons
                        HStack(spacing: 12) {
                            Button(action: {
                                // Call functionality
                                if let url = URL(string: "tel://\(resource.phoneNumber.filter { "0123456789".contains($0) })"),
                                   UIApplication.shared.canOpenURL(url) {
                                    UIApplication.shared.open(url)
                                }
                            }) {
                                HStack {
                                    Image(systemName: "phone.fill")
                                    Text("Call")
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(Color(hex: "6A89CC"))
                                .foregroundColor(.white)
                                .cornerRadius(8)
                            }
                            
                            Button(action: {
                                // Open in Maps
                                let destination = MKMapItem(placemark: MKPlacemark(coordinate: resource.coordinate))
                                destination.name = resource.name
                                destination.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
                            }) {
                                HStack {
                                    Image(systemName: "location.fill")
                                    Text("Directions")
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(Color(hex: "41B3A3"))
                                .foregroundColor(.white)
                                .cornerRadius(8)
                            }
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    
                    // Services offered
                    if !resource.services.isEmpty {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Services Offered")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(Color(hex: "2D3748"))
                            
                            ForEach(resource.services, id: \.self) { service in
                                HStack(spacing: 8) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 14))
                                        .foregroundColor(Color(hex: "41B3A3"))
                                    
                                    Text(service)
                                        .font(.system(size: 16))
                                        .foregroundColor(Color(hex: "2D3748"))
                                }
                            }
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                    }
                    
                    // Description
                    VStack(alignment: .leading, spacing: 12) {
                        Text("About")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(Color(hex: "2D3748"))
                        
                        Text(resource.description)
                            .font(.system(size: 16))
                            .foregroundColor(Color(hex: "2D3748"))
                            .lineSpacing(4)
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    
                    // Map view of this specific location
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Location")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(Color(hex: "2D3748"))
                        
                        // Detail map view with iOS 17 compatibility
                        #if swift(>=5.9) && canImport(MapKit)
                        if #available(iOS 17.0, *) {
                            Map(initialPosition: MapCameraPosition.region(MKCoordinateRegion(
                                center: resource.coordinate,
                                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                            ))) {
                                Marker(resource.name, coordinate: resource.coordinate)
                                    .tint(Color(hex: "6A89CC"))
                            }
                        } else {
                            // Fallback for iOS 16 and earlier
                            Map(coordinateRegion: .constant(MKCoordinateRegion(
                                center: resource.coordinate,
                                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                            )), annotationItems: [resource]) { location in
                                MapMarker(coordinate: location.coordinate, tint: Color(hex: "6A89CC"))
                            }
                        }
                        #else
                        // Fallback for older Swift versions
                        Map(coordinateRegion: .constant(MKCoordinateRegion(
                            center: resource.coordinate,
                            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                        )), annotationItems: [resource]) { location in
                            MapMarker(coordinate: location.coordinate, tint: Color(hex: "6A89CC"))
                        }
                        #endif
                        .frame(height: 200)
                        .cornerRadius(8)
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                }
                .padding()
            }
            .background(Color(hex: "F5F7FA"))
            .navigationBarTitle("Resource Details", displayMode: .inline)
            .navigationBarItems(trailing: Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 20))
                    .foregroundColor(Color(hex: "718096"))
            })
        }
    }
}

// Helper extension for hex colors (only add if not already defined elsewhere in your app)
#if !canImport(ColorHexExtension)
extension Color {
    static func hex(_ hex: String) -> Self {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        return Color(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// Maintain backward compatibility with existing code

#endif
