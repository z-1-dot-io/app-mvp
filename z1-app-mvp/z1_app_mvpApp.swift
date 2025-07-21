//
//  z1_app_mvpApp.swift
//  z1-app-mvp
//
//  Created by Amit Anand on 7/19/25.
//

import SwiftUI

@main
struct z1_app_mvpApp: App {
    @StateObject private var serviceContainer = ServiceContainer()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(serviceContainer)
        }
    }
}
