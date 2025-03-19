//
//  ResourceDetailView.swift
//  SafeHaven
//
//  Created by Travis Rodriguez on 2/28/25.
//
import SwiftUI
import MapKit

struct ResourceDetailView: View {
    let resource: ResourceLocation
    @Environment(\.presentationMode) var presentationMode
    @State private var mapPosition: MapCameraPosition
    
    init(resource: ResourceLocation) {
        self.resource = resource
        // Initialize map camera position
        self._mapPosition = State(initialValue: .region(MKCoordinateRegion(
            center: resource.coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        )))
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Header
                HStack {
                    ZStack {
                        Circle()
                            .fill(resource.category.color.opacity(0.2))
                            .frame(width: 60, height: 60)
                        
                        Image(systemName: resource.icon)
                            .font(.system(size: 30))
                            .foregroundColor(resource.category.color)
                    }
                    
                    VStack(alignment: .leading) {
                        Text(resource.name)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        Text(resource.category.rawValue)
                            .font(.subheadline)
                            .foregroundColor(resource.category.color)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 3)
                            .background(
                                Capsule()
                                    .fill(resource.category.color.opacity(0.1))
                            )
                    }
                }
                .padding()
                .background(Color.white)
                .cornerRadius(12)
                
                // Address & Phone
                VStack(alignment: .leading, spacing: 10) {
                    Text("Contact Information")
                        .font(.headline)
                    
                    HStack {
                        Image(systemName: "mappin.circle.fill")
                            .foregroundColor(.blue)
                        Text(resource.address)
                    }
                    
                    HStack {
                        Image(systemName: "phone.circle.fill")
                            .foregroundColor(.green)
                        Button(action: {
                            makePhoneCall(resource.phoneNumber)
                        }) {
                            Text(resource.phoneNumber)
                                .foregroundColor(.blue)
                                .underline()
                        }
                    }
                }
                .padding()
                .background(Color.white)
                .cornerRadius(12)
                
                // Hours
                if let hours = resource.hours {
                    HStack {
                        Image(systemName: "clock.fill")
                            .foregroundColor(.orange)
                        Text("Hours: \(hours)")
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                }
                
                // Description
                VStack(alignment: .leading, spacing: 10) {
                    Text("About")
                        .font(.headline)
                    
                    Text(resource.description)
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color.white)
                .cornerRadius(12)
                
                // Map
                Map(position: $mapPosition) {
                    Marker(resource.name, coordinate: resource.coordinate)
                        .tint(resource.category.color)
                }
                .mapStyle(.standard)
                .frame(height: 200)
                .cornerRadius(8)
                .padding()
                
                // Action Buttons
                HStack(spacing: 16) {
                    Button(action: {
                        getDirections(to: resource.coordinate)
                    }) {
                        HStack {
                            Image(systemName: "map.fill")
                            Text("Directions")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(resource.category.color)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    
                    Button(action: {
                        makePhoneCall(resource.phoneNumber)
                    }) {
                        HStack {
                            Image(systemName: "phone.fill")
                            Text("Call")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(resource.category.color)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
            .padding()
            .background(Color(hex: "F5F7FA"))
        }
        .navigationTitle("Resource Details")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarItems(trailing: Button(action: {
            presentationMode.wrappedValue.dismiss()
        }) {
            Image(systemName: "xmark.circle.fill")
                .font(.system(size: 20))
                .foregroundColor(Color(hex: "718096"))
        })
    }
    
    // Helper function to make phone calls
    private func makePhoneCall(_ number: String) {
        let cleanNumber = number.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
        if let url = URL(string: "tel://\(cleanNumber)"), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
    
    // Helper function to get directions
    private func getDirections(to coordinate: CLLocationCoordinate2D) {
        let placemark = MKPlacemark(coordinate: coordinate)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = resource.name
        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
    }
}
