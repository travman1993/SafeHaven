import SwiftUI
import CoreLocation

struct OnboardingView: View {
    @Binding var hasCompletedOnboarding: Bool
    @State private var currentPage = 0
    @State private var locationEnabled = false
    var onComplete: () -> Void
    
    // Enhanced pages with more detailed content
    let pages = [
        OnboardingPage(
            title: "Welcome to SafeHaven",
            subtitle: "Your lifeline in times of need",
            image: "hand.raised.fill",
            description: "SafeHaven helps you quickly find resources, emergency assistance, and support services when you need them most."
        ),
        OnboardingPage(
            title: "Emergency SOS",
            subtitle: "Help is just a slide away",
            image: "exclamationmark.shield.fill",
            description: "Our emergency slider lets you quickly call 911 and automatically sends your location to your trusted emergency contacts."
        ),
        OnboardingPage(
            title: "Find Resources",
            subtitle: "Connect with local support services",
            image: "mappin.and.ellipse",
            description: "Locate nearby shelters, food banks, healthcare providers, mental health services, and many other essential resources."
        ),
        OnboardingPage(
            title: "Location Services",
            subtitle: "Privacy & safety under your control",
            image: "location.fill",
            description: "When enabled, we'll only access your location when looking for nearby resources. Location services are optional, and you can select cities manually. Your location data is never stored or shared without your permission."
        ),
        OnboardingPage(
            title: "Ready to Get Started?",
            subtitle: "Everything is completely free!",
            image: "checkmark.shield.fill",
            description: "All features are available with no subscription required. Your data stays on your device for maximum privacy."
        )
    ]
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background gradient
                LinearGradient(
                    gradient: Gradient(colors: [Color(hex: "F8F9FA"), Color(hex: "E9ECEF")]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Progress bar
                    HStack(spacing: ResponsiveLayout.padding(4)) {
                        ForEach(0..<pages.count, id: \.self) { index in
                            Capsule()
                                .fill(currentPage >= index ? AppTheme.primary : Color.gray.opacity(0.3))
                                .frame(height: ResponsiveLayout.isIPad ? 6 : 4)
                                .animation(.spring(), value: currentPage)
                        }
                    }
                    .padding(.horizontal, ResponsiveLayout.isIPad ? 80 : 40)
                    .padding(.top, ResponsiveLayout.padding(20))
                    
                    // Page content
                    TabView(selection: $currentPage) {
                        ForEach(0..<pages.count, id: \.self) { index in
                            pageContentView(for: pages[index], at: index, in: geometry)
                                .tag(index)
                        }
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    
                    // Navigation buttons (Always show to enable skipping location permission)
                    HStack {
                        // Back button
                        if currentPage > 0 {
                            Button(action: {
                                withAnimation {
                                    currentPage -= 1
                                }
                            }) {
                                HStack(spacing: ResponsiveLayout.padding(4)) {
                                    Image(systemName: "chevron.left")
                                    Text("Back")
                                }
                                .foregroundColor(AppTheme.primary)
                                .padding()
                            }
                        } else {
                            Spacer()
                                .frame(width: ResponsiveLayout.isIPad ? 120 : 80)
                        }
                        
                        Spacer()
                        
                        // Next/Get Started button
                        if currentPage < pages.count - 1 {
                            Button(action: {
                                withAnimation {
                                    currentPage += 1
                                }
                            }) {
                                HStack(spacing: ResponsiveLayout.padding(4)) {
                                    Text("Next")
                                    Image(systemName: "chevron.right")
                                }
                                .foregroundColor(AppTheme.primary)
                                .padding()
                            }
                        } else {
                            Button(action: {
                                // Complete onboarding
                                UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
                                hasCompletedOnboarding = true
                                onComplete()  // Call the completion handler
                            }) {
                                Text("Get Started")
                                    .font(.system(
                                        size: ResponsiveLayout.fontSize(18),
                                        weight: .semibold
                                    ))
                                    .foregroundColor(.white)
                                    .padding(.vertical, ResponsiveLayout.isIPad ? 20 : 16)
                                    .padding(.horizontal, ResponsiveLayout.isIPad ? 40 : 32)
                                    .background(AppTheme.secondary)
                                    .cornerRadius(ResponsiveLayout.isIPad ? 16 : 12)
                                    .shadow(color: AppTheme.secondary.opacity(0.3), radius: 5, x: 0, y: 3)
                            }
                        }
                    }
                    .padding(.horizontal, ResponsiveLayout.padding(20))
                    .padding(.bottom, ResponsiveLayout.isIPad ? 60 : 40)
                }
            }
        }
        .onAppear {
            // Check current location permission status
            checkLocationPermission()
        }
    }
    
    private func pageContentView(for page: OnboardingPage, at index: Int, in geometry: GeometryProxy) -> some View {
        VStack(spacing: ResponsiveLayout.isIPad ? 40 : 30) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(LinearGradient(
                        gradient: Gradient(colors: [AppTheme.primary.opacity(0.8), AppTheme.secondary]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(
                        width: ResponsiveLayout.isIPad ? 180 : 120,
                        height: ResponsiveLayout.isIPad ? 180 : 120
                    )
                
                Image(systemName: page.image)
                    .font(.system(
                        size: ResponsiveLayout.isIPad ? 80 : 50
                    ))
                    .foregroundColor(.white)
            }
            .shadow(color: AppTheme.primary.opacity(0.3), radius: 8, x: 0, y: 4)
            
            VStack(spacing: ResponsiveLayout.padding(12)) {
                Text(page.title)
                    .font(.system(
                        size: ResponsiveLayout.fontSize(28),
                        weight: .bold,
                        design: .rounded
                    ))
                    .foregroundColor(AppTheme.textPrimary)
                    .multilineTextAlignment(.center)
                
                Text(page.subtitle)
                    .font(.system(
                        size: ResponsiveLayout.fontSize(18),
                        weight: .medium,
                        design: .rounded
                    ))
                    .foregroundColor(AppTheme.primary)
                    .multilineTextAlignment(.center)
            }
            
            Text(page.description)
                .font(.system(size: ResponsiveLayout.fontSize(16)))
                .foregroundColor(AppTheme.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, ResponsiveLayout.isIPad ? 80 : 40)
                .padding(.top, ResponsiveLayout.padding(8))
            
            // Location permission options on the location page
            if index == 3 {
                VStack(spacing: ResponsiveLayout.padding(10)) {
                    Button(action: {
                        requestLocationPermission()
                    }) {
                        HStack {
                            Image(systemName: "location.fill")
                            Text("Enable Location")
                        }
                        .font(.system(
                            size: ResponsiveLayout.fontSize(16),
                            weight: .semibold
                        ))
                        .foregroundColor(.white)
                        .padding(.vertical, ResponsiveLayout.isIPad ? 20 : 16)
                        .padding(.horizontal, ResponsiveLayout.isIPad ? 32 : 24)
                        .background(AppTheme.primary)
                        .cornerRadius(ResponsiveLayout.isIPad ? 16 : 12)
                        .shadow(color: AppTheme.primary.opacity(0.3), radius: 5, x: 0, y: 3)
                    }
                    .padding(.vertical, ResponsiveLayout.padding(8))
                    
                    Button(action: {
                        // Skip location permission and continue
                        withAnimation {
                            currentPage += 1
                        }
                    }) {
                        Text("Choose Location Later")
                            .font(.system(
                                size: ResponsiveLayout.fontSize(16),
                                weight: .medium
                            ))
                            .foregroundColor(AppTheme.primary)
                            .padding(.vertical, ResponsiveLayout.padding(8))
                    }
                    
                    // Show a message indicating this step is optional
                    Text("Location permission enhances your experience but is optional. You can manually select a city if you prefer.")
                        .font(.system(size: ResponsiveLayout.fontSize(14)))
                        .foregroundColor(AppTheme.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, ResponsiveLayout.isIPad ? 60 : 40)
                        .padding(.top, ResponsiveLayout.padding(12))
                }
                .padding(.vertical, ResponsiveLayout.padding(16))
            }
            
            Spacer()
        }
        .tag(index)
        .padding(.bottom, ResponsiveLayout.isIPad ? 80 : 80)
    }
    
    private func checkLocationPermission() {
        let status = CLLocationManager().authorizationStatus
        locationEnabled = (status == .authorizedWhenInUse || status == .authorizedAlways)
    }
    
    private func requestLocationPermission() {
        let manager = CLLocationManager()
        manager.requestWhenInUseAuthorization()
        
        // Check permission after a short delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            checkLocationPermission()
            // Automatically advance to next screen after a moment regardless of the choice
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation {
                    currentPage += 1
                }
            }
        }
    }
}

// Onboarding Page Model
struct OnboardingPage {
    let title: String
    let subtitle: String
    let image: String
    let description: String
}
