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
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: ResponsiveLayout.padding(16)) {
                    // Header
                    headerSection(in: geometry)
                    
                    // Address & Phone
                    contactInformationSection(in: geometry)
                    
                    // Hours (if available)
                    if let hours = resource.hours {
                        hoursSection(hours: hours, in: geometry)
                    }
                    
                    // Description
                    descriptionSection(in: geometry)
                    
                    // Map
                    mapSection(in: geometry)
                    
                    // Action Buttons
                    actionButtonsSection(in: geometry)
                }
                .padding(ResponsiveLayout.padding())
            }
            .background(Color(hex: "F5F7FA"))
        }
        .navigationTitle("Resource Details")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarItems(trailing: Button(action: {
            presentationMode.wrappedValue.dismiss()
        }) {
            Image(systemName: "xmark.circle.fill")
                .font(.system(size: ResponsiveLayout.fontSize(20)))
                .foregroundColor(Color(hex: "718096"))
        })
    }
    
    private func headerSection(in geometry: GeometryProxy) -> some View {
        HStack {
            ZStack {
                Circle()
                    .fill(resource.category.color.opacity(0.2))
                    .frame(
                        width: ResponsiveLayout.isIPad ? 80 : 60,
                        height: ResponsiveLayout.isIPad ? 80 : 60
                    )
                
                Image(systemName: resource.icon)
                    .font(.system(
                        size: ResponsiveLayout.fontSize(30)
                    ))
                    .foregroundColor(resource.category.color)
            }
            
            VStack(alignment: .leading) {
                Text(resource.name)
                    .font(.system(
                        size: ResponsiveLayout.fontSize(22),
                        weight: .bold
                    ))
                    .foregroundColor(.primary)
                
                Text(resource.category.rawValue)
                    .font(.system(
                        size: ResponsiveLayout.fontSize(14)
                    ))
                    .foregroundColor(resource.category.color)
                    .padding(.horizontal, ResponsiveLayout.padding(10))
                    .padding(.vertical, ResponsiveLayout.padding(3))
                    .background(
                        Capsule()
                            .fill(resource.category.color.opacity(0.1))
                    )
            }
        }
        .padding(ResponsiveLayout.padding())
        .background(Color.white)
        .cornerRadius(ResponsiveLayout.isIPad ? 16 : 12)
    }
    
    private func contactInformationSection(in geometry: GeometryProxy) -> some View {
        VStack(alignment: .leading, spacing: ResponsiveLayout.padding(10)) {
            Text("Contact Information")
                .font(.system(
                    size: ResponsiveLayout.fontSize(18),
                    weight: .bold
                ))
            
            HStack {
                Image(systemName: "mappin.circle.fill")
                    .foregroundColor(.blue)
                    .font(.system(size: ResponsiveLayout.fontSize(20)))
                Text(resource.address)
                    .font(.system(size: ResponsiveLayout.fontSize(16)))
            }
            
            HStack {
                Image(systemName: "phone.circle.fill")
                    .foregroundColor(.green)
                    .font(.system(size: ResponsiveLayout.fontSize(20)))
                Button(action: {
                    makePhoneCall(resource.phoneNumber)
                }) {
                    Text(resource.phoneNumber)
                        .font(.system(size: ResponsiveLayout.fontSize(16)))
                        .foregroundColor(.blue)
                        .underline()
                }
            }
        }
        .padding(ResponsiveLayout.padding())
        .background(Color.white)
        .cornerRadius(ResponsiveLayout.isIPad ? 16 : 12)
    }
    
    private func hoursSection(hours: String, in geometry: GeometryProxy) -> some View {
        HStack {
            Image(systemName: "clock.fill")
                .foregroundColor(.orange)
                .font(.system(size: ResponsiveLayout.fontSize(20)))
            Text("Hours: \(hours)")
                .font(.system(size: ResponsiveLayout.fontSize(16)))
        }
        .padding(ResponsiveLayout.padding())
        .background(Color.white)
        .cornerRadius(ResponsiveLayout.isIPad ? 16 : 12)
    }
    
    private func descriptionSection(in geometry: GeometryProxy) -> some View {
        VStack(alignment: .leading, spacing: ResponsiveLayout.padding(10)) {
            Text("About")
                .font(.system(
                    size: ResponsiveLayout.fontSize(18),
                    weight: .bold
                ))
            
            Text(resource.description)
                .font(.system(size: ResponsiveLayout.fontSize(16)))
                .foregroundColor(.secondary)
        }
        .padding(ResponsiveLayout.padding())
        .background(Color.white)
        .cornerRadius(ResponsiveLayout.isIPad ? 16 : 12)
    }
    
    private func mapSection(in geometry: GeometryProxy) -> some View {
        Map(position: $mapPosition) {
            Marker(resource.name, coordinate: resource.coordinate)
                .tint(resource.category.color)
        }
        .mapStyle(.standard)
        .frame(height: ResponsiveLayout.isIPad ? 300 : 200)
        .cornerRadius(ResponsiveLayout.isIPad ? 16 : 8)
        .padding(ResponsiveLayout.padding())
    }
    
    private func actionButtonsSection(in geometry: GeometryProxy) -> some View {
        HStack(spacing: ResponsiveLayout.padding(16)) {
            Button(action: {
                getDirections(to: resource.coordinate)
            }) {
                HStack {
                    Image(systemName: "map.fill")
                    Text("Directions")
                }
                .frame(maxWidth: .infinity)
                .padding(ResponsiveLayout.padding())
                .background(resource.category.color)
                .foregroundColor(.white)
                .cornerRadius(ResponsiveLayout.isIPad ? 16 : 10)
            }
            
            Button(action: {
                makePhoneCall(resource.phoneNumber)
            }) {
                HStack {
                    Image(systemName: "phone.fill")
                    Text("Call")
                }
                .frame(maxWidth: .infinity)
                .padding(ResponsiveLayout.padding())
                .background(resource.category.color)
                .foregroundColor(.white)
                .cornerRadius(ResponsiveLayout.isIPad ? 16 : 10)
            }
        }
        .padding(.horizontal, ResponsiveLayout.padding())
        .padding(.bottom, ResponsiveLayout.padding(20))
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
