//
//  AuthenticationService.swift
//  SafeHaven
//
//  Created by Travis Rodriguez on 3/12/25.
//

import Foundation
import AuthenticationServices
import SwiftUI

class AuthenticationService: ObservableObject {
    @Published var isSignedIn = false
    @Published var userIdentifier: String?
    @Published var userEmail: String?
    @Published var fullName: PersonNameComponents?
    
    init() {
        checkExistingSignIn()
    }
    
    private func checkExistingSignIn() {
        // Check if user is already signed in
        guard let savedUserIdentifier = retrieveUserIdentifierFromKeychain() else {
            isSignedIn = false
            return
        }
        
        // Verify the saved user identifier
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        appleIDProvider.getCredentialState(forUserID: savedUserIdentifier) { [weak self] credentialState, error in
            DispatchQueue.main.async {
                switch credentialState {
                case .authorized:
                    self?.isSignedIn = true
                    self?.userIdentifier = savedUserIdentifier
                case .revoked, .notFound:
                    self?.signOut()
                @unknown default:
                    self?.signOut()
                }
            }
        }
    }
    
    func signIn(
        userIdentifier: String,
        fullName: PersonNameComponents?,
        email: String?,
        completion: @escaping (Result<Bool, Error>) -> Void
    ) {
        // Save user details
        self.userIdentifier = userIdentifier
        self.fullName = fullName
        self.userEmail = email
        
        // Save to keychain
        saveUserIdentifierToKeychain(userIdentifier)
        
        // Set signed in state
        isSignedIn = true
        
        completion(.success(true))
    }
    
    func signOut() {
        // Clear all user-related data
        userIdentifier = nil
        userEmail = nil
        fullName = nil
        isSignedIn = false
        
        // Remove from keychain
        deleteUserIdentifierFromKeychain()
    }
    
    // Keychain Management
    private func saveUserIdentifierToKeychain(_ identifier: String) {
        let keychainItem: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "appleUserIdentifier",
            kSecValueData as String: identifier.data(using: .utf8)!,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlocked
        ]
        
        // Delete existing item first
        SecItemDelete(keychainItem as CFDictionary)
        
        // Add new item
        let status = SecItemAdd(keychainItem as CFDictionary, nil)
        guard status == errSecSuccess else {
            print("Error saving user identifier to keychain")
            return
        }
    }
    
    private func retrieveUserIdentifierFromKeychain() -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "appleUserIdentifier",
            kSecReturnData as String: true
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess,
              let data = result as? Data,
              let identifier = String(data: data, encoding: .utf8) else {
            return nil
        }
        
        return identifier
    }
    
    private func deleteUserIdentifierFromKeychain() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "appleUserIdentifier"
        ]
        
        SecItemDelete(query as CFDictionary)
    }
}
