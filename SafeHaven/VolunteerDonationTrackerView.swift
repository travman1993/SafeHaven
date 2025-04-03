//
//  VolunteerDonationTrackerView.swift
//  SafeHaven
//
//  Created by Travis Rodriguez on 4/3/25.
//
import SwiftUI
import CoreLocation
import MapKit

// MARK: - Helper Classes and Models

// MARK: - Volunteer and Donation Models
struct VolunteerActivity: Identifiable {
    let id = UUID()
    let organization: String
    let hours: Int
    let date: Date
    let verified: Bool
}

struct DonationActivity: Identifiable {
    let id = UUID()
    let organization: String
    let items: String
    let date: Date
    let verified: Bool
}

// MARK: - Volunteer and Donation Tracker View
struct VolunteerDonationTrackerView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTab = 0
    @State private var showingAddVolunteerSheet = false
    @State private var showingAddDonationSheet = false
    
    // Sample user stats
    @State private var totalVolunteerHours = 12
    @State private var totalDonations = 5
    @State private var userLevel = "Bronze Helper"
    @State private var progress: CGFloat = 0.48 // Progress to next level
    
    // Sample activities
    @State private var volunteerActivities: [VolunteerActivity] = []
    @State private var donationActivities: [DonationActivity] = []
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Stats card
                statsCard
                    .padding()
                
                // Tab selector
                Picker("Activity Type", selection: $selectedTab) {
                    Text("Volunteer Hours").tag(0)
                    Text("Donations").tag(1)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                
                // Tab content
                TabView(selection: $selectedTab) {
                    volunteerTab.tag(0)
                    donationTab.tag(1)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .animation(.easeInOut, value: selectedTab)
            }
            .background(AppTheme.adaptiveBackground.ignoresSafeArea())
            .navigationTitle("Activity Tracker")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        if selectedTab == 0 {
                            showingAddVolunteerSheet = true
                        } else {
                            showingAddDonationSheet = true
                        }
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddVolunteerSheet) {
                AddVolunteerActivityView { organization, hours in
                    let newActivity = VolunteerActivity(
                        organization: organization,
                        hours: hours,
                        date: Date(),
                        verified: false
                    )
                    volunteerActivities.insert(newActivity, at: 0)
                    totalVolunteerHours += hours
                    updateLevel()
                }
            }
            .sheet(isPresented: $showingAddDonationSheet) {
                AddDonationActivityView { organization, items in
                    let newActivity = DonationActivity(
                        organization: organization,
                        items: items,
                        date: Date(),
                        verified: false
                    )
                    donationActivities.insert(newActivity, at: 0)
                    totalDonations += 1
                    updateLevel()
                }
            }
            .onAppear {
                if volunteerActivities.isEmpty {
                    // Load sample data
                    volunteerActivities = [
                        VolunteerActivity(organization: "Local Food Bank", hours: 4, date: Date().addingTimeInterval(-7*24*60*60), verified: true),
                        VolunteerActivity(organization: "Community Garden", hours: 3, date: Date().addingTimeInterval(-14*24*60*60), verified: true),
                        VolunteerActivity(organization: "Animal Shelter", hours: 5, date: Date().addingTimeInterval(-21*24*60*60), verified: true)
                    ]
                    
                    donationActivities = [
                        DonationActivity(organization: "Homeless Shelter", items: "Winter Clothes", date: Date().addingTimeInterval(-3*24*60*60), verified: true),
                        DonationActivity(organization: "Food Bank", items: "Canned Goods", date: Date().addingTimeInterval(-10*24*60*60), verified: true),
                        DonationActivity(organization: "School Drive", items: "School Supplies", date: Date().addingTimeInterval(-17*24*60*60), verified: true),
                        DonationActivity(organization: "Disaster Relief", items: "Hygiene Kits", date: Date().addingTimeInterval(-24*24*60*60), verified: true),
                        DonationActivity(organization: "Clothing Drive", items: "Winter Jackets", date: Date().addingTimeInterval(-30*24*60*60), verified: true)
                    ]
                }
            }
        }
    }
    
    private var volunteerTab: some View {
        ScrollView {
            VStack(spacing: ResponsiveLayout.padding(16)) {
                if volunteerActivities.isEmpty {
                    emptyStateView(
                        image: "clock.fill",
                        title: "No Volunteer Hours",
                        message: "Log your volunteer hours to track your contributions and earn recognition"
                    )
                } else {
                    ForEach(volunteerActivities) { activity in
                        volunteerActivityRow(activity)
                    }
                }
            }
            .padding()
        }
    }
    
    private var donationTab: some View {
        ScrollView {
            VStack(spacing: ResponsiveLayout.padding(16)) {
                if donationActivities.isEmpty {
                    emptyStateView(
                        image: "gift.fill",
                        title: "No Donations",
                        message: "Log the items you've donated to help those in need and track your contributions"
                    )
                } else {
                    ForEach(donationActivities) { activity in
                        donationActivityRow(activity)
                    }
                }
            }
            .padding()
        }
    }
    
    private func volunteerActivityRow(_ activity: VolunteerActivity) -> some View {
        HStack {
            Circle()
                .fill(AppTheme.primary.opacity(0.2))
                .frame(width: 50, height: 50)
                .overlay(
                    Image(systemName: "clock.fill")
                        .foregroundColor(AppTheme.primary)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(activity.organization)
                    .font(.system(size: ResponsiveLayout.fontSize(16), weight: .semibold))
                    .foregroundColor(AppTheme.adaptiveTextPrimary)
                
                HStack {
                    Text("\(activity.hours) hours")
                        .font(.system(size: ResponsiveLayout.fontSize(14)))
                        .foregroundColor(AppTheme.adaptiveTextSecondary)
                    
                    Spacer()
                    
                    Text(activity.date, style: .date)
                        .font(.system(size: ResponsiveLayout.fontSize(12)))
                        .foregroundColor(AppTheme.adaptiveTextSecondary)
                }
                
                if activity.verified {
                    HStack {
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundColor(.green)
                            .font(.system(size: 10))
                        
                        Text("Verified")
                            .font(.system(size: 10))
                            .foregroundColor(.green)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(4)
                }
            }
            .padding(.leading, 8)
        }
        .padding()
        .background(AppTheme.adaptiveCardBackground)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    private func donationActivityRow(_ activity: DonationActivity) -> some View {
        HStack {
            Circle()
                .fill(Color(hex: "E8505B").opacity(0.2))
                .frame(width: 50, height: 50)
                .overlay(
                    Image(systemName: "gift.fill")
                        .foregroundColor(Color(hex: "E8505B"))
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(activity.organization)
                    .font(.system(size: ResponsiveLayout.fontSize(16), weight: .semibold))
                    .foregroundColor(AppTheme.adaptiveTextPrimary)
                
                HStack {
                    Text(activity.items)
                        .font(.system(size: ResponsiveLayout.fontSize(14)))
                        .foregroundColor(AppTheme.adaptiveTextSecondary)
                    
                    Spacer()
                    
                    Text(activity.date, style: .date)
                        .font(.system(size: ResponsiveLayout.fontSize(12)))
                        .foregroundColor(AppTheme.adaptiveTextSecondary)
                }
                
                if activity.verified {
                    HStack {
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundColor(.green)
                            .font(.system(size: 10))
                        
                        Text("Verified")
                            .font(.system(size: 10))
                            .foregroundColor(.green)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(4)
                }
            }
            .padding(.leading, 8)
        }
        .padding()
        .background(AppTheme.adaptiveCardBackground)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    private func emptyStateView(image: String, title: String, message: String) -> some View {
        VStack(spacing: ResponsiveLayout.padding(16)) {
            Image(systemName: image)
                .font(.system(size: ResponsiveLayout.fontSize(48)))
                .foregroundColor(AppTheme.adaptiveTextSecondary.opacity(0.5))
                .padding(.bottom, 8)
            
            Text(title)
                .font(.system(size: ResponsiveLayout.fontSize(18), weight: .semibold))
                .foregroundColor(AppTheme.adaptiveTextPrimary)
            
            Text(message)
                .font(.system(size: ResponsiveLayout.fontSize(14)))
                .foregroundColor(AppTheme.adaptiveTextSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button(action: {
                if selectedTab == 0 {
                    showingAddVolunteerSheet = true
                } else {
                    showingAddDonationSheet = true
                }
            }) {
                Text(selectedTab == 0 ? "Log Hours" : "Log Donation")
                    .font(.system(size: ResponsiveLayout.fontSize(16), weight: .medium))
                    .padding(.vertical, 12)
                    .padding(.horizontal, 24)
                    .background(selectedTab == 0 ? AppTheme.primary : Color(hex: "E8505B"))
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .padding(.top, 8)
        }
        .padding()
        .frame(maxWidth: .infinity)
    }
    
    private func updateLevel() {
        // Simple logic to update level based on hours
        if totalVolunteerHours >= 50 {
            userLevel = "Gold Helper"
            progress = 1.0
        } else if totalVolunteerHours >= 25 {
            userLevel = "Silver Helper"
            progress = (CGFloat(totalVolunteerHours) - 25) / 25
        } else {
            userLevel = "Bronze Helper"
            progress = CGFloat(totalVolunteerHours) / 25
        }
    }
    
    private var statsCard: some View {
        VStack(spacing: ResponsiveLayout.padding(16)) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(userLevel)
                        .font(.system(size: ResponsiveLayout.fontSize(20), weight: .bold))
                        .foregroundColor(AppTheme.adaptiveTextPrimary)
                    
                    HStack(spacing: 12) {
                        VStack(alignment: .leading) {
                            Text("\(totalVolunteerHours)")
                                .font(.system(size: ResponsiveLayout.fontSize(24), weight: .bold))
                                .foregroundColor(AppTheme.primary)
                            
                            Text("Hours")
                                .font(.system(size: ResponsiveLayout.fontSize(14)))
                                .foregroundColor(AppTheme.adaptiveTextSecondary)
                        }
                        
                        Divider()
                            .frame(height: 30)
                        
                        VStack(alignment: .leading) {
                            Text("\(totalDonations)")
                                .font(.system(size: ResponsiveLayout.fontSize(24), weight: .bold))
                                .foregroundColor(Color(hex: "E8505B"))
                            
                            Text("Donations")
                                .font(.system(size: ResponsiveLayout.fontSize(14)))
                                .foregroundColor(AppTheme.adaptiveTextSecondary)
                        }
                    }
                }
                
                Spacer()
                
                LevelBadgeView(level: userLevel)
            }
            
            // Progress to next level
            VStack(alignment: .leading, spacing: 4) {
                Text("Progress to Silver Helper")
                    .font(.system(size: ResponsiveLayout.fontSize(14)))
                    .foregroundColor(AppTheme.adaptiveTextSecondary)
                
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 8)
                        .cornerRadius(4)
                    
                    Rectangle()
                        .fill(LinearGradient(gradient: Gradient(colors: [AppTheme.primary, Color(hex: "E8505B")]), startPoint: .leading, endPoint: .trailing))
                        .frame(width: UIScreen.main.bounds.width * 0.85 * progress, height: 8)
                        .cornerRadius(4)
                }
                
                Text("12 more hours to reach next level")
                    .font(.system(size: ResponsiveLayout.fontSize(12)))
                    .foregroundColor(AppTheme.adaptiveTextSecondary)
            }
        }
        .padding()
        .background(AppTheme.adaptiveCardBackground)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

// MARK: - Volunteer & Donation Tracker Card
struct VolunteerDonationCard: View {
    @State private var showingTrackerView = false
    
    var body: some View {
        Button(action: {
            showingTrackerView = true
        }) {
            VStack(alignment: .leading, spacing: ResponsiveLayout.padding(12)) {
                HStack {
                    Image(systemName: "heart.fill")
                        .font(.system(size: ResponsiveLayout.fontSize(24)))
                        .foregroundColor(Color(hex: "E8505B"))
                    
                    Text("Volunteer & Donation Tracker")
                        .font(.system(size: ResponsiveLayout.fontSize(18), weight: .semibold))
                        .foregroundColor(AppTheme.adaptiveTextPrimary)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .foregroundColor(AppTheme.adaptiveTextSecondary)
                }
                
                Text("Empower people to give more and stay engaged")
                    .font(.system(size: ResponsiveLayout.fontSize(14)))
                    .foregroundColor(AppTheme.adaptiveTextSecondary)
                    .padding(.top, 2)
                
                HStack(spacing: ResponsiveLayout.padding(12)) {
                    Feature(icon: "clock.fill", text: "Log volunteer hours")
                    Feature(icon: "gift.fill", text: "Track donations")
                    Feature(icon: "star.fill", text: "Earn recognition")
                }
                .padding(.top, 8)
            }
            .padding(ResponsiveLayout.padding())
            .background(AppTheme.adaptiveCardBackground)
            .cornerRadius(ResponsiveLayout.isIPad ? 20 : 16)
            .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 4)
        }
        .sheet(isPresented: $showingTrackerView) {
            VolunteerDonationTrackerView()
        }
    }
    
    private struct Feature: View {
        let icon: String
        let text: String
        
        var body: some View {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: ResponsiveLayout.fontSize(12)))
                    .foregroundColor(Color(hex: "E8505B"))
                
                Text(text)
                    .font(.system(size: ResponsiveLayout.fontSize(12)))
                    .foregroundColor(AppTheme.adaptiveTextSecondary)
            }
        }
    }
}

// Badge View
struct LevelBadgeView: View {
    let level: String
    
    var body: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            badgeColor.opacity(0.2),
                            badgeColor.opacity(0.5)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 70, height: 70)
            
            Image(systemName: "star.fill")
                .font(.system(size: 30))
                .foregroundColor(badgeColor)
        }
    }
    
    private var badgeColor: Color {
        switch level {
        case "Bronze Helper": return Color(hex: "CD7F32")
        case "Silver Helper": return Color(hex: "C0C0C0")
        case "Gold Helper": return Color(hex: "FFD700")
        default: return Color.gray
        }
    }
}

// Add Volunteer Activity View
struct AddVolunteerActivityView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var organization = ""
    @State private var hours = ""
    let onSave: (String, Int) -> Void
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Volunteer Details")) {
                    TextField("Organization Name", text: $organization)
                    
                    TextField("Hours", text: $hours)
                        .keyboardType(.numberPad)
                }
                
                Section(footer: Text("Your volunteer hours will be pending verification. Organizations can verify your hours if they use the SafeHaven app.")) {
                    Button("Log Hours") {
                        if let hoursInt = Int(hours), hoursInt > 0, !organization.isEmpty {
                            onSave(organization, hoursInt)
                            dismiss()
                        }
                    }
                    .disabled(organization.isEmpty || hours.isEmpty)
                }
            }
            .navigationTitle("Log Volunteer Hours")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// Add Donation Activity View
struct AddDonationActivityView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var organization = ""
    @State private var items = ""
    let onSave: (String, String) -> Void
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Donation Details")) {
                    TextField("Organization Name", text: $organization)
                    
                    TextField("Items Donated", text: $items)
                }
                
                Section(footer: Text("Your donation will be pending verification. Organizations can verify your donation if they use the SafeHaven app.")) {
                    Button("Log Donation") {
                        if !organization.isEmpty && !items.isEmpty {
                            onSave(organization, items)
                            dismiss()
                        }
                    }
                    .disabled(organization.isEmpty || items.isEmpty)
                }
            }
            .navigationTitle("Log Donation")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}
