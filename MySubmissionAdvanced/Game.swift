//
//  GameItems.swift
//  MySubmissionAdvanced
//
//  Created by Faisal Arif on 04/07/20.
//  Copyright © 2020 Dicoding Indonesia. All rights reserved.
//

import UIKit

struct Game: Codable {
    public var games: [GamesResult]?
    
    enum CodingKeys: String, CodingKey {
        case games = "results"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        games = try container.decode([GamesResult].self, forKey: .games)
    }
}

struct GamesResult: Codable {
    let id: Int
    let name: String
    let released: String
    let backgroundImage: String
    var clip: Clips?
    let rating: Double
    let ratingsCount: Int
    var gamePlatform: [Platform]? // results[0].platforms[0].platform.name
    let genres: [Genre]
    
    enum CodingKeys: String, CodingKey {
        case id, name, released, rating, genres, clip
        case backgroundImage = "background_image"
        case gamePlatform = "platforms"
        case ratingsCount = "ratings_count"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decodeIfPresent(Int.self, forKey: .id) ?? 0
        name = try container.decodeIfPresent(String.self, forKey: .name) ?? ""
        backgroundImage = try container.decodeIfPresent(String.self, forKey: .backgroundImage) ?? ""
        clip = try container.decodeIfPresent(Clips.self, forKey: .clip) ?? nil
        released = try container.decodeIfPresent(String.self, forKey: .released) ?? ""
        rating = try container.decodeIfPresent(Double.self, forKey: .rating) ?? 0
        ratingsCount = try container.decodeIfPresent(Int.self, forKey: .ratingsCount) ?? 0
        gamePlatform = try container.decodeIfPresent([Platform].self, forKey: .gamePlatform)
        genres = try container.decode([Genre].self, forKey: .genres)
        
    }
}






