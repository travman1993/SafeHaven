//
//  SceneDelegate.swift
//  SafeHaven
//
//  Created by Travis Rodriguez on 3/16/25.
//

// SceneDelegate.swift
import UIKit
import SwiftUI

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }
        
        // Create the SwiftUI view that provides the window contents.
        let contentView = ContentView()
            .environmentObject(WeatherService.shared)
            .environmentObject(LocationService())
        
        // Use a UIHostingController as window root view controller.
        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = UIHostingController(rootView: contentView)
        self.window = window
        window.makeKeyAndVisible()
    }
}
