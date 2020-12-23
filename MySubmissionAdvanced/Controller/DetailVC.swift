//
//  DetailVC.swift
//  MySubmissionAdvanced
//
//  Created by Faisal Arif on 09/07/20.
//  Copyright © 2020 Dicoding Indonesia. All rights reserved.
//

import UIKit
import AVKit
import Cosmos
import SafariServices
import JGProgressHUD

class DetailVC: UIViewController, GamesManagerDelegate {
    
    @IBOutlet weak var videoViewDetail: UIView!
    @IBOutlet weak var imageGameDetail: UIImageView!
    @IBOutlet weak var labelGameNameDetail: UILabel!
    @IBOutlet weak var labelFamiliarName: UILabel!
    @IBOutlet weak var labelAboutDetail: UILabel!
    @IBOutlet weak var labelGenreGameDetail: UILabel!
    @IBOutlet weak var labelDateGameDetail: UILabel!
    @IBOutlet weak var labelRatingGameDetail: UILabel!
    @IBOutlet weak var labelPlatfromsGameDetail: UILabel!
    @IBOutlet weak var linkWebsite: UILabel!
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var startsViewDetail: CosmosView!
    
    private var gameModelsDetail: GamesModel?
    private var gamesManager = GamesManager()
    private var gamesProvider = GamesProvider()
    
    private let spinner = JGProgressHUD(style: .dark)
    
    private var player: AVPlayer!
    private var playerVC: AVPlayerViewController!
    
    var detailID = Int32()
    
    private var dataIdFav = [Int32]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.largeTitleDisplayMode = .never
        gamesManager.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        spinner.show(in: view)
        DispatchQueue.main.async {
            self.gamesProvider.getAllGames { (results) in
                if !results.isEmpty {
                    for result in results {
                        guard let id = result.id else { return }
                        self.dataIdFav.append(id)
                    }
                } else {
                    self.dataIdFav.removeAll()
                }
            }
        }
        if dataIdFav.isEmpty {
            gameModelsDetail?.selected = false
            favoriteButton.isSelected = false
            favoriteButton.zoomOut()
            self.favoriteButton.reloadInputViews()
        }
        gamesManager.detailGame(detailId: String(detailID))
    }
    
    @IBAction func favoriteButtonTapped(_ sender: UIButton) {
        guard let gameIdFav = gameModelsDetail?.id,
                    let gameNameFav = gameModelsDetail?.name,
                    let gameFamiliarNames = gameModelsDetail?.alternativeNames,
                    let gameAbout = gameModelsDetail?.description,
                    let gameRealeseFav = gameModelsDetail?.dateRealese,
                    let gameImageFav = gameModelsDetail?.backgroundImage,
                    let gameClips = gameModelsDetail?.clip,
                    let gameWebsiteUrl = gameModelsDetail?.websiteURL,
                    let gameRatingFav = gameModelsDetail?.rating,
                    let gameRatingCountFav = gameModelsDetail?.ratingsCount,
                    let gamePlatformFav = gameModelsDetail?.platforms,
                    let gameGenreFav = gameModelsDetail?.genres else { return }
                
                if sender.isSelected == true {
                    
                    // Selected true (Game has been added to favorite)
                    let alert = UIAlertController(title: "Confirm", message: "You want to remove \(gameNameFav) from Favorites?", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in
                        self.gamesProvider.deleteGamesById(gameIdFav) {
                            DispatchQueue.main.async {
                                let alert = UIAlertController(title: "Succesfull", message: "Your games \(gameNameFav) has been deleted from favorites", preferredStyle: .alert)
                                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in
                                    
                                    self.navigationController?.popViewController(animated: true)
                                }))
                                self.present(alert, animated: true)
                            }
                        }
                        sender.isSelected = false
                        sender.zoomOut()
                    }))
                    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (_) in
                        print("doesn't cancel")
                        sender.zoomInWithEasing()
                    }))
                    self.present(alert, animated: true, completion: nil)
                } else {
                    // Selected false (not yet added to favorite)
                    sender.isSelected = true
                    
                    sender.zoomInWithEasing()
                    
                    let alert = UIAlertController(title: "Confirm", message: "You want added \(gameNameFav) to favorite?", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in
                        print("succesfully added")
                        // Add games to Core Data
                        self.gamesProvider.addGames(gameIdFav, true, gameNameFav, gameFamiliarNames, gameAbout, gameRealeseFav, gameImageFav, gameClips, gameWebsiteUrl, gameRatingFav, gameRatingCountFav, gamePlatformFav, gameGenreFav)
                        
                        self.dataIdFav.append(gameIdFav)                        
                    }))
                    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (_) in
                        sender.zoomOut()
                        sender.isSelected = false
                    }))
                    self.present(alert, animated: true, completion: nil)
                    
                }
                
            
    }
    @IBAction func showWebsite(_ sender: UIButton) {
        guard let urlString = gameModelsDetail?.websiteURL, let url = URL(string: urlString) else { return }
        let sf = SFSafariViewController(url: url)
        present(sf, animated: true)
        if sf.isBeingDismissed {
            spinner.dismiss()
        }
    }
    
    // Update data source after fetching data from JSONDecoder
    func didUpdateGames(gamesManager: GamesManager, gamesModel: [GamesModel]) {
        DispatchQueue.main.async {
            self.gameModelsDetail = gamesModel[0]
            for data in self.dataIdFav {
                if self.gameModelsDetail?.id == data {
                    self.gameModelsDetail?.selected = true
                    self.favoriteButton.isSelected = true
                    self.favoriteButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
                    self.favoriteButton.reloadInputViews()
                }
                print(data)
                if self.gameModelsDetail?.id != data {
                    self.gameModelsDetail?.selected = false
                    self.favoriteButton.isSelected = false
                    self.favoriteButton.setImage(UIImage(systemName: "heart"), for: .normal)
                    self.favoriteButton.reloadInputViews()
                }
                
            }
            self.spinner.dismiss()
            self.updateUI()
            self.updateAVPlayer()
        }
        
    }
    
    // Update UI for table view cell
    private func updateUI() {
        title = gameModelsDetail?.name
        if let result = gameModelsDetail, let bgimage = result.backgroundImage {
            guard let urlString = URL(string: bgimage) else { return }
            
            URLSession.shared.dataTask(with: urlString) { (data, _, _) in
                guard let safeData = data else { return }
                DispatchQueue.main.async {
                    self.imageGameDetail.image = UIImage(data: safeData)
                }
            }.resume()
            
            if let name = result.name,
                let familiarName = result.alternativeNames,
                let aboutGame = result.description,
                let dateRelease = result.dateRealese,
                let rating = result.rating,
                let platform = result.platforms,
                let genres = result.genres,
                let webUrl = result.websiteURL,
                let selected = result.selected {
                
                if familiarName == [] {
                    labelFamiliarName.text = name
                } else {
                    labelFamiliarName.numberOfLines = familiarName.count
                    labelFamiliarName.text = familiarName.joined(separator: ", ")
                }
                let editedText = aboutGame.replacingOccurrences(of: "<p>", with: "")
                let editedText2 = editedText.replacingOccurrences(of: "</p>", with: "   ")
                let editedText3 = editedText2.replacingOccurrences(of: "<br />", with: "\n")
                labelAboutDetail.text = editedText3
                
                labelGameNameDetail.text = name
                labelDateGameDetail.text = dateRelease
                labelRatingGameDetail.text = String(rating)
                startsViewDetail.rating = rating
                labelPlatfromsGameDetail.numberOfLines = platform.count
                labelPlatfromsGameDetail.text = platform.joined(separator: ", ")
                labelGenreGameDetail.numberOfLines = genres.count
                labelGenreGameDetail.text = genres.joined(separator: ", ")
                linkWebsite.text = webUrl
                
                if selected == true {
                    favoriteButton.isSelected = true
                    favoriteButton.setImage(UIImage(systemName: "heart.fill"), for: .selected)
                }
                else {
                    favoriteButton.setImage(UIImage(systemName: "heart"), for: .normal)
                    favoriteButton.setImage(UIImage(systemName: "heart.fill"), for: .selected)
                }
            }
            
        }
    }
    
    // Setup video player
    private func updateAVPlayer() {
        
        if let clipUrl = gameModelsDetail?.clip {
            VideoCacheManager.shared.getFileWith(stringUrl: clipUrl) { (result) in
                switch result {
                    case .success(let url):
                        self.player = AVPlayer(url: url)
                        break;
                    case .failure(let error):
                        print(error, "failure error in the cache of video")
                        break;
                }
            }
            
            playerVC = AVPlayerViewController()
            playerVC.player = player
            playerVC.view.frame = self.videoViewDetail.bounds
            addChild(playerVC)
            playerVC.player?.play()
            self.videoViewDetail.addSubview(playerVC.view)
        }
        
    }
    
}
