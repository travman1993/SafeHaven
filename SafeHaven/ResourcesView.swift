import SwiftUI
import MapKit

struct ResourceLocation: Identifiable {
    let id = UUID()
    let name: String
    let category: String
    let address: String
    let phoneNumber: String
    let description: String
    let coordinate: CLLocationCoordinate2D
    let icon: String
}

struct ResourcesView: View {
    @State private var selectedCategory: String = "All"
    @State private var searchText: String = ""
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    @State private var selectedResource: ResourceLocation?
    @State private var showingResourceDetails = false
    
    // Sample resource locations
    let resourceLocations = [
        ResourceLocation(
            name: "Community Shelter",
            category: "Shelter",
            address: "123 Main St, San Francisco, CA",
            phoneNumber: "(555) 123-4567",
            description: "Emergency shelter providing temporary housing for individuals and families in need.",
            coordinate: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
            icon: "house.fill"
        ),
        ResourceLocation(
            name: "Hope Food Bank",
            category: "Food",
            address: "456 Market St, San Francisco, CA",
            phoneNumber: "(555) 987-6543",
            description: "Food bank providing groceries and meals to those experiencing food insecurity.",
            coordinate: CLLocationCoordinate2D(latitude: 37.7829, longitude: -122.4190),
            icon: "bag.fill"
        ),
        ResourceLocation(
            name: "Wellness Clinic",
            category: "Healthcare",
            address: "789 Powell St, San Francisco, CA",
            phoneNumber: "(555) 456-7890",
            description: "Free and low-cost healthcare services for uninsured and underinsured individuals.",
            coordinate: CLLocationCoordinate2D(latitude: 37.7699, longitude: -122.4120),
            icon: "heart.text.square.fill"
        ),
        ResourceLocation(
            name: "Youth Support Center",
            category: "Support",
            address: "321 Mission St, San Francisco, CA",
            phoneNumber: "(555) 234-5678",
            description: "Support services specifically for youth including counseling, education assistance, and job training.",
            coordinate: CLLocationCoordinate2D(latitude: 37.7859, longitude: -122.4250),
            icon: "person.2.fill"
        )
    ]
    
    var categories: [String] {
        var cats = resourceLocations.map { $0.category }
        cats.insert("All", at: 0)
        return Array(Set(cats)).sorted()
    }
    
    var filteredResources: [ResourceLocation] {
        resourceLocations.filter { resource in
            (selectedCategory == "All" || resource.category == selectedCategory) &&
            (searchText.isEmpty || resource.name.lowercased().contains(searchText.lowercased()) ||
             resource.category.lowercased().contains(searchText.lowercased()))
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
                        ForEach(categories, id: \.self) { category in
                            Button(action: {
                                selectedCategory = category
                            }) {
                                Text(category)
                                    .font(.system(size: 14, weight: .medium))
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(
                                        RoundedRectangle(cornerRadius: 20)
                                            .fill(selectedCategory == category ? Color(hex: "6A89CC") : Color.white)
                                    )
                                    .foregroundColor(selectedCategory == category ? .white : Color(hex: "6A89CC"))
                                    .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 12)
                }
                .background(Color.white)
                .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 2)
                
                // Toggle between list and map
                TabView {
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
                    .tabItem {
                        Label("List", systemImage: "list.bullet")
                    }
                    
                    // Map view
                    Map(coordinateRegion: $region, annotationItems: filteredResources) { resource in
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
                    .tabItem {
                        Label("Map", systemImage: "map")
                    }
                }
            }
        }
        .navigationTitle("Resources")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingResourceDetails) {
            if let resource = selectedResource {
                ResourceDetailView(resource: resource)
            }
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
                    
                    Text(resource.category)
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
                            
                            Text(resource.category)
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
                        
                        HStack(spacing: 12) {
                            Image(systemName: "mappin.circle.fill")
                                .font(.system(size: 22))
                                .foregroundColor(Color(hex: "6A89CC"))
                            
                            Text(resource.address)
                                .font(.system(size: 16))
                        }
                        
                        HStack(spacing: 12) {
                            Image(systemName: "phone.circle.fill")
                                .font(.system(size: 22))
                                .foregroundColor(Color(hex: "6A89CC"))
                            
                            Text(resource.phoneNumber)
                                .font(.system(size: 16))
                        }
                        
                        // Action buttons
                        HStack(spacing: 12) {
                            Button(action: {
                                // Call functionality would go here
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
                                // Direction functionality would go here
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
                    
                    // Description
                    VStack(alignment: .leading, spacing: 12) {
                        Text("About")
                            .font(.system(size: 18, weight: .semibold))
                        
                        Text(resource.description)
                            .font(.system(size: 16))
                            .lineSpacing(4)
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    
                    // Map view of this specific location
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Location")
                            .font(.system(size: 18, weight: .semibold))
                        
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

struct ResourcesView_Previews: PreviewProvider {
    static var previews: some View {
        ResourcesView()
    }
}
