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
    
    // Prevent too many resource reloads
    @State private var lastLoadTime = Date()
    
    enum ViewMode {
        case map, list
    }
    
    var filteredResources: [ResourceLocation] {
        let filtered = resourceService.resources.filter { resource in
            (selectedCategory == .all || resource.category == selectedCategory) &&
            (searchText.isEmpty ||
             resource.name.localizedCaseInsensitiveContains(searchText) ||
             resource.category.rawValue.localizedCaseInsensitiveContains(searchText))
        }
        print("Search text: \(searchText), Found \(filtered.count) resources out of \(resourceService.resources.count)")
        return filtered
    }

    var body: some View {
        // Removed the NavigationView to use full screen
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
                                color: category.color
                            ) {
                                if selectedCategory != category {
                                    selectedCategory = category
                                    loadResources()
                                }
                            }
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
            .background(Color(hex: "F5F7FA"))
            
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
                case .list:
                    ListContentView(
                        resources: filteredResources,
                        selectedResource: $selectedResource
                    )
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
        .navigationTitle("Resources")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $selectedResource) { resource in
            ResourceDetailView(resource: resource)
        }
        .onAppear {
            // Only request permissions and load resources if we don't already have them
            if locationService.authorizationStatus == .notDetermined {
                locationService.requestLocation()
            }
            
            if resourceService.resources.isEmpty {
                loadResources()
            }
        }
    }
    
    // In ResourcesView.swift - performSearch function
    private func performSearch() {
        guard !searchText.isEmpty else { return }
        isLoading = true
        
        // Explicitly update UI to show loading state
        withAnimation {
            // This will force UI update
            resourceService.resources = []
        }
        
        if let location = locationService.currentLocation {
            // Use a broader search with multiple terms and categories
            resourceService.searchAnyPlace(query: searchText, near: location, radius: 25000) {
                // Search completed
                self.isLoading = false
            }
        } else {
            // Use default location if user location isn't available
            let defaultLocation = CLLocation(latitude: 37.7749, longitude: -122.4194)
            resourceService.searchAnyPlace(query: searchText, near: defaultLocation, radius: 25000) {
                self.isLoading = false
            }
        }
    }
    
    private func loadResources() {
        guard !isLoading else { return } // Prevent multiple simultaneous loads
        
        isLoading = true
        
        if let location = locationService.currentLocation {
            // Add a small delay to ensure UI updates properly
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                resourceService.fetchResources(category: selectedCategory, near: location) {
                    isLoading = false
                }
            }
        } else {
            // If location not available, try to use a default location or ask for permission
            if locationService.authorizationStatus == .authorizedWhenInUse ||
               locationService.authorizationStatus == .authorizedAlways {
                // Location permission granted but no location yet - try to get location
                locationService.requestLocation()
                
                // Wait briefly then check again
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    if let location = locationService.currentLocation {
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
