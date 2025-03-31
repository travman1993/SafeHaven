//
//  JournalView.swift
//  SafeHaven
//
//  Created by Travis Rodriguez on 3/1/25.
import Foundation
import SwiftUI

// Journal Entry Model
struct JournalEntry: Identifiable, Codable {
    var id = UUID()
    var date: Date
    var title: String
    var content: String
    var mood: String
}

// Journal Manager
class JournalManager: ObservableObject {
    @Published var entries: [JournalEntry] = []
    
    init() {
        loadEntries()
    }
    
    func loadEntries() {
        if let data = UserDefaults.standard.data(forKey: "journalEntries"),
           let savedEntries = try? JSONDecoder().decode([JournalEntry].self, from: data) {
            entries = savedEntries
        }
    }
    
    func saveEntries() {
        if let encoded = try? JSONEncoder().encode(entries) {
            UserDefaults.standard.set(encoded, forKey: "journalEntries")
        }
    }
    
    func addEntry(_ title: String, _ content: String, _ mood: String) {
        let newEntry = JournalEntry(date: Date(), title: title, content: content, mood: mood)
        entries.insert(newEntry, at: 0) // Add to beginning of array
        saveEntries()
    }
    
    func deleteEntry(_ entry: JournalEntry) {
        entries.removeAll { $0.id == entry.id }
        saveEntries()
    }
}

// Existing JournalView code remains the same as in the previous responsive implementation
struct JournalView: View {
    @StateObject private var journalManager = JournalManager()
    @State private var showingNewEntryView = false
    
    // Date formatter
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
    
    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .leading, spacing: 0) {
                // Header
                HStack {
                    HStack(spacing: ResponsiveLayout.padding(12)) {
                        Image(systemName: "book.fill")
                            .font(.system(
                                size: ResponsiveLayout.fontSize(22),
                                weight: .medium
                            ))
                            .foregroundColor(Color(hex: "6A89CC"))
                        
                        Text("Journal")
                            .font(.system(
                                size: ResponsiveLayout.fontSize(20),
                                weight: .semibold,
                                design: .rounded
                            ))
                            .foregroundColor(AppTheme.adaptiveTextPrimary)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        showingNewEntryView = true
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: ResponsiveLayout.fontSize(22)))
                            .foregroundColor(Color(hex: "6A89CC"))
                    }
                }
                .padding(.horizontal, ResponsiveLayout.padding(20))
                .padding(.vertical, ResponsiveLayout.padding(16))
                .background(AppTheme.adaptiveCardBackground)
                
                Divider()
                    .padding(.horizontal, ResponsiveLayout.padding(20))
                
                // Journal Entries
                if journalManager.entries.isEmpty {
                    emptyStateView(in: geometry)
                } else {
                    entriesListView(in: geometry)
                }
            }
            .background(AppTheme.adaptiveBackground)
            .cornerRadius(ResponsiveLayout.isIPad ? 20 : 16)
            .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 4)
            .overlay(
                RoundedRectangle(cornerRadius: ResponsiveLayout.isIPad ? 20 : 16)
                    .stroke(Color(hex: "EEEEEE").opacity(0.5), lineWidth: 1)
            )
            .sheet(isPresented: $showingNewEntryView) {
                NewJournalEntryView(journalManager: journalManager)
            }
        }
    }
    
    private func emptyStateView(in geometry: GeometryProxy) -> some View {
        VStack(spacing: ResponsiveLayout.padding(12)) {
            Image(systemName: "book")
                .font(.system(size: ResponsiveLayout.fontSize(36)))
                .foregroundColor(Color(hex: "CCCCCC").opacity(0.7))
                .padding(.top, ResponsiveLayout.padding(30))
            
            Text("Your journal is empty")
                .font(.system(
                    size: ResponsiveLayout.fontSize(16),
                    weight: .medium,
                    design: .rounded
                ))
                .foregroundColor(AppTheme.adaptiveTextSecondary)
            
            Text("Start writing to track your journey")
                .font(.system(
                    size: ResponsiveLayout.fontSize(14),
                    design: .rounded
                ))
                .foregroundColor(AppTheme.adaptiveTextSecondary.opacity(0.8))
            
            Button(action: {
                showingNewEntryView = true
            }) {
                Text("Write First Entry")
                    .font(.system(
                        size: ResponsiveLayout.fontSize(16),
                        weight: .medium,
                        design: .rounded
                    ))
                    .foregroundColor(.white)
                    .padding(.horizontal, ResponsiveLayout.padding(20))
                    .padding(.vertical, ResponsiveLayout.padding(10))
                    .background(Color(hex: "6A89CC"))
                    .cornerRadius(8)
            }
            .padding(.top, ResponsiveLayout.padding(10))
            .padding(.bottom, ResponsiveLayout.padding(30))
        }
        .frame(maxWidth: .infinity)
    }
    
    private func entriesListView(in geometry: GeometryProxy) -> some View {
        ScrollView {
            LazyVStack(spacing: ResponsiveLayout.padding(12)) {
                ForEach(journalManager.entries) { entry in
                    entryRowView(entry)
                }
            }
            .padding(.vertical, ResponsiveLayout.padding(16))
        }
    }
    
    private func entryRowView(_ entry: JournalEntry) -> some View {
        VStack(alignment: .leading, spacing: ResponsiveLayout.padding(6)) {
            HStack {
                Text(entry.title)
                    .font(.system(
                        size: ResponsiveLayout.fontSize(17),
                        weight: .semibold,
                        design: .rounded
                    ))
                    .foregroundColor(AppTheme.adaptiveTextPrimary)
                
                Spacer()
                
                Text(dateFormatter.string(from: entry.date))
                    .font(.system(
                        size: ResponsiveLayout.fontSize(14),
                        design: .rounded
                    ))
                    .foregroundColor(AppTheme.adaptiveTextSecondary)
            }
            
            HStack {
                getMoodIcon(for: entry.mood)
                    .foregroundColor(getMoodColor(for: entry.mood))
                
                Text(entry.mood.capitalized)
                    .font(.system(
                        size: ResponsiveLayout.fontSize(14),
                        design: .rounded
                    ))
                    .foregroundColor(getMoodColor(for: entry.mood))
                
                Spacer()
            }
            .padding(.vertical, ResponsiveLayout.padding(4))
            
            Text(entry.content)
                .font(.system(
                    size: ResponsiveLayout.fontSize(15),
                    design: .rounded
                ))
                .foregroundColor(AppTheme.adaptiveTextSecondary)
                .lineLimit(3)
                .padding(.top, ResponsiveLayout.padding(2))
        }
        .padding(.horizontal, ResponsiveLayout.padding(16))
        .padding(.vertical, ResponsiveLayout.padding(12))
        .background(AppTheme.adaptiveCardBackground)
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 1)
        .padding(.horizontal, ResponsiveLayout.padding(20))
        .contextMenu {
            Button(role: .destructive, action: {
                withAnimation {
                    journalManager.deleteEntry(entry)
                }
            }) {
                Label("Delete", systemImage: "trash")
            }
        }
    }
    
    private func getMoodIcon(for mood: String) -> Image {
        switch mood.lowercased() {
        case "happy":
            return Image(systemName: "face.smiling")
        case "sad":
            return Image(systemName: "face.sad")
        case "anxious":
            return Image(systemName: "tornado")
        case "calm":
            return Image(systemName: "leaf")
        case "angry":
            return Image(systemName: "flame")
        default:
            return Image(systemName: "questionmark.circle")
        }
    }
    
    private func getMoodColor(for mood: String) -> Color {
        switch mood.lowercased() {
        case "happy":
            return Color(hex: "41B3A3")
        case "sad":
            return Color(hex: "6A89CC")
        case "anxious":
            return Color(hex: "F9C74F")
        case "calm":
            return Color(hex: "43AA8B")
        case "angry":
            return Color(hex: "E8505B")
        default:
            return Color(hex: "999999")
        }
    }
}

// New Journal Entry View
struct NewJournalEntryView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var journalManager: JournalManager
    
    @State private var entryTitle = ""
    @State private var entryContent = ""
    @State private var selectedMood = "calm"
    
    let moods = ["happy", "calm", "anxious", "sad", "angry"]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Entry Details")) {
                    TextField("Title", text: $entryTitle)
                        .foregroundColor(AppTheme.adaptiveTextPrimary)
                    
                    ZStack(alignment: .topLeading) {
                        if entryContent.isEmpty {
                            Text("How are you feeling today?")
                                .foregroundColor(Color(hex: "CCCCCC"))
                                .padding(.top, 8)
                                .padding(.leading, 5)
                        }
                        
                        TextEditor(text: $entryContent)
                            .frame(minHeight: 150)
                            .foregroundColor(AppTheme.adaptiveTextPrimary)
                    }
                }
                
                Section(header: Text("Mood")) {
                    Picker("How are you feeling?", selection: $selectedMood) {
                        ForEach(moods, id: \.self) { mood in
                            HStack {
                                getMoodIcon(for: mood)
                                    .foregroundColor(getMoodColor(for: mood))
                                Text(mood.capitalized)
                            }
                            .tag(mood)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }
            }
            .navigationTitle("New Journal Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        if !entryTitle.isEmpty && !entryContent.isEmpty {
                            journalManager.addEntry(entryTitle, entryContent, selectedMood)
                            dismiss()
                        }
                    }
                    .disabled(entryTitle.isEmpty || entryContent.isEmpty)
                }
            }
        }
    }
    
    // Reuse mood icon and color helper methods from JournalView
    private func getMoodIcon(for mood: String) -> Image {
        switch mood.lowercased() {
        case "happy":
            return Image(systemName: "face.smiling")
        case "sad":
            return Image(systemName: "face.sad")
        case "anxious":
            return Image(systemName: "tornado")
        case "calm":
            return Image(systemName: "leaf")
        case "angry":
            return Image(systemName: "flame")
        default:
            return Image(systemName: "questionmark.circle")
        }
    }
    
    private func getMoodColor(for mood: String) -> Color {
        switch mood.lowercased() {
        case "happy":
            return Color(hex: "41B3A3")
        case "sad":
            return Color(hex: "6A89CC")
        case "anxious":
            return Color(hex: "F9C74F")
        case "calm":
            return Color(hex: "43AA8B")
        case "angry":
            return Color(hex: "E8505B")
        default:
            return Color(hex: "999999")
        }
    }
}
