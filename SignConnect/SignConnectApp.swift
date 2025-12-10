//
//  SignConnectApp.swift
//  SignConnect
//
//  Created by Paulo Jauregui on 12/9/25.
//

import SwiftUI
import SwiftData

@main
struct SignConnectApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        // This single line handles the entire DB setup for us.
        // It automatically creates the schema for Scenario.
        .modelContainer(for: Scenario.self)
    }
}
