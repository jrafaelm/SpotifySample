//
//  Track.swift
//  SpotifySample
//
//  Created by Rafael Moraes on 19/05/18.
//  Copyright © 2018 Rafael Moraes. All rights reserved.
//

import Foundation

struct Tracks: Codable {
    var items: [Track]?

    enum CodingKeys: String, CodingKey {
        case items = "tracks"
    }
}

struct Track: Codable {
    var name: String?
    var uri: String?
    var durationInMilis: Double?
    enum CodingKeys: String, CodingKey {
        case name
        case uri
        case durationInMilis = "duration_ms"
    }
}
