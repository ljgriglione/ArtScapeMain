//
//  ArtData.swift
//  StreetArtApp
//
//  Created by Logan Griglione on 6/26/24.
//

import Foundation
import SwiftData

@Model
class ArtData {
    @Attribute(.unique)
    var name: String
    var long: Double
    var lat: Double
    
    init(name: String, address: String, long: Double, lat: Double) {
        self.name = name
        self.long = long
        self.lat = lat
    }
}
