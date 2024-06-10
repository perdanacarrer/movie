//
//  movieApp.swift
//  movie
//
//  Created by oscar perdana on 07/06/24.
//

import SwiftUI

@main
struct MovieApp: App {
    @StateObject private var appRootManager = AppRootManager()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(appRootManager)
                .preferredColorScheme(.light)
        }
    }
}
