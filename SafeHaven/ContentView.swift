import SwiftUI
import UIKit

struct ContentView: View {
    @State private var showingEmergencyCallAlert = false
    @State private var showingTodoView = false
    @State private var showingJournalView = false
    @State private var showingPaywallView = false
    @StateObject private var todoManager = TodoManager()
    @StateObject private var subscriptionManager = SubscriptionManager.shared
    
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
                    VStack(spacing: 20) {
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
                            .padding(.top, 30)
                        
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
                            .padding(.bottom, 10)
                        
                        // Emergency slider (Premium feature)
                        if subscriptionManager.isSubscribed {
                            EmergencySlider(onEmergencyCall: {
                                // In a real app, this would initiate a call to emergency services
                                showingEmergencyCallAlert = true
                            })
                            .padding(.horizontal, 20)
                            .padding(.bottom, 10)
                        } else {
                            // Locked emergency slider
                            Button(action: {
                                showingPaywallView = true
                            }) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 30)
                                        .fill(Color.black.opacity(0.15))
                                        .frame(height: 60)
                                    
                                    HStack {
                                        Image(systemName: "lock.fill")
                                            .font(.system(size: 20))
                                            .foregroundColor(.white)
                                            .padding(.leading, 20)
                                        
                                        Text("Unlock Emergency Call Feature")
                                            .font(.system(size: 18, weight: .medium, design: .rounded))
                                            .foregroundColor(.white)
                                        
                                        Spacer()
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.bottom, 10)
                        }

                        // Navigation buttons
                        VStack(spacing: 18) {
                            // Daily Motivation Button (Now Premium)
                            Button(action: {
                                if subscriptionManager.isSubscribed {
                                    // Navigate to Motivation View
                                    // Replace with proper NavigationLink in the full implementation
                                } else {
                                    showingPaywallView = true
                                }
                            }) {
                                HStack {
                                    Image(systemName: "quote.bubble.fill")
                                        .font(.system(size: 22))
                                        .foregroundColor(.white)
                                        .frame(width: 30)
                                    
                                    Text("Daily Motivation")
                                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                                    
                                    Spacer()
                                    
                                    // Lock icon if not subscribed
                                    if !subscriptionManager.isSubscribed {
                                        Image(systemName: "lock.fill")
                                            .font(.system(size: 16))
                                            .foregroundColor(.white)
                                            .frame(width: 24, height: 24)
                                            .background(Color(hex: "E8505B"))
                                            .clipShape(Circle())
                                            .padding(.trailing, 5)
                                    }
                                    
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

                            // Find Resources Button (Free)
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
                            
                            // Support Our Mission Button (Free)
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
                            
                            // Upgrade to Premium Button (only shows if not subscribed)
                            if !subscriptionManager.isSubscribed {
                                Button(action: {
                                    showingPaywallView = true
                                }) {
                                    HStack {
                                        Image(systemName: "star.fill")
                                            .font(.system(size: 22))
                                            .foregroundColor(.white)
                                            .frame(width: 30)
                                        
                                        Text("Upgrade to Premium")
                                            .font(.system(size: 20, weight: .semibold, design: .rounded))
                                        
                                        Spacer()
                                        
                                        Image(systemName: "chevron.right")
                                            .foregroundColor(.white.opacity(0.7))
                                    }
                                    .padding(.vertical, 20)
                                    .padding(.horizontal, 25)
                                    .background(
                                        RoundedRectangle(cornerRadius: 16)
                                            .fill(Color(hex: "F6AD55").opacity(0.9))
                                    )
                                    .foregroundColor(.white)
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        
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
                            // JOURNAL BUTTON - Left side (Premium feature)
                            Button(action: {
                                if subscriptionManager.isSubscribed {
                                    withAnimation {
                                        showingJournalView.toggle()
                                    }
                                } else {
                                    showingPaywallView = true
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
                                    
                                    // Lock icon if not subscribed
                                    if !subscriptionManager.isSubscribed {
                                        Image(systemName: "lock.fill")
                                            .font(.system(size: 10, weight: .bold))
                                            .foregroundColor(.white)
                                            .frame(width: 16, height: 16)
                                            .background(Color(hex: "E8505B"))
                                            .clipShape(Circle())
                                            .offset(x: 3, y: -3)
                                    }
                                }
                            }
                            .padding(.top, geometry.safeAreaInsets.top + 15)
                            .padding(.leading, 25)
                            
                            Spacer()
                            
                            // Todo Button - Right side (Premium feature)
                            Button(action: {
                                if subscriptionManager.isSubscribed {
                                    withAnimation {
                                        showingTodoView.toggle()
                                    }
                                } else {
                                    showingPaywallView = true
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
                                    
                                    // Lock icon if not subscribed
                                    if !subscriptionManager.isSubscribed {
                                        Image(systemName: "lock.fill")
                                            .font(.system(size: 10, weight: .bold))
                                            .foregroundColor(.white)
                                            .frame(width: 16, height: 16)
                                            .background(Color(hex: "E8505B"))
                                            .clipShape(Circle())
                                            .offset(x: 3, y: -3)
                                    }
                                    // Notification dot for incomplete todos
                                    else if !todoManager.items.filter({ !$0.isCompleted }).isEmpty {
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
            .sheet(isPresented: $showingPaywallView) {
                PaywallView()
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        // Debug toolbar to toggle subscription status - REMOVE THIS FOR PRODUCTION
        .toolbar {
            ToolbarItemGroup(placement: .bottomBar) {
                #if DEBUG
                Button("Toggle Premium") {
                    subscriptionManager.debugSetSubscribed(!subscriptionManager.isSubscribed)
                }
                #endif
                
                Spacer()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
