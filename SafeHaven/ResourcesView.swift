import SwiftUI
import MapKit
import CoreLocation

// Simplified Resource Category
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
    let id = UUID()
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
    
    init(name: String, category: ResourceCategory, address: String, phoneNumber: String,
         description: String, coordinate: CLLocationCoordinate2D,
         website: String? = nil, hours: String? = nil, services: [String] = []) {
        self.name = name
        self.category = category
        self.address = address
        self.phoneNumber = phoneNumber
        self.description = description
        self.coordinate = coordinate
        self.icon = category.icon
        self.website = website
        self.hours = hours
        self.services = services
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
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        userLocation = location.coordinate
    }
}

struct ResourcesView: View {
    @StateObject private var locationManager = LocationManager()
    @State private var selectedCategory: ResourceCategory = .all
    @State private var searchText: String = ""
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    @State private var selectedResource: ResourceLocation?
    @State private var showingResourceDetails = false
    @State private var viewMode: String = "map" // "map" or "list"
    
    // Sample data - in a real app, this would come from an API or database
    let resourceLocations = [
        ResourceLocation(
            name: "Community Shelter",
            category: .shelter,
            address: "123 Main St, San Francisco, CA",
            phoneNumber: "(555) 123-4567",
            description: "Emergency shelter providing temporary housing for individuals and families in need.",
            coordinate: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
            hours: "24/7",
            services: ["Emergency shelter", "Meals", "Case management"]
        ),
        ResourceLocation(
            name: "Hope Food Bank",
            category: .food,
            address: "456 Market St, San Francisco, CA",
            phoneNumber: "(555) 987-6543",
            description: "Food bank providing groceries and meals to those experiencing food insecurity.",
            coordinate: CLLocationCoordinate2D(latitude: 37.7829, longitude: -122.4190),
            hours: "Mon-Fri 9am-5pm",
            services: ["Food pantry", "Hot meals", "Grocery delivery"]
        ),
        ResourceLocation(
            name: "Wellness Clinic",
            category: .healthcare,
            address: "789 Powell St, San Francisco, CA",
            phoneNumber: "(555) 456-7890",
            description: "Free and low-cost healthcare services for uninsured and underinsured individuals.",
            coordinate: CLLocationCoordinate2D(latitude: 37.7699, longitude: -122.4120),
            hours: "Mon-Sat 8am-6pm",
            services: ["Medical care", "Mental health", "Prescriptions"]
        ),
        ResourceLocation(
            name: "Youth Support Center",
            category: .support,
            address: "321 Mission St, San Francisco, CA",
            phoneNumber: "(555) 234-5678",
            description: "Support services specifically for youth including counseling, education assistance, and job training.",
            coordinate: CLLocationCoordinate2D(latitude: 37.7859, longitude: -122.4250),
            hours: "Mon-Fri 10am-8pm",
            services: ["Counseling", "Education support", "Job training"]
        )
    ]
    
    var filteredResources: [ResourceLocation] {
        resourceLocations.filter { resource in
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
                
                if viewMode == "map" {
                    // Map view
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
                } else {
                    // List view
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
            // Request location if not already authorized
            if locationManager.authorizationStatus == .notDetermined {
                locationManager.requestLocationPermission()
            }
            
            locationManager.startUpdatingLocation()
            
            // Center map on user's location when available
            if let userLocation = locationManager.userLocation {
                region = MKCoordinateRegion(
                    center: userLocation,
                    span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                )
            }
        }
        .onReceive(locationManager.$userLocation.compactMap { $0 }) { location in
            region = MKCoordinateRegion(
                center: location,
                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            )
        }
    }
}

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
                        
                        Map(coordinateRegion: .constant(MKCoordinateRegion(
                            center: resource.coordinate,
                            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                        )), annotationItems: [resource]) { location in
                            MapMarker(coordinate: location.coordinate, tint: Color(hex: "6A89CC"))
                        }
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
