//
//  ResourceDetailView.swift
//  SafeHaven
//
//  Created by Travis Rodriguez on 2/28/25.
//

import Foundation
import SwiftUI
import CloudKit
import WeatherKit
import CoreLocation
import AuthenticationServices

struct ResourceDetailView: View {
    let resource: ResourceLocation
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Header
                    HStack {
                        ZStack {
                            Circle()
                                .fill(Color(hex: "6A89CC").opacity(0.2))
                                .frame(width: 60, height: 60)
                            
                            Image(systemName: resource.icon)
                                .font(.system(size: 30))
                                .foregroundColor(Color(hex: "6A89CC"))
                        }

                        VStack(alignment: .leading) {
                            Text(resource.name)
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)

                            Text(resource.category.rawValue)
                                .font(.subheadline)
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
                            Text(resource.phoneNumber)
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
                    Map(coordinateRegion: .constant(MKCoordinateRegion(
                        center: resource.coordinate,
                        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                    )))
                    .frame(height: 200)
                    .cornerRadius(8)
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
