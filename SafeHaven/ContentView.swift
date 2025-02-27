import SwiftUI
import UIKit

struct ContentView: View {
    @State private var showingEmergencyCallAlert = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(
                    gradient: Gradient(colors: [Color(hex: "6A89CC"), Color(hex: "41B3A3")]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                // Content
                VStack(spacing: 30) {
                    Spacer()
                    
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
            }
            .navigationBarHidden(true)
            .alert(isPresented: $showingEmergencyCallAlert) {
                Alert(
                    title: Text("Emergency Call"),
                    message: Text("In a real app, this would call 911 and send your emergency messages"),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
