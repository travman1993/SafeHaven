//
//  JournalView.swift
//  SafeHaven
//
//  Created by Travis Rodriguez on 3/1/25.
//
import SwiftUI

struct JournalEntry: Identifiable, Codable {
    var id = UUID()
    var date: Date
    var title: String
    var content: String
    var mood: String
}

class JournalManager: ObservableObject {
    @Published var entries: [JournalEntry] = []
    
    init() {
        // In a real app, you would load from UserDefaults or a database
        // This is just sample data
        let sampleEntries = [
            JournalEntry(
                date: Date().addingTimeInterval(-86400), // Yesterday
                title: "Finding Peace",
                content: "Today was challenging but I practiced my breathing exercises and felt calmer.",
                mood: "calm"
            ),
            JournalEntry(
                date: Date().addingTimeInterval(-172800), // 2 days ago
                title: "Small Victories",
                content: "Made progress on my goals today. Taking one step at a time.",
                mood: "happy"
            )
        ]
        entries = sampleEntries
    }
    
    func addEntry(_ title: String, _ content: String, _ mood: String) {
        let newEntry = JournalEntry(date: Date(), title: title, content: content, mood: mood)
        entries.insert(newEntry, at: 0) // Add to beginning of array
        
        // In a real app, you would save to storage here
    }
    
    func deleteEntry(_ entry: JournalEntry) {
        if let index = entries.firstIndex(where: { $0.id == entry.id }) {
            entries.remove(at: index)
            // In a real app, you would update storage here
        }
    }
}

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
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack {
                HStack(spacing: 12) {
                    Image(systemName: "book.fill")
                        .font(.system(size: 22, weight: .medium))
                        .foregroundColor(Color(hex: "6A89CC"))
                    
                    Text("Journal")
                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                        .foregroundColor(Color(hex: "333333"))
                }
                
                Spacer()
                
                Button(action: {
                    showingNewEntryView = true
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 22))
                        .foregroundColor(Color(hex: "6A89CC"))
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(Color(hex: "F8F9FA"))
            
            Divider()
                .padding(.horizontal, 20)
            
            // Journal Entries
            if journalManager.entries.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "book")
                        .font(.system(size: 36))
                        .foregroundColor(Color(hex: "CCCCCC"))
                        .padding(.top, 30)
                    
                    Text("Your journal is empty")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(Color(hex: "999999"))
                    
                    Text("Start writing to track your journey")
                        .font(.system(size: 14, design: .rounded))
                        .foregroundColor(Color(hex: "AAAAAA"))
                    
                    Button(action: {
                        showingNewEntryView = true
                    }) {
                        Text("Write First Entry")
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(Color(hex: "6A89CC"))
                            .cornerRadius(8)
                    }
                    .padding(.top, 10)
                    .padding(.bottom, 30)
                }
                .frame(maxWidth: .infinity)
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(journalManager.entries) { entry in
                            VStack(alignment: .leading, spacing: 6) {
                                HStack {
                                    Text(entry.title)
                                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                                        .foregroundColor(Color(hex: "333333"))
                                    
                                    Spacer()
                                    
                                    Text(dateFormatter.string(from: entry.date))
                                        .font(.system(size: 14, design: .rounded))
                                        .foregroundColor(Color(hex: "999999"))
                                }
                                
                                HStack {
                                    getMoodIcon(for: entry.mood)
                                        .foregroundColor(getMoodColor(for: entry.mood))
                                    
                                    Text(entry.mood.capitalized)
                                        .font(.system(size: 14, design: .rounded))
                                        .foregroundColor(getMoodColor(for: entry.mood))
                                    
                                    Spacer()
                                }
                                .padding(.vertical, 4)
                                
                                Text(entry.content)
                                    .font(.system(size: 15, design: .rounded))
                                    .foregroundColor(Color(hex: "555555"))
                                    .lineLimit(3)
                                    .padding(.top, 2)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(Color.white)
                            .cornerRadius(10)
                            .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 1)
                            .padding(.horizontal, 20)
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
                    }
                    .padding(.vertical, 16)
                }
            }
        }
        .background(Color(hex: "F9FAFB"))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 4)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(hex: "EEEEEE"), lineWidth: 1)
        )
        .sheet(isPresented: $showingNewEntryView) {
            NewJournalEntryView(journalManager: journalManager)
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
                    
                    ZStack(alignment: .topLeading) {
                        if entryContent.isEmpty {
                            Text("How are you feeling today?")
                                .foregroundColor(Color(hex: "CCCCCC"))
                                .padding(.top, 8)
                                .padding(.leading, 5)
                        }
                        
                        TextEditor(text: $entryContent)
                            .frame(minHeight: 150)
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
