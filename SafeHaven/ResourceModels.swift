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
    case shelter = "Shelter & Housing"
    case food = "Food & Meals"
    case healthcare = "Healthcare"
    case mentalHealth = "Mental Health"
    case substanceSupport = "Substance Support"
    case crisis = "Crisis Services"
    case legalAid = "Legal Aid"
    case immigration = "Immigration Help"
    case financial = "Financial Assistance"
    case employment = "Employment"
    case education = "Education"
    case transportation = "Transportation"
    case family = "Family Services"
    case veterans = "Veterans Services"
    case lgbtq = "LGBTQ+ Support"
    case youthServices = "Youth Services"
    case domesticViolence = "Domestic Violence"
    
    var id: String { self.rawValue }
    
    var icon: String {
        switch self {
        case .all: return "square.grid.2x2.fill"
        case .shelter: return "house.fill"
        case .food: return "fork.knife"
        case .healthcare: return "cross.fill"
        case .mentalHealth: return "brain.head.profile"
        case .substanceSupport: return "pills.fill"
        case .crisis: return "exclamationmark.triangle.fill"
        case .legalAid: return "building.columns.fill"
        case .immigration: return "globe"
        case .financial: return "dollarsign.circle.fill"
        case .employment: return "briefcase.fill"
        case .education: return "book.fill"
        case .transportation: return "bus.fill"
        case .family: return "figure.2.and.child.holdinghands"
        case .veterans: return "shield.fill"
        case .lgbtq: return "heart.fill"
        case .youthServices: return "figure.child"
        case .domesticViolence: return "house.lodge"
        }
    }
    
    var color: Color {
        switch self {
        case .all: return Color(hex: "6A89CC")
        case .shelter: return Color(hex: "F9844A")
        case .food: return Color(hex: "4D908E")
        case .healthcare: return Color(hex: "F94144")
        case .mentalHealth: return Color(hex: "577590")
        case .substanceSupport: return Color(hex: "F8961E")
        case .crisis: return Color(hex: "E63946")
        case .legalAid: return Color(hex: "90BE6D")
        case .immigration: return Color(hex: "0096C7")
        case .financial: return Color(hex: "43AA8B")
        case .employment: return Color(hex: "277DA1")
        case .education: return Color(hex: "577590")
        case .transportation: return Color(hex: "277DA1")
        case .family: return Color(hex: "F3722C")
        case .veterans: return Color(hex: "1D3557")
        case .lgbtq: return Color(hex: "F37EF9")
        case .youthServices: return Color(hex: "FFC8DD")
        case .domesticViolence: return Color(hex: "D00000")
        }
    }
    
    // More specific search keywords for each category
    var searchKeywords: [String] {
        switch self {
        case .all:
            return ["help", "assistance", "resources", "support", "services", "aid"]
            
        case .shelter:
            return ["shelter", "homeless shelter", "emergency housing", "transitional housing", 
                    "affordable housing", "rent help", "housing assistance", "eviction", 
                    "women's shelter", "men's shelter", "temporary shelter"]
            
        case .food:
            return ["food bank", "food pantry", "free meals", "soup kitchen", "meal program", 
                    "grocery assistance", "emergency food", "community meals", "food stamps", 
                    "SNAP benefits", "WIC", "hunger"]
            
        case .healthcare:
            return ["free clinic", "community health", "medical care", "doctor", "health center", 
                    "emergency medical", "dental care", "vision care", "prescription", "medication assistance", 
                    "health insurance", "medicaid", "medicare"]
            
        case .mentalHealth:
            return ["mental health", "counseling", "therapy", "psychiatrist", "psychologist", 
                    "depression", "anxiety", "trauma", "crisis counseling", "support group", 
                    "mental illness", "behavioral health"]
            
        case .substanceSupport:
            return ["substance abuse", "addiction", "recovery", "detox", "rehab", "treatment center", 
                    "alcoholics anonymous", "narcotics anonymous", "sober living", "drug counseling", 
                    "alcohol treatment", "opioid treatment"]
            
        case .crisis:
            return ["crisis center", "suicide prevention", "crisis hotline", "emergency services", 
                    "crisis intervention", "disaster relief", "emergency assistance", "crisis support"]
            
        case .legalAid:
            return ["legal aid", "free legal", "legal assistance", "lawyer", "attorney", "legal rights", 
                    "legal clinic", "public defender", "legal advocacy", "law help", "court help", 
                    "legal services", "tenant rights", "consumer rights"]
            
        case .immigration:
            return ["immigration services", "immigrant rights", "refugee", "asylum", "immigration lawyer", 
                    "deportation", "DACA", "citizenship", "green card", "visa help", "immigration legal", 
                    "undocumented", "migrant"]
            
        case .financial:
            return ["financial assistance", "emergency cash", "bill pay assistance", "utility assistance", 
                    "rent assistance", "financial counseling", "debt help", "tax help", "benefits", 
                    "financial aid", "low income", "welfare", "financial support"]
            
        case .employment:
            return ["job training", "employment center", "job search", "career counseling", "resume help", 
                    "vocational training", "workforce development", "job placement", "unemployment", 
                    "work program", "job skills", "job fair"]
            
        case .education:
            return ["adult education", "GED program", "literacy program", "ESL class", "educational assistance", 
                    "school supplies", "tutoring", "college access", "financial aid", "scholarship", 
                    "education resources", "computer training"]
            
        case .transportation:
            return ["transportation assistance", "bus pass", "reduced fare", "ride service", "medical transport", 
                    "free transportation", "car repair", "gas voucher", "transit", "ride share", "commuter assistance"]
            
        case .family:
            return ["family support", "childcare", "parenting classes", "family counseling", "child support", 
                    "family resources", "after school", "family assistance", "children services", 
                    "family crisis", "parent help"]
            
        case .veterans:
            return ["veteran services", "VA", "veteran benefits", "veteran housing", "veteran healthcare", 
                    "veteran employment", "military", "veteran assistance", "veteran support", 
                    "VA hospital", "veteran counseling"]
            
        case .lgbtq:
            return ["LGBTQ", "LGBTQ+ support", "gay", "lesbian", "transgender", "queer", "LGBTQ health", 
                    "LGBTQ youth", "LGBTQ housing", "LGBTQ counseling", "LGBTQ center", "LGBTQ resources"]
            
        case .youthServices:
            return ["youth services", "teen center", "youth shelter", "youth program", "children services", 
                    "youth counseling", "after school program", "juvenile", "teen support", 
                    "foster youth", "runaway", "youth outreach"]
            
        case .domesticViolence:
            return ["domestic violence", "abuse shelter", "women's shelter", "abuse hotline", "safety planning", 
                    "protective order", "family violence", "intimate partner violence", "abuse support", 
                    "safe house", "victim services", "battering"]
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

// Helper function to determine category based on search terms or place attributes
func determineCategoryFromSearch(_ query: String, placeName: String) -> ResourceCategory {
    let lowercaseQuery = query.lowercased()
    let lowercaseName = placeName.lowercased()
    
    // Check each category's keywords for matches
    for category in ResourceCategory.allCases where category != .all {
        for keyword in category.searchKeywords {
            if lowercaseQuery.contains(keyword) || lowercaseName.contains(keyword) {
                return category
            }
        }
    }
    
    // Default to all if no matches
    return .all
}

// Enhanced search query helper
func enhanceSearchQuery(_ query: String) -> String {
    let lowercaseQuery = query.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
    
    // If query is very short (1-2 words), add general terms
    let wordCount = lowercaseQuery.split(separator: " ").count
    if wordCount <= 2 {
        return "\(query) assistance services help"
    }
    
    return query
}
