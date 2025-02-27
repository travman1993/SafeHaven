//
//  SafeHavenApp.swift
//  SafeHaven
//
//  Created by Travis Rodriguez on 2/23/25.
//

//
//  SafeHavenApp.swift
//  SafeHaven
//
//  Created by Travis Rodriguez on 2/23/25.
//

import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    // Add print statement to verify this runs
    print("Configuring Firebase...")
    FirebaseApp.configure()
    print("Firebase configured successfully")
    return true
  }
}

@main
struct SafeHavenApp: App {
  @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
  
  var body: some Scene {
    WindowGroup {
      ContentView()
    }
  }
}
