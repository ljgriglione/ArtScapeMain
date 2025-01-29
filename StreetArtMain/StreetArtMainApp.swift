//
//  StreetArtAppApp.swift
//  StreetArtApp
//
//  Created by Logan Griglione on 6/19/24.
//

import SwiftUI
import MapKit
import SwiftData

@main
struct StreetArtMainApp: App {
    var body: some Scene {
        WindowGroup {
           ContentView()
        }
        .modelContainer(for: ArtData.self)
    }
    
}
