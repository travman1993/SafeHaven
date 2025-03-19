//
//  ResourceModels.swift
//  SafeHaven
//
//  Created by Travis Rodriguez on 3/19/25.
//
//
//  ResourceModels.swift
//  SafeHaven
//
//  Created by Claude on 3/19/25.
//

import Foundation
import SwiftUI
import CoreLocation

enum ResourceCategory: String, CaseIterable, Identifiable {
    case all = "All Resources"
    case shelter = "Shelter"
    case food = "Food & Meals"
    case healthcare = "Healthcare"
    case mentalHealth = "Mental Health"
    case addiction = "Addiction Services"
    case legal = "Legal Aid"
    case employment = "Employment"
    case transportation = "Transportation"
    case family = "Family Support"
    case education = "Education"
    
    var id: String { self.rawValue }
    
    var icon: String {
        switch self {
        case .all: return "square.grid.2x2.fill"
        case .shelter: return "house.fill"
        case .food: return "fork.knife"
        case .healthcare: return "cross.fill"
        case .mentalHealth: return "brain.head.profile"
        case .addiction: return "hand.raised.fill"
        case .legal: return "building.columns.fill"
        case .employment: return "briefcase.fill"
        case .transportation: return "bus.fill"
        case .family: return "figure.2.and.child.holdinghands"
        case .education: return "book.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .all: return Color(hex: "6A89CC")
        case .shelter: return Color(hex: "F9844A")
        case .food: return Color(hex: "4D908E")
        case .healthcare: return Color(hex: "F94144")
        case .mentalHealth: return Color(hex: "577590")
        case .addiction: return Color(hex: "F8961E")
        case .legal: return Color(hex: "90BE6D")
        case .employment: return Color(hex: "43AA8B")
        case .transportation: return Color(hex: "277DA1")
        case .family: return Color(hex: "F3722C")
        case .education: return Color(hex: "577590")
        }
    }
}

struct ResourceLocation: Identifiable, Hashable {
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
    
    // For SwiftUI sheet presentation and Hashable conformance
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: ResourceLocation, rhs: ResourceLocation) -> Bool {
        lhs.id == rhs.id
    }
    
    // Add Equatable conformance for CLLocationCoordinate2D
    private func coordinatesEqual(_ lhs: CLLocationCoordinate2D, _ rhs: CLLocationCoordinate2D) -> Bool {
        return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}

// MARK: - Custom Views for Resource Display

struct CategoryChip: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 12))
                
                Text(title)
                    .font(.system(size: 13, weight: .medium))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? color : color.opacity(0.1))
            )
            .foregroundColor(isSelected ? .white : color)
        }
    }
}

struct ResourceMapPin: View {
    let resource: ResourceLocation
    var onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 0) {
                ZStack {
                    Circle()
                        .fill(resource.category.color)
                        .frame(width: 36, height: 36)
                    
                    Image(systemName: resource.category.icon)
                        .font(.system(size: 18))
                        .foregroundColor(.white)
                }
                
                Image(systemName: "triangle.fill")
                    .font(.system(size: 12))
                    .foregroundColor(resource.category.color)
                    .rotationEffect(.degrees(180))
                    .offset(y: -5)
            }
        }
    }
}

struct ListContentView: View {
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
                                    .foregroundColor(AppTheme.textPrimary)
                                
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
                                        .foregroundColor(AppTheme.textSecondary)
                                    
                                    Text(resource.address)
                                        .font(.caption)
                                        .foregroundColor(AppTheme.textSecondary)
                                        .lineLimit(1)
                                }
                                .padding(.top, 2)
                                
                                // Phone
                                HStack(spacing: 4) {
                                    Image(systemName: "phone.circle.fill")
                                        .font(.system(size: 12))
                                        .foregroundColor(AppTheme.textSecondary)
                                    
                                    Text(resource.phoneNumber)
                                        .font(.caption)
                                        .foregroundColor(AppTheme.textSecondary)
                                }
                            }
                            
                            Spacer()
                            
                            // Chevron
                            Image(systemName: "chevron.right")
                                .font(.system(size: 14))
                                .foregroundColor(AppTheme.textSecondary)
                                .padding(.top, 8)
                        }
                        .padding(16)
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 3)
                    }
                }
            }
            .padding(16)
        }
        .background(AppTheme.background)
    }
}
