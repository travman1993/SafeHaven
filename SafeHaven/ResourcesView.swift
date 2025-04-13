import SwiftUI
import CoreLocation
import MapKit

struct ResourcesView: View {
    @StateObject private var locationService = LocationService()
    @StateObject private var resourceService = ResourceService()
    
    @State private var selectedCategory: ResourceCategory = .all
    @State private var viewMode: ViewMode = .list
    @State private var selectedResource: ResourceLocation?
    @State private var isLoading = false
    @State private var showingLocationSelector = false
    @State private var locationEnabled = false
    @State private var showingLocationPermissionAlert = false
    
    // Prevent too many resource reloads
    @State private var lastLoadTime = Date()
    
    enum ViewMode {
        case map, list
    }
    
    var filteredResources: [ResourceLocation] {
        // For "All" category, show all resources without filtering
        if selectedCategory == .all {
            return resourceService.resources
        }
        
        // Otherwise filter by selected category
        return resourceService.resources.filter { $0.category == selectedCategory }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Category Scrolling Tabs
            VStack(spacing: ResponsiveLayout.padding(12)) {
                // View Mode Toggle
                Picker("View Mode", selection: $viewMode) {
                    Image(systemName: "list.bullet").tag(ViewMode.list)
                    Image(systemName: "map").tag(ViewMode.map)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal, ResponsiveLayout.padding())
                .padding(.top, ResponsiveLayout.padding(8))
                
                // Category Scroll View
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: ResponsiveLayout.padding(10)) {
                        ForEach(ResourceCategory.allCases) { category in
                            CategoryChip(
                                title: category.rawValue,
                                icon: category.icon,
                                isSelected: selectedCategory == category,
                                color: category.color,
                                action: {
                                    if selectedCategory != category {
                                        selectedCategory = category
                                        loadResources()
                                    }
                                }
                            )
                        }
                    }
                    .padding(.horizontal, ResponsiveLayout.padding())
                }
                .padding(.bottom, ResponsiveLayout.padding(8))
            }
            .padding(.vertical, ResponsiveLayout.padding())
            .background(AppTheme.adaptiveBackground)
            
            // Content View - Map or List
            ZStack {
                switch viewMode {
                case .map:
                    // Map view with resources
                    SafeHavenResourceMapContainer(
                        resources: filteredResources,
                        userLocation: locationService.currentLocation?.coordinate,
                        selectedResource: $selectedResource
                    )
                    
                    // Show location permission message when location is disabled
                    if !locationEnabled && resourceService.resources.isEmpty {
                        LocationPermissionView(showingLocationSelector: $showingLocationSelector)
                    }
                    
                case .list:
                    ResourceListContentView(
                        resources: filteredResources,
                        selectedResource: $selectedResource
                    )
                    
                    // Show location permission message when location is disabled
                    if !locationEnabled && resourceService.resources.isEmpty {
                        LocationPermissionView(showingLocationSelector: $showingLocationSelector)
                    }
                }
                
                // Loading Indicator
                if isLoading {
                    ProgressView()
                        .scaleEffect(ResponsiveLayout.isIPad ? 2.0 : 1.5)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.black.opacity(0.1))
                }
            }
        }
        .background(AppTheme.adaptiveBackground)
        .navigationTitle("Resources")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    if locationEnabled {
                        // Request location update if permission is granted
                        locationService.requestLocation()
                    } else {
                        // Show location selector if permission is denied
                        showingLocationSelector = true
                    }
                }) {
                    Image(systemName: locationEnabled ? "location.fill" : "mappin.and.ellipse")
                }
            }
        }
        .sheet(isPresented: $showingLocationSelector) {
            LocationSelectorView(
                selectedCity: $resourceService.selectedCity,
                defaultCities: resourceService.defaultCities
            )
        }
        .alert(isPresented: $showingLocationPermissionAlert) {
            Alert(
                title: Text("Location Services Disabled"),
                message: Text("You can still use SafeHaven without location services. Select a city to find resources."),
                primaryButton: .default(Text("Select City"), action: {
                    showingLocationSelector = true
                }),
                secondaryButton: .cancel()
            )
        }
        .sheet(item: $selectedResource) { resource in
            ResourceDetailView(resource: resource)
        }
        .onAppear {
            // Check if location is enabled
            checkLocationStatus()
            
            // Always load resources when view appears to ensure fresh data
            loadResources()
        }
    }
    
    private func checkLocationStatus() {
        let status = locationService.authorizationStatus
        locationEnabled = (status == .authorizedWhenInUse || status == .authorizedAlways)
    }
    
    private func loadResources() {
        guard !isLoading else { return } // Prevent multiple simultaneous loads
        
        isLoading = true
        
        if let location = locationService.currentLocation, locationEnabled {
            // Use current location if available and authorized
            resourceService.fetchResources(category: selectedCategory, near: location) {
                isLoading = false
            }
        } else {
            // If location not available or not authorized, use selected city or default
            resourceService.fetchResources(category: selectedCategory, near: nil) {
                isLoading = false
                
                // If no city is selected and location is disabled, prompt to select a city
                if !locationEnabled && resourceService.selectedCity == nil {
                    self.showingLocationSelector = true
                }
            }
        }
    }
}

struct ResourceListContentView: View {
    let resources: [ResourceLocation]
    @Binding var selectedResource: ResourceLocation?
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                if resources.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 40))
                            .foregroundColor(AppTheme.primary.opacity(0.5))
                            .padding(.top, 40)
                        
                        Text("No resources found")
                            .font(.headline)
                            .foregroundColor(AppTheme.adaptiveTextPrimary)
                        
                        Text("Try selecting a different category or location")
                            .font(.subheadline)
                            .foregroundColor(AppTheme.adaptiveTextSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .padding(.top, 60)
                    .frame(maxWidth: .infinity)
                }
                
                ForEach(resources) { resource in
                    Button(action: {
                        selectedResource = resource
                    }) {
                        HStack(alignment: .top, spacing: 16) {
                            // Category icon
                            ZStack {
                                Circle()
                                    .fill(resource.category.color.opacity(0.2))
                                    .frame(width: 50, height: 50)
                                
                                Image(systemName: resource.category.icon)
                                    .font(.system(size: 20))
                                    .foregroundColor(resource.category.color)
                            }
                            
                            // Resource details
                            VStack(alignment: .leading, spacing: 5) {
                                Text(resource.name)
                                    .font(.headline)
                                    .foregroundColor(AppTheme.adaptiveTextPrimary)
                                
                                // Category
                                Text(resource.category.rawValue)
                                    .font(.caption)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 3)
                                    .background(resource.category.color)
                                    .cornerRadius(8)
                                
                                // Address
                                HStack(spacing: 4) {
                                    Image(systemName: "mappin.circle.fill")
                                        .font(.system(size: 12))
                                        .foregroundColor(AppTheme.adaptiveTextSecondary)
                                    
                                    Text(resource.address)
                                        .font(.caption)
                                        .foregroundColor(AppTheme.adaptiveTextSecondary)
                                        .lineLimit(1)
                                }
                                .padding(.top, 2)
                                
                                // Phone
                                HStack(spacing: 4) {
                                    Image(systemName: "phone.circle.fill")
                                        .font(.system(size: 12))
                                        .foregroundColor(AppTheme.adaptiveTextSecondary)
                                    
                                    Text(resource.phoneNumber)
                                        .font(.caption)
                                        .foregroundColor(AppTheme.adaptiveTextSecondary)
                                }
                            }
                            
                            Spacer()
                            
                            // Chevron
                            Image(systemName: "chevron.right")
                                .font(.system(size: 14))
                                .foregroundColor(AppTheme.adaptiveTextSecondary)
                                .padding(.top, 8)
                        }
                        .padding(16)
                        .background(AppTheme.adaptiveCardBackground)
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 3)
                    }
                }
            }
            .padding(16)
        }
        .background(AppTheme.adaptiveBackground)
    }
}
