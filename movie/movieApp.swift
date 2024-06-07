//
//  movieApp.swift
//  movie
//
//  Created by oscar perdana on 07/06/24.
//

import SwiftUI

@main
struct movieApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
