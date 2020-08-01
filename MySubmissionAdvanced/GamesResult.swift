
//  GameResult.swift
//  MySubmissionAdvanced
//
//  Created by Faisal Arif on 05/07/20.
//  Copyright © 2020 Dicoding Indonesia. All rights reserved.


import UIKit

struct GamesResultDetail: Codable {
    let id: Int
    let name: String
    let alternativeName: [String]
    let description: String
    let released: String
    let backgroundImage: String
    let website: String
    let rating: Double
    var gamePlatform: [Platform]? // results[0].platforms[0].platform.name
    let genres: [Genre]

    enum CodingKeys: String, CodingKey {
        case id, name, released, rating, genres, website, description
        case backgroundImage = "background_image"
        case gamePlatform = "platforms"
        case alternativeName = "alternative_names"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decodeIfPresent(Int.self, forKey: .id) ?? 0
        name = try container.decodeIfPresent(String.self, forKey: .name) ?? ""
        alternativeName = try container.decodeIfPresent([String].self, forKey: .alternativeName) ?? []
        description = try container.decodeIfPresent(String.self, forKey: .description) ?? ""
        backgroundImage = try container.decodeIfPresent(String.self, forKey: .backgroundImage) ?? ""
        website = try container.decodeIfPresent(String.self, forKey: .website) ?? ""
        released = try container.decodeIfPresent(String.self, forKey: .released) ?? ""
        rating = try container.decodeIfPresent(Double.self, forKey: .rating) ?? 0
        gamePlatform = try container.decodeIfPresent([Platform].self, forKey: .gamePlatform)
        genres = try container.decode([Genre].self, forKey: .genres)        
        
    }
}

private struct DummyData: Codable { }

struct Genre: Codable {
    let name: String
}

struct Platform: Codable {
    var platform: Platforms?
}

struct Platforms: Codable {
    var name: String?
}

