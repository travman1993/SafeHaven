import SwiftUI
import CoreLocation
import MapKit

struct ResourcesView: View {
    @StateObject private var locationService = LocationService()
    @StateObject private var resourceService = ResourceService()
    
    @State private var selectedCategory: ResourceCategory = .all
    @State private var searchText = ""
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
        // When doing a search, don't filter by category
        if !searchText.isEmpty {
            let searchFiltered = resourceService.resources.filter { resource in
                resource.name.localizedCaseInsensitiveContains(searchText) ||
                resource.category.rawValue.localizedCaseInsensitiveContains(searchText) ||
                resource.address.localizedCaseInsensitiveContains(searchText) ||
                resource.description.localizedCaseInsensitiveContains(searchText)
            }
            print("Search filter: \(searchText), Found \(searchFiltered.count) resources out of \(resourceService.resources.count)")
            return searchFiltered
        }
        
        // When not searching, filter by selected category
        let categoryFiltered = selectedCategory == .all ?
            resourceService.resources :
            resourceService.resources.filter { $0.category == selectedCategory }
            
        print("Category filter: \(selectedCategory.rawValue), Found \(categoryFiltered.count) resources out of \(resourceService.resources.count)")
        return categoryFiltered
    }

    var body: some View {
        VStack(spacing: 0) {
            // Search and Filter Section
            VStack(spacing: ResponsiveLayout.padding(12)) {
                // Search Bar
                SearchBar(text: $searchText, placeholder: "Search resources...", onSubmit: {
                    performSearch()
                })
                .padding(.horizontal, ResponsiveLayout.padding())
                
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
                
                // View Mode Toggle
                Picker("View Mode", selection: $viewMode) {
                    Image(systemName: "list.bullet").tag(ViewMode.list)
                    Image(systemName: "map").tag(ViewMode.map)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal, ResponsiveLayout.padding())
            }
            .padding(.vertical, ResponsiveLayout.padding())
            .background(AppTheme.adaptiveBackground)
            
            // Content View
            ZStack {
                switch viewMode {
                case .map:
                    // Use the new map component with anti-flickering measures
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
            
            // Only load resources if we don't already have them
            if resourceService.resources.isEmpty {
                loadResources()
            }
        }
    }
    
    private func checkLocationStatus() {
        let status = locationService.authorizationStatus
        locationEnabled = (status == .authorizedWhenInUse || status == .authorizedAlways)
    }
    
    private func performSearch() {
        guard !searchText.isEmpty else { return }
        isLoading = true
        
        // Explicitly update UI to show loading state
        withAnimation {
            // This will force UI update
            resourceService.resources = []
        }
        
        print("Searching for: \(searchText)")
        
        if let location = locationService.currentLocation, locationEnabled {
            print("Using current location for search")
            // Use a broader search with multiple terms and categories
            resourceService.searchAnyPlace(query: searchText, near: location, radius: 25000) {
                // Search completed
                self.isLoading = false
                print("Search completed, found \(self.resourceService.resources.count) results")
            }
        } else {
            print("Using selected city or default location for search")
            // Use selected city or default location
            resourceService.searchAnyPlace(query: searchText, near: nil, radius: 25000) {
                self.isLoading = false
                print("Search completed, found \(self.resourceService.resources.count) results")
            }
        }
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

struct SearchBar: View {
    @Binding var text: String
    var placeholder: String
    var onSubmit: (() -> Void)? = nil
    @FocusState private var isInputFocused: Bool
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(text.isEmpty ? AppTheme.adaptiveTextSecondary : AppTheme.primary)
            
            TextField(placeholder, text: $text)
                .font(.system(size: 16))
                .foregroundColor(AppTheme.adaptiveTextPrimary)
                .focused($isInputFocused)
                .submitLabel(.search)
                .onSubmit {
                    print("Search submitted: \(text)")
                    isInputFocused = false
                    onSubmit?() // This is where the search function is called
                }
            
            // Add a dedicated search button for clarity
            if !text.isEmpty {
                Button(action: {
                    isInputFocused = false
                    onSubmit?() // Explicitly call search function
                }) {
                    Text("Search")
                        .foregroundColor(AppTheme.primary)
                        .padding(.horizontal, 10)
                }
            }
            
            // Clear button
            if !text.isEmpty {
                Button(action: {
                    text = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(AppTheme.adaptiveTextSecondary)
                }
            }
        }
        .padding(12)
        .background(AppTheme.adaptiveCardBackground)
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

struct ResourceListContentView: View {
    let resources: [ResourceLocation]
    @Binding var selectedResource: ResourceLocation?
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
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
