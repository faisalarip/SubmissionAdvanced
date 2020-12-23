//
//  GamesManager.swift
//  MySubmissionAdvanced
//
//  Created by Faisal Arif on 05/07/20.
//  Copyright © 2020 Dicoding Indonesia. All rights reserved.
//
//
import Foundation

protocol GamesManagerDelegate {
    func didUpdateGames(gamesManager: GamesManager, gamesModel: [GamesModel])
}

struct GamesManager {
    
    var delegate: GamesManagerDelegate?
    
    func fetchGame() {
        let gameURL = "https://api.rawg.io/api/games"
        performQuery(gameURL, GamesResult.self)
    }
    
    func searchGame(searchName: String) {
        /// https://api.rawg.io/api/games?search=%7BGrand%7D
        let gameSearchURL = "https://api.rawg.io/api/games?search=%7B\(searchName)%7D"
        performQuery(gameSearchURL, GamesResult.self)
    }
    
    func detailGame(detailId: String) {
        let gameDetailURL = "https://api.rawg.io/api/games/\(detailId)"
        performQuery(gameDetailURL, GamesResultDetail.self)
    }
    
    func performQuery<T: Codable>(_ urlString: String,_ type: T.Type) {
        if let url = URL(string: urlString) {
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { (data, response, error) in
                guard let safeData = data, error == nil else {
                    print("Failed to get data from URLSession data task")
                    return
                }
                print(safeData)
                
                if type == GamesResult.self   {
                    print(type)
                    guard let model = self.parseJSON(safeData) else { return }
                    self.delegate?.didUpdateGames(gamesManager: self, gamesModel: model)
                } else if type == GamesResultDetail.self {
                    print(type)
                    guard let model = self.parseJSONById(safeData) else { return }
                    self.delegate?.didUpdateGames(gamesManager: self, gamesModel: model)
                }
                
            }
            task.resume()
        }
        
    }
    
    private func parseJSON(_ data: Data) -> [GamesModel]? {
        var gamesModel = [GamesModel]()
        let decoder = JSONDecoder()
        
        do {
            let decodeData = try decoder.decode(Game.self, from: data)
            decodeData.games?.forEach { (result) in
                var platformsList = [String]()
                result.gamePlatform?.forEach { (plat) in
                    if let platlist = plat.platform?.name {
                        platformsList.append(platlist)                        
                    } else {
                        platformsList.append("")
                    }                    
                }
                
                var genreList = [String]()
                result.genres.forEach { (genre) in
                    let genres = genre.name
                    genreList.append(genres)
                }
                
                var clips = String()
                if let clip = result.clip?.clip {
                    clips = clip
                } else {
                    clips = ""
                }
                
                let id = result.id
                let name = result.name
                let bgImage = result.backgroundImage
                
                let realese = result.released
                let rating = result.rating
                let ratingsCount = result.ratingsCount
                
                let gameDataModel = GamesModel(id: Int32(id), selected: false, name: name, alternativeNames: [], description: "", dateRealese: realese, backgroundImage: bgImage, clip: clips, websiteURL: "", rating: rating, ratingsCount: Int64(ratingsCount), platforms: platformsList, genres: genreList)
                
                gamesModel.append(gameDataModel)
            }
            return gamesModel
        } catch {
            print(error)
            return nil
        }
    }
    
    private func parseJSONById(_ data: Data) -> [GamesModel]? {
        var gamesModel = [GamesModel]()
        let decoder = JSONDecoder()
        do {
            let decodeData = try decoder.decode(GamesResultDetail.self, from: data)
            var alternativeNameList = [String]()
            decodeData.alternativeName.forEach { (alternative) in
                alternativeNameList.append(alternative)
            }
            
            var platformsList = [String]()
            decodeData.gamePlatform?.forEach { (plat) in
                if let platlist = plat.platform?.name {
                    platformsList.append(platlist)
                } else {
                    platformsList.append("")
                }
            }
            
            var genreList = [String]()
            decodeData.genres.forEach { (genre) in
                let genres = genre.name
                genreList.append(genres)
            }
            
            let id = decodeData.id
            let name = decodeData.name
            let description = decodeData.description
            let website = decodeData.website
            let bgImage = decodeData.backgroundImage
            let clip = decodeData.clipDetail?.clip
            let realese = decodeData.released
            let rating = decodeData.rating
            let ratingCount = decodeData.ratingCount
            
            let gameDataModel = GamesModel(id: Int32(id), selected: false, name: name, alternativeNames: alternativeNameList, description: description, dateRealese: realese, backgroundImage: bgImage, clip: clip ,websiteURL: website, rating: rating, ratingsCount: Int64(ratingCount), platforms: platformsList, genres: genreList)
            
            gamesModel.append(gameDataModel)
            return gamesModel
        } catch {
            print(error)
            return nil
        }
    }
    
    enum GamesError: Error {
        case gamesErrorCompletion
    }
}
