//
//  GamesProvider.swift
//  MySubmissionAdvanced
//
//  Created by Faisal Arif on 19/07/20.
//  Copyright © 2020 Dicoding Indonesia. All rights reserved.
//

import UIKit
import CoreData

class GamesProvider {
    lazy var persistanceContainer: NSPersistentContainer = {
        
        let container = NSPersistentContainer(name: "Games")
        
        container.loadPersistentStores { (storeDescription, error) in
            guard error == nil else {
                print("Unresolved load persistenStore")
                return
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = false
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        container.viewContext.shouldDeleteInaccessibleFaults = true
        container.viewContext.undoManager = nil
        
        return container
    }()
    
    private func newTaskContext() -> NSManagedObjectContext {
        let taskContext = persistanceContainer.newBackgroundContext()
        taskContext.undoManager = nil
        
        taskContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return taskContext
    }
    
    func getAllGames(completion: @escaping(_ members: [GamesModel]) -> ()) {
        let taskContext = newTaskContext()
        taskContext.perform {
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Games")
            do {
                let results = try taskContext.fetch(fetchRequest)
                var games: [GamesModel] = []
                for result in results {
                    let game = GamesModel(id: result.value(forKey: "gameId") as? Int32,
                                          selected: result.value(forKey: "gameSelected") as? Bool,
                                          name: result.value(forKey: "gameName") as? String,
                                          alternativeNames: result.value(forKey: "gameFamiliarNames") as? [String],
                                          description: result.value(forKey: "gameAbout") as? String,
                                          dateRealese: result.value(forKey: "gameRelease") as? String,
                                          backgroundImage: result.value(forKey: "gameImage") as? String,
                                          clip: result.value(forKey: "gameClips") as? String,
                                          websiteURL: result.value(forKey: "gameWebsiteUrl") as? String,
                                          rating: result.value(forKey: "gameRating") as? Double,
                                          ratingsCount: result.value(forKey: "gameRatingCount") as? Int64,
                                          platforms: result.value(forKey: "gamePlatform") as? [String],
                                          genres: result.value(forKey: "gameGenre") as? [String])
                    games.append(game)
                }
                completion(games)
            } catch let error as NSError{
                print("Could not fetch. \(error), \(error.userInfo)")
            }
        }
    }
    
    func getGames(_ gameId: Int, completion: @escaping(_ members: GamesModel) -> ()) {
        let taskContext = newTaskContext()
        taskContext.perform {
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Games")
            fetchRequest.fetchLimit = 1
            fetchRequest.predicate = NSPredicate(format: "gameId == \(gameId)")
            do {
                if let result = try taskContext.fetch(fetchRequest).first {
                    let game = GamesModel(id: result.value(forKey: "gameId") as? Int32,
                                          selected: result.value(forKey: "gameSelected") as? Bool,
                                          name: result.value(forKey: "gameName") as? String,
                                          alternativeNames: result.value(forKey: "gameFamiliarNames") as? [String],
                                          description: result.value(forKey: "gameAbout") as? String,
                                          dateRealese: result.value(forKey: "gameRelease") as? String,
                                          backgroundImage: result.value(forKey: "gameImage") as? String,
                                          clip: result.value(forKey: "gameAbout") as? String,
                                          websiteURL: result.value(forKey: "gameWebsiteUrl") as? String,
                                          rating: result.value(forKey: "gameRating") as? Double,
                                          ratingsCount: result.value(forKey: "gameRatingCount") as? Int64,
                                          platforms: result.value(forKey: "gamePlatform") as? [String],
                                          genres: result.value(forKey: "gameGenre") as? [String])
                    completion(game)
                }
                
            } catch let error as NSError{
                print("Could not fetch. \(error), \(error.userInfo)")
            }
        }
    }
    
    func addGames(_ gameId: Int32,
                  _ gameSelected: Bool,
                  _ gameName: String,
                  _ gameFamiliarNames: [String],
                  _ gameAbout: String,
                  _ gameRelease: String,
                  _ gameImage: String,
                  _ gameClips: String,
                  _ gameWebsiteUrl: String,
                  _ gameRating: Double,
                  _ gameRatingCount: Int64,
                  _ gamePlatform: [String],
                  _ gameGenre: [String]) {
        let taskContext = newTaskContext()
        taskContext.performAndWait {
            if let entity = NSEntityDescription.entity(forEntityName: "Games", in: taskContext) {
                let game = NSManagedObject(entity: entity, insertInto: taskContext)
                game.setValue(gameId, forKey: "gameId")
                game.setValue(gameSelected, forKey: "gameSelected")
                game.setValue(gameName, forKey: "gameName")
                game.setValue(gameFamiliarNames, forKey: "gameFamiliarNames")
                game.setValue(gameAbout, forKey: "gameAbout")
                game.setValue(gameRelease, forKey: "gameRelease")
                game.setValue(gameImage, forKey: "gameImage")
                game.setValue(gameClips, forKey: "gameClips")
                game.setValue(gameWebsiteUrl, forKey: "gameWebsiteUrl")
                game.setValue(gameRating, forKey: "gameRating")
                game.setValue(gameRatingCount, forKey: "gameRatingCount")
                game.setValue(gamePlatform, forKey: "gamePlatform")
                game.setValue(gameGenre, forKey: "gameGenre")
                
                do {
                    try taskContext.save()                    
                } catch let error as NSError {
                    print("Could not save. \(error), \(error.userInfo)")
                }
                
            }
        }
    }
    
    func deleteAllGames(completion: @escaping() -> ()) {
        let tasContext = newTaskContext()
        tasContext.perform {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Games")
            let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            batchDeleteRequest.resultType = .resultTypeCount
            if let batchDelegeteResult = try? tasContext.execute(batchDeleteRequest) as? NSBatchDeleteResult, batchDelegeteResult.result != nil {
                completion()
            }
        }
    }
    
    func deleteGamesById(_ gameId: Int32, completion: @escaping() -> ()) {
        let taskContext = newTaskContext()
        taskContext.perform {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Games")
            fetchRequest.fetchLimit = 1
            fetchRequest.predicate = NSPredicate(format: "gameId == \(gameId)")
            let batchDeleteReq = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            batchDeleteReq.resultType = .resultTypeCount
            if let batchDeleteRes = try? taskContext.execute(batchDeleteReq) as? NSBatchDeleteResult, batchDeleteRes.result != nil {
                completion()
            }
            
        }
    }
    
    func updateGame(_ gameId: Int32,
                    _ gameSelected: Bool,
                    _ gameName: String,
                    _ gameFamiliarNames: [String],
                    _ gameAbout: String,
                    _ gameRelease: String,
                    _ gameImage: String,
                    _ gameClips: String,
                    _ gameWebsiteUrl: String,
                    _ gameRating: Double,
                    _ gameRatingCount: Int64,
                    _ gamePlatform: [String],
                    _ gameGenre: [String], completion: @escaping() -> ()) {
        let taskContext = newTaskContext()
        taskContext.perform {
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Games")
            fetchRequest.fetchLimit = 1
            fetchRequest.predicate = NSPredicate(format: "gameId == \(gameId)")
            if let result = try? taskContext.fetch(fetchRequest), let games = result.first as? Games {
                games.setValue(gameName, forKey: "gameName")
                games.setValue(gameSelected, forKey: "gameSelected")
                games.setValue(gameFamiliarNames, forKey: "gameFamiliarNames")
                games.setValue(gameAbout, forKey: "gameAbout")
                games.setValue(gameRelease, forKey: "gameRelease")
                games.setValue(gameImage, forKey: "gameImage")
                games.setValue(gameClips, forKey: "gameClips")
                games.setValue(gameWebsiteUrl, forKey: "gameWebsiteUrl")
                games.setValue(gameRating, forKey: "gameRating")
                games.setValue(gameRatingCount, forKey: "gameRatingCount")
                games.setValue(gamePlatform, forKey: "gamePlatform")
                games.setValue(gameGenre, forKey: "gameGenre")
                do {
                    try taskContext.save()
                } catch let error as NSError {
                    print("Could not save. \(error), \(error.userInfo)")
                }
            }
            
        }
    }    
    
}

