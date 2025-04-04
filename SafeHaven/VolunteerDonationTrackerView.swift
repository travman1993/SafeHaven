//
//  VolunteerDonationTrackerView.swift
//  SafeHaven
//
//  Created by Travis Rodriguez on 4/3/25.
//
import SwiftUI

// Models for Volunteer and Donation Activities
struct VolunteerActivity: Identifiable, Codable {
    let id: UUID
    let organization: String
    let hours: Int
    let date: Date
    var verified: Bool = false
}

struct DonationActivity: Identifiable, Codable {
    let id: UUID
    let organization: String
    let items: String
    let date: Date
    var verified: Bool = false
    var category: DonationType
    var value: Double  // Dollar amount or equivalent point value
}

// Donation Type Enum
enum DonationType: String, CaseIterable, Codable {
    case money = "Financial Donation"
    case food = "Food Donation"
    case clothing = "Clothing Donation"
    case supplies = "Supplies Donation"
    case other = "Other Donation"
    
    // Points multiplier for each type
    var pointsMultiplier: Double {
        switch self {
        case .money: return 1.0    // 1 point per dollar
        case .food: return 5.0     // 5 points per food donation
        case .clothing: return 3.0  // 3 points per clothing donation
        case .supplies: return 4.0  // 4 points per supplies donation
        case .other: return 2.0     // 2 points per other donation
        }
    }
}

// Contributor Level Enum
enum ContributorLevel: String, CaseIterable, Codable {
    case tin = "Tin – Just starting out"
    case copper = "Copper – Gaining experience"
    case bronze = "Bronze – Reliable contributor"
    case iron = "Iron – Building strength"
    case steel = "Steel – Committed helper"
    case silver = "Silver – Making an impact"
    case gold = "Gold – Dedicated volunteer"
    case platinum = "Platinum – Going above and beyond"
    case titanium = "Titanium – Strong leader"
    case diamond = "Diamond – A shining example"
    case obsidian = "Obsidian – Rare and valuable"
    case mithril = "Mithril – Legendary dedication"
    case adamantium = "Adamantium – Unbreakable commitment"
    case orichalcum = "Orichalcum – A mythical force"
    case legendaryAlloy = "Legendary Alloy – The ultimate level"
    
    var symbol: String {
        switch self {
        case .tin: return "🛠️" // Craftsman's tools, representing early skills and potential
        case .copper: return "🟤" // Copper-colored circle
        case .bronze: return "🥉" // Bronze medal
        case .iron: return "⚙️" // Gear representing industrial strength
        case .steel: return "🔪" // Stainless steel blade
        case .silver: return "🥈" // Silver medal
        case .gold: return "🥇" // Gold medal
        case .platinum: return "🌐" // Globe, representing worldwide impact and rarity
        case .titanium: return "🚀" // Titanium used in aerospace
        case .diamond: return "💎" // Diamond (crystalline structure)
        case .obsidian: return "🌑" // Black as obsidian
        case .mithril: return "🗡️" // Mythical lightweight metal weapon
        case .adamantium: return "🛡️" // Legendary unbreakable shield
        case .orichalcum: return "🔱" // Trident, mythical metal associated with Poseidon
        case .legendaryAlloy: return "🏆" // Trophy, representing ultimate achievement
        }
    }
    
    // Minimum hours to reach each level
    var minimumPoints: Int {
        switch self {
        case .tin: return 0
        case .copper: return 10
        case .bronze: return 25
        case .iron: return 50
        case .steel: return 100
        case .silver: return 250
        case .gold: return 500
        case .platinum: return 1000
        case .titanium: return 2000
        case .diamond: return 3500
        case .obsidian: return 5000
        case .mithril: return 7500
        case .adamantium: return 10000
        case .orichalcum: return 15000
        case .legendaryAlloy: return 20000
        }
    }
    
    // Color representation for each level
    var color: Color {
        switch self {
        case .tin: return Color(hex: "A0A0A0")
        case .copper: return Color(hex: "B87333")
        case .bronze: return Color(hex: "CD7F32")
        case .iron: return Color(hex: "5D4037")
        case .steel: return Color(hex: "607D8B")
        case .silver: return Color(hex: "C0C0C0")
        case .gold: return Color(hex: "FFD700")
        case .platinum: return Color(hex: "E5E4E2")
        case .titanium: return Color(hex: "67CBCE")
        case .diamond: return Color(hex: "B9F2FF")
        case .obsidian: return Color(hex: "000000")
        case .mithril: return Color(hex: "C0C0C0")
        case .adamantium: return Color(hex: "3D3D3D")
        case .orichalcum: return Color(hex: "4CAF50")
        case .legendaryAlloy: return Color(hex: "FF5722")
        }
    }
}

// Activity Tracker View Model - UPDATED
class ActivityTrackerViewModel: ObservableObject {
    @Published var volunteerActivities: [VolunteerActivity] = []
    @Published var donationActivities: [DonationActivity] = []
    @Published var totalVolunteerHours: Int = 0
    @Published var totalDonationPoints: Double = 0
    @Published var totalCombinedPoints: Int = 0
    @Published var currentLevel: ContributorLevel = .tin
    @Published var progressToNextLevel: CGFloat = 0.0
    
    init() {
        loadActivities()
    }
    
    func deleteVolunteerActivity(at indexSet: IndexSet) {
        // First, subtract the hours from the total
        for index in indexSet {
            if index < volunteerActivities.count {
                totalVolunteerHours -= volunteerActivities[index].hours
            }
        }
        
        // Then remove the activities
        volunteerActivities.remove(atOffsets: indexSet)
        
        // Update total points and level
        updateTotalPoints()
        calculateCurrentLevel()
        saveActivities()
    }

    func deleteDonationActivity(at indexSet: IndexSet) {
        // Remove the activities (the points will be recalculated in updateTotalPoints)
        donationActivities.remove(atOffsets: indexSet)
        
        // Update total points and level
        updateTotalPoints()
        calculateCurrentLevel()
        saveActivities()
    }
    
    func addVolunteerActivity(organization: String, hours: Int) {
        let newActivity = VolunteerActivity(
            id: UUID(),
            organization: organization,
            hours: hours,
            date: Date()
        )
        volunteerActivities.insert(newActivity, at: 0)
        totalVolunteerHours += hours
        updateTotalPoints()
        calculateCurrentLevel()
        saveActivities()
    }
    
    func addDonationActivity(organization: String, items: String, category: DonationType, value: Double) {
        let newActivity = DonationActivity(
            id: UUID(),
            organization: organization,
            items: items,
            date: Date(),
            verified: false,
            category: category,
            value: value
        )
        donationActivities.insert(newActivity, at: 0)
        updateTotalPoints()
        calculateCurrentLevel()
        saveActivities()
    }
    
    private func updateTotalPoints() {
        // Each volunteer hour counts as one point
        let volunteerPoints = totalVolunteerHours
        
        // Calculate donation points based on category and value
        totalDonationPoints = donationActivities.reduce(0.0) { total, donation in
            total + (donation.value * donation.category.pointsMultiplier)
        }
        
        // Combined total (rounded to int)
        totalCombinedPoints = volunteerPoints + Int(totalDonationPoints)
    }
    
    private func calculateCurrentLevel() {
        let sortedLevels = ContributorLevel.allCases.sorted { $0.minimumPoints < $1.minimumPoints }
        
        for (index, level) in sortedLevels.enumerated() {
            if totalCombinedPoints < level.minimumPoints {
                currentLevel = index > 0 ? sortedLevels[index - 1] : .tin
                
                // Calculate progress to next level
                let currentLevelPoints = currentLevel.minimumPoints
                let nextLevelPoints = level.minimumPoints
                
                progressToNextLevel = CGFloat(totalCombinedPoints - currentLevelPoints) /
                                       CGFloat(nextLevelPoints - currentLevelPoints)
                
                return
            }
        }
        
        // If points exceed all defined levels
        currentLevel = .legendaryAlloy
        progressToNextLevel = 1.0
    }
    
    private func saveActivities() {
        // Save to UserDefaults or other persistent storage
        let encoder = JSONEncoder()
        if let volunteerData = try? encoder.encode(volunteerActivities),
           let donationData = try? encoder.encode(donationActivities) {
            UserDefaults.standard.set(volunteerData, forKey: "volunteerActivities")
            UserDefaults.standard.set(donationData, forKey: "donationActivities")
        }
    }
    
    private func loadActivities() {
        // Load from UserDefaults or other persistent storage
        let decoder = JSONDecoder()
        if let volunteerData = UserDefaults.standard.data(forKey: "volunteerActivities"),
           let donationData = UserDefaults.standard.data(forKey: "donationActivities") {
            volunteerActivities = (try? decoder.decode([VolunteerActivity].self, from: volunteerData)) ?? []
            donationActivities = (try? decoder.decode([DonationActivity].self, from: donationData)) ?? []
            
            // Recalculate total hours
            totalVolunteerHours = volunteerActivities.reduce(0) { $0 + $1.hours }
            
            // Update points and level
            updateTotalPoints()
            calculateCurrentLevel()
        }
    }
}

// Main Tracker View
struct VolunteerDonationTrackerView: View {
    @StateObject private var viewModel = ActivityTrackerViewModel()
    @State private var showingVolunteerSheet = false
    @State private var showingDonationSheet = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Level Progress Card
                    levelProgressCard
                    
                    // Activity Sections
                    volunteerActivitySection
                    donationActivitySection
                }
                .padding()
            }
            .navigationTitle("Activity Tracker")
            .navigationBarItems(
                leading: EditButton(), // Add edit button
                trailing: HStack {
                    Button(action: { showingDonationSheet = true }) {
                        Label("Log Donation", systemImage: "gift")
                    }
                    .padding(.trailing, 8)
                    
                    Button(action: { showingVolunteerSheet = true }) {
                        Label("Log Hours", systemImage: "clock")
                    }
                }
            )
            .sheet(isPresented: $showingVolunteerSheet) {
                AddVolunteerActivityView(viewModel: viewModel)
            }
            .sheet(isPresented: $showingDonationSheet) {
                AddDonationActivityView(viewModel: viewModel)
            }
        }
    }
    
    private var levelProgressCard: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                VStack(alignment: .leading) {
                    Text(viewModel.currentLevel.rawValue)
                        .font(.headline)
                    
                    HStack {
                        Text("Total Points: \(viewModel.totalCombinedPoints)")
                            .font(.subheadline)
                        
                        Spacer()
                        
                        Text("Volunteer: \(viewModel.totalVolunteerHours) • Donations: \(Int(viewModel.totalDonationPoints))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                // Level badge with symbolic representation
                ZStack {
                    Circle()
                        .fill(viewModel.currentLevel.color)
                        .frame(width: 60, height: 60)
                    
                    Text(viewModel.currentLevel.symbol)
                        .font(.system(size: 30))
                }
            }
            
            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 10)
                        .cornerRadius(5)
                    
                    Rectangle()
                        .fill(viewModel.currentLevel.color)
                        .frame(width: geometry.size.width * viewModel.progressToNextLevel, height: 10)
                        .cornerRadius(5)
                }
            }
            .frame(height: 10)
            
            // Next level information
            let nextLevel = nextLevelForCurrentProgress()
            HStack {
                Text("Next Level: \(nextLevel.rawValue)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("Points needed: \(nextLevel.minimumPoints - viewModel.totalCombinedPoints)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .shadow(color: .gray.opacity(0.2), radius: 5, x: 0, y: 2)
        )
    }
    
    private var volunteerActivitySection: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Volunteer Hours")
                    .font(.headline)
                Spacer()
                Button("Log Hours") {
                    showingVolunteerSheet = true
                }
            }
            
            if viewModel.volunteerActivities.isEmpty {
                Text("No volunteer hours logged")
                    .foregroundColor(.secondary)
                    .padding()
            } else {
                List {
                    ForEach(viewModel.volunteerActivities) { activity in
                        volunteerActivityRow(activity)
                    }
                    .onDelete { indexSet in
                        viewModel.deleteVolunteerActivity(at: indexSet)
                    }
                }
                .frame(height: min(CGFloat(viewModel.volunteerActivities.count) * 70, 210))
                .listStyle(PlainListStyle())
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .shadow(color: .gray.opacity(0.1), radius: 3, x: 0, y: 1)
        )
    }

    // Replace the donationActivitySection with:
    private var donationActivitySection: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Donations")
                    .font(.headline)
                Spacer()
                Button("Log Donation") {
                    showingDonationSheet = true
                }
            }
            
            if viewModel.donationActivities.isEmpty {
                Text("No donations logged")
                    .foregroundColor(.secondary)
                    .padding()
            } else {
                List {
                    ForEach(viewModel.donationActivities) { activity in
                        donationActivityRow(activity)
                    }
                    .onDelete { indexSet in
                        viewModel.deleteDonationActivity(at: indexSet)
                    }
                }
                .frame(height: min(CGFloat(viewModel.donationActivities.count) * 70, 210))
                .listStyle(PlainListStyle())
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .shadow(color: .gray.opacity(0.1), radius: 3, x: 0, y: 1)
        )
    }
    
    private func volunteerActivityRow(_ activity: VolunteerActivity) -> some View {
        HStack {
            VStack(alignment: .leading) {
                Text(activity.organization)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text("\(activity.hours) hours")
                    .font(.caption)
            }
            
            Spacer()
            
            Text(activity.date, style: .date)
                .font(.caption)
                .foregroundColor(.secondary)
            
            if activity.verified {
                Image(systemName: "checkmark.seal.fill")
                    .foregroundColor(.green)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(8)
    }
    
    private func donationActivityRow(_ activity: DonationActivity) -> some View {
        HStack {
            VStack(alignment: .leading) {
                Text(activity.organization)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                HStack {
                    Text(activity.category.rawValue)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(4)
                    
                    if activity.category == .money {
                        Text("$\(String(format: "%.2f", activity.value))")
                            .font(.caption)
                            .foregroundColor(.green)
                    } else {
                        Text(activity.items)
                            .font(.caption)
                    }
                }
            }
            
            Spacer()
            
            Text(activity.date, style: .date)
                .font(.caption)
                .foregroundColor(.secondary)
            
            if activity.verified {
                Image(systemName: "checkmark.seal.fill")
                    .foregroundColor(.green)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(8)
    }
    
    private func nextLevelForCurrentProgress() -> ContributorLevel {
        let sortedLevels = ContributorLevel.allCases.sorted { $0.minimumPoints < $1.minimumPoints }
        
        for level in sortedLevels {
            if viewModel.totalCombinedPoints < level.minimumPoints {
                return level
            }
        }
        
        return .legendaryAlloy
    }
}

// Add Volunteer Activity Sheet
struct AddVolunteerActivityView: View {
    @ObservedObject var viewModel: ActivityTrackerViewModel
    @Environment(\.presentationMode) var presentationMode
    
    @State private var organization = ""
    @State private var hours = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Activity Details")) {
                    TextField("Organization", text: $organization)
                    TextField("Hours", text: $hours)
                        .keyboardType(.numberPad)
                }
                
                Section(footer: Text("Every volunteer hour counts as 1 contribution point toward your contributor level.")) {
                    Button("Log Hours") {
                        if let hoursInt = Int(hours), !organization.isEmpty {
                            viewModel.addVolunteerActivity(organization: organization, hours: hoursInt)
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                    .disabled(organization.isEmpty || hours.isEmpty)
                }
            }
            .navigationTitle("Log Volunteer Hours")
            .navigationBarItems(
                leading: Button("Cancel") { presentationMode.wrappedValue.dismiss() }
            )
        }
    }
}

// Add Donation Activity Sheet - UPDATED
struct AddDonationActivityView: View {
    @ObservedObject var viewModel: ActivityTrackerViewModel
    @Environment(\.presentationMode) var presentationMode
    
    @State private var organization = ""
    @State private var items = ""
    @State private var donationType: DonationType = .other
    @State private var value = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Donation Details")) {
                    TextField("Organization", text: $organization)
                    
                    Picker("Donation Type", selection: $donationType) {
                        ForEach(DonationType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    
                    if donationType == .money {
                        TextField("Amount ($)", text: $value)
                            .keyboardType(.decimalPad)
                    } else {
                        TextField("Items Description", text: $items)
                        TextField("Estimated Value ($)", text: $value)
                            .keyboardType(.decimalPad)
                    }
                }
                
                Section(footer: Text("Donation points are calculated based on type and value. Financial donations earn 1 point per dollar. Other donations earn points based on type and value.")) {
                    Button("Log Donation") {
                        if let valueDouble = Double(value), !organization.isEmpty {
                            if donationType == .money {
                                viewModel.addDonationActivity(
                                    organization: organization,
                                    items: "Financial contribution",
                                    category: donationType,
                                    value: valueDouble
                                )
                            } else if !items.isEmpty {
                                viewModel.addDonationActivity(
                                    organization: organization,
                                    items: items,
                                    category: donationType,
                                    value: valueDouble
                                )
                            }
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                    .disabled(organization.isEmpty || value.isEmpty || (donationType != .money && items.isEmpty))
                }
            }
            .navigationTitle("Log Donation")
            .navigationBarItems(
                leading: Button("Cancel") { presentationMode.wrappedValue.dismiss() }
            )
        }
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
                    
                    Text("Community Impact Tracker")
                        .font(.system(size: ResponsiveLayout.fontSize(18), weight: .semibold))
                        .foregroundColor(AppTheme.adaptiveTextPrimary)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .foregroundColor(AppTheme.adaptiveTextSecondary)
                }
                
                Text("Track your volunteer hours and donations")
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
