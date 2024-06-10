//
//  AppRootManager.swift
//  movie
//
//  Created by oscar perdana on 08/06/24.
//

import SwiftUI
import Foundation

class AppRootManager: ObservableObject {
    @Published var isLoggedIn: Bool = false

    init() {
        if let (username, _) = loadCredentials(), !username.isEmpty {
            self.isLoggedIn = true
        }
    }

    func switchToLogin() {
        isLoggedIn = false
    }
    
    func switchToMain() {
        isLoggedIn = true
    }
}

struct RootView: View {
    @EnvironmentObject private var appRootManager: AppRootManager
    
    var body: some View {
        if appRootManager.isLoggedIn {
            MovieListView()
                .environmentObject(appRootManager)
        } else {
            NavigationView {
                OnboardingView()
                    .environmentObject(appRootManager)
            }
        }
    }
}

struct StartView: View {
    @EnvironmentObject private var appRootManager: AppRootManager
    
    var body: some View {
        NavigationView {
            OnboardingView()
        }
    }
}

class AuthManager {
    func validateLogin(username: String, password: String) -> Bool {
        return username == "VVVBB" && password == "@bcd1234"
    }
}

