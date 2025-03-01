import SwiftUI
import UIKit

struct ContentView: View {
    @State private var showingEmergencyCallAlert = false
    @State private var showingTodoView = false
    @State private var showingJournalView = false
    @StateObject private var todoManager = TodoManager()
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                ZStack(alignment: .top) {
                    // Background gradient
                    LinearGradient(
                        gradient: Gradient(colors: [Color(hex: "6A89CC"), Color(hex: "41B3A3")]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .ignoresSafeArea()
                    
                    // Main content
                    VStack(spacing: 30) {
                        // App logo/icon
                        Circle()
                            .fill(Color.white.opacity(0.9))
                            .frame(width: 120, height: 120)
                            .overlay(
                                Image(systemName: "house.fill")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .padding(30)
                                    .foregroundColor(Color(hex: "6A89CC"))
                            )
                            .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
                            .padding(.top, 40)
                        
                        // App name
                        Text("Safe Haven")
                            .font(.system(size: 42, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                        
                        // App tagline
                        Text("Find safety and support when you need it most")
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundColor(.white.opacity(0.9))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                            .padding(.bottom, 20)
                        
                        Spacer()
                        
                        // Emergency slider
                        EmergencySlider(onEmergencyCall: {
                            // In a real app, this would initiate a call to emergency services
                            showingEmergencyCallAlert = true
                        })
                        .padding(.horizontal, 20)
                        .padding(.bottom, 10)

                        // Navigation buttons
                        VStack(spacing: 18) {
                            // Daily Motivation Button
                            NavigationLink(destination: MotivationView()) {
                                HStack {
                                    Image(systemName: "quote.bubble.fill")
                                        .font(.system(size: 22))
                                        .foregroundColor(.white)
                                        .frame(width: 30)
                                    
                                    Text("Daily Motivation")
                                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.white.opacity(0.7))
                                }
                                .padding(.vertical, 20)
                                .padding(.horizontal, 25)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color(hex: "41B3A3").opacity(0.9))
                                )
                                .foregroundColor(.white)
                            }

                            // Find Resources Button
                            NavigationLink(destination: ResourcesView()) {
                                HStack {
                                    Image(systemName: "mappin.and.ellipse")
                                        .font(.system(size: 22))
                                        .foregroundColor(.white)
                                        .frame(width: 30)
                                    
                                    Text("Find Resources")
                                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.white.opacity(0.7))
                                }
                                .padding(.vertical, 20)
                                .padding(.horizontal, 25)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color(hex: "4A69BB").opacity(0.9))
                                )
                                .foregroundColor(.white)
                            }
                            
                            // Support Our Mission Button
                            NavigationLink(destination: DonateView()) {
                                HStack {
                                    Image(systemName: "heart.fill")
                                        .font(.system(size: 22))
                                        .foregroundColor(.white)
                                        .frame(width: 30)
                                    
                                    Text("Support Our Mission")
                                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.white.opacity(0.7))
                                }
                                .padding(.vertical, 20)
                                .padding(.horizontal, 25)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color(hex: "E8505B").opacity(0.9))
                                )
                                .foregroundColor(.white)
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        Spacer()
                        
                        // Version info
                        Text("Version 1.0")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white.opacity(0.6))
                            .padding(.bottom, 10)
                    }
                    .padding()
                    
                    // Top action buttons - positioned on top in ZStack
                    VStack {
                        HStack {
                            // JOURNAL BUTTON - Left side
                            Button(action: {
                                withAnimation {
                                    showingJournalView.toggle()
                                }
                            }) {
                                ZStack(alignment: .topTrailing) {
                                    Image(systemName: "book.fill")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 25, height: 25)
                                        .foregroundColor(.white)
                                        .padding(12)
                                        .background(Color.white.opacity(0.2))
                                        .clipShape(Circle())
                                }
                            }
                            .padding(.top, geometry.safeAreaInsets.top + 15)
                            .padding(.leading, 25)
                            
                            Spacer()
                            
                            // Todo Button - Right side
                            Button(action: {
                                withAnimation {
                                    showingTodoView.toggle()
                                }
                            }) {
                                ZStack(alignment: .topTrailing) {
                                    Image(systemName: "checklist")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 25, height: 25)
                                        .foregroundColor(.white)
                                        .padding(12)
                                        .background(Color.white.opacity(0.2))
                                        .clipShape(Circle())
                                    
                                    // Notification dot for incomplete todos
                                    if !todoManager.items.filter({ !$0.isCompleted }).isEmpty {
                                        Circle()
                                            .fill(Color.red)
                                            .frame(width: 10, height: 10)
                                            .offset(x: 3, y: -3)
                                    }
                                }
                            }
                            .padding(.top, geometry.safeAreaInsets.top + 15)
                            .padding(.trailing, 25)
                        }
                        
                        Spacer()
                    }
                }
                .navigationBarHidden(true)
            }
            .alert(isPresented: $showingEmergencyCallAlert) {
                Alert(
                    title: Text("Emergency Call"),
                    message: Text("In a real app, this would call 911 and send your emergency messages"),
                    dismissButton: .default(Text("OK"))
                )
            }
            .sheet(isPresented: $showingTodoView) {
                TodoView()
                    .presentationDetents([.medium, .large])
            }
            .sheet(isPresented: $showingJournalView) {
                JournalView()
                    .presentationDetents([.medium, .large])
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

// EmergencySlider component
struct EmergencySlider: View {
    var onEmergencyCall: () -> Void
    @State private var sliderValue: CGFloat = 0
    
    var body: some View {
        ZStack(alignment: .leading) {
            // Background track
            RoundedRectangle(cornerRadius: 30)
                .fill(Color.black.opacity(0.15))
                .frame(height: 60)
            
            // Slide to call text
            HStack {
                Image(systemName: "phone.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.white)
                    .padding(.leading, 20)
                
                Text("Slide to Call for Help")
                    .font(.system(size: 18, weight: .medium, design: .rounded))
                    .foregroundColor(.white)
                
                Spacer()
            }
            .padding(.leading, sliderValue > 0 ? sliderValue : 0)
            
            // Slider thumb
            Circle()
                .fill(Color(hex: "FF5A5F"))
                .frame(width: 50, height: 50)
                .overlay(
                    Image(systemName: "phone.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.white)
                )
                .offset(x: sliderValue)
                .shadow(color: Color.black.opacity(0.15), radius: 4, x: 0, y: 2)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            // Calculate slider position
                            let maxSlide = UIScreen.main.bounds.width - 100
                            let newValue = min(max(0, value.translation.width), maxSlide)
                            sliderValue = newValue
                            
                            // Trigger call if slid to the end
                            if newValue >= maxSlide {
                                onEmergencyCall()
                                // Reset after delay
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    withAnimation {
                                        sliderValue = 0
                                    }
                                }
                            }
                        }
                        .onEnded { _ in
                            // Reset if not slid to the end
                            withAnimation {
                                sliderValue = 0
                            }
                        }
                )
                .padding(.leading, 5)
        }
    }
}

// Extension for hex colors
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

// These are placeholders for the views that would be in separate files
struct MotivationView: View {
    var body: some View {
        Text("Motivation View")
    }
}

struct ResourcesView: View {
    var body: some View {
        Text("Resources View")
    }
}

struct DonateView: View {
    var body: some View {
        Text("Donate View")
    }
}

// Todo Manager class needed for TodoView
class TodoManager: ObservableObject {
    @Published var items: [TodoItem] = []
    
    func addTodo(_ title: String) {
        let newItem = TodoItem(title: title)
        items.append(newItem)
    }
    
    func toggleTodo(_ item: TodoItem) {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            items[index].isCompleted.toggle()
        }
    }
    
    func removeTodo(_ item: TodoItem) {
        items.removeAll { $0.id == item.id }
    }
}

// Todo Item model needed for TodoView
struct TodoItem: Identifiable {
    var id = UUID()
    var title: String
    var isCompleted = false
}
