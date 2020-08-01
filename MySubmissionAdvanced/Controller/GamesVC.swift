//
//  ViewController.swift
//  MySubmissionAdvanced
//
//  Created by Faisal Arif on 04/07/20.
//  Copyright © 2020 Dicoding Indonesia. All rights reserved.
//

import UIKit
import AVKit
import JGProgressHUD

class GamesVC: UIViewController, GamesManagerDelegate {
    
    private let spinner = JGProgressHUD(style: .dark)
    
    private var gameItems = [GamesModel]()
    private var gamesManager = GamesManager()
    private var gamesProvider = GamesProvider()
    
    private var player = AVPlayer()
    private var playerVC = AVPlayerViewController()
    
    @IBOutlet weak var tableView: UITableView!
    
    private var videoURL = [String]()
    private var dataIdFav = [Int32]()
    
    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.searchBarStyle = .prominent
        searchBar.placeholder = "Search 'Games name'"
        searchBar.sizeToFit()
        searchBar.isTranslucent = false
        searchBar.backgroundColor = .systemBackground
        return searchBar
    }()
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        playerVC.player?.removeObserver(self, forKeyPath: "timeControlStatus")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "GameCell", bundle: nil), forCellReuseIdentifier: "GameCell")
        
        spinner.show(in: view)
        gamesManager.delegate = self
        searchBar.delegate = self        
        tableView.addSubview(searchBar)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        if ProfileModel.stateLogin == false {
            let nav = UINavigationController(rootViewController: CreateAccountVC())
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: false)
        } else {
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
            gamesManager.fetchGame()
        }
        
    }
    
    @objc private func avPlayerClosed() {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
            self.player.play()
        }
    }
    
    /// Update data source after fetching from JSONDecoder
    func didUpdateGames(gamesManager: GamesManager, gamesModel: [GamesModel]) {
        DispatchQueue.main.async {
            self.gameItems = gamesModel
            
            if self.gameItems.isEmpty {
                self.tableView.reloadData()
                self.spinner.dismiss()
                let alert = UIAlertController(title: "Oppss, No Result Games", message: "Let's try to search another games", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                    self.searchBar.searchTextField.text = ""
                    self.searchBar.becomeFirstResponder()
                }))
                /// Handle duplicate present alert, when fetch data from json still process
                if let presented = self.presentedViewController {
                    presented.removeFromParent()
                }
                if self.presentedViewController == nil {
                    self.present(alert, animated: true)
                }
                
            } else {
                
                for data in self.dataIdFav {
                    for i in 0..<self.gameItems.count {
                        if self.gameItems[i].id == data {
                            self.gameItems[i].selected = true
                        }
                    }
                }
                for i in (0..<self.gameItems.count).reversed() {
                    if self.gameItems[i].clip != "" {
                        guard let clip = self.gameItems[i].clip else { return }
                        self.videoURL.append(clip)
                    }
                    if self.gameItems[i].clip == "" {
                        self.gameItems[i].clip = self.videoURL[i]                        
                    }
                }
                
                self.tableView.reloadData()
                self.spinner.dismiss()
            }
            
        }
    }
    
    // MARK: - Favorite Manager
    @objc private func didTapFavorite(_ sender: UIButton) {
        guard let gameIdFav = gameItems[sender.tag].id,
            let gameNameFav = gameItems[sender.tag].name,
            let gameFamiliarNames = gameItems[sender.tag].alternativeNames,
            let gameAbout = gameItems[sender.tag].description,
            let gameRealeseFav = gameItems[sender.tag].dateRealese,
            let gameImageFav = gameItems[sender.tag].backgroundImage,
            let gameClips = gameItems[sender.tag].clip,
            let gameWebsiteUrl = gameItems[sender.tag].websiteURL,
            let gameRatingFav = gameItems[sender.tag].rating,
            let gameRatingCountFav = gameItems[sender.tag].ratingsCount,
            let gamePlatformFav = gameItems[sender.tag].platforms,
            let gameGenreFav = gameItems[sender.tag].genres else { return }
        
        if sender.isSelected == true {
            
            /// Selected true (Game has been added to favorite)
            let alert = UIAlertController(title: "Confirm", message: "You want to remove \(gameNameFav) from Favorites?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                self.gamesProvider.deleteGamesById(gameIdFav) {
                    DispatchQueue.main.async {
                        let alert = UIAlertController(title: "Succesfull", message: "Your games \(gameNameFav) has been deleted from favorites", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in
                            print("Games has been deleted")
                            for i in 0..<self.dataIdFav.count {
                                if self.dataIdFav[i] == gameIdFav {
                                    self.dataIdFav[i] = .zero
                                }
                            }
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
            /// Selected false (not yet added to favorite)
            sender.isSelected = true
            
            sender.zoomInWithEasing()
            
            let alert = UIAlertController(title: "Confirm", message: "You want added \(gameNameFav) to favorite?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                print("succesfully added")
                /// Add games to Core Data
                self.gamesProvider.addGames(gameIdFav, true, gameNameFav, gameFamiliarNames, gameAbout, gameRealeseFav, gameImageFav, gameClips, gameWebsiteUrl, gameRatingFav, gameRatingCountFav, gamePlatformFav, gameGenreFav)
                
                self.dataIdFav.append(gameIdFav)
                
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
                sender.zoomOut()
                sender.isSelected = false
            }))
            self.present(alert, animated: true, completion: nil)
            
        }
        
    }
    
}

// MARK: - Table View Manager
extension GamesVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return gameItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GameCell", for: indexPath) as! GameCell
        
        let games = gameItems[indexPath.row]
        
        /// Setup view game image in cell
        if let bgImage = games.backgroundImage, let urlString = URL(string: bgImage), let defaultImage = bgImage.first?.description {
            if games.backgroundImage == "", let firstImageUrl = URL(string: defaultImage) {
                URLSession.shared.dataTask(with: firstImageUrl) { (data, _, _) in
                    guard let safeData = data else { return }
                    DispatchQueue.main.async {
                        cell.gameImage.image = UIImage(data: safeData)
                    }
                }
            } else {
                URLSession.shared.dataTask(with: urlString) { (data, _, _) in
                    guard let safeData = data else { return }
                    DispatchQueue.main.async {
                        cell.gameImage.image = UIImage(data: safeData)
                    }
                }.resume()
            }
        }
        
        /// UITableViewCell Setup games view
        if let name = games.name,
            let date = games.dateRealese,
            let genre = games.genres,
            let rating = games.rating,
            let platform = games.platforms,
            let ratingsCount = games.ratingsCount,
            let clip = games.clip
        {
            cell.gameName.text = name
            cell.dateLabel.text = date
            cell.platformLabel.numberOfLines = platform.count
            cell.platformLabel.text = platform.joined(separator: ", ")
            cell.genreLabel.numberOfLines = genre.count
            cell.genreLabel.text = genre.joined(separator: ", ")
            cell.ratingVotes.text = String(ratingsCount)
            cell.ratingLabel.text = String(rating)
            cell.starsView.rating = rating
            
            /// Configuring cache video
            VideoCacheManager.shared.getFileWith(stringUrl: clip) { (result) in
                switch result {
                    case .success(let url):
                        self.player = AVPlayer(url: url)
                        break;
                    case .failure(let error):
                        print(error, "filure in the cache of video")
                        break;
                }
            }
        }
        /// Video Palyer Configure
        playerVC = AVPlayerViewController()
        playerVC.player = player
        playerVC.view.frame = cell.videoView.bounds
        playerVC.player?.isMuted = true
        cell.videoView.addSubview(playerVC.view)
        addChild(playerVC)        
        playerVC.player?.play()
        
        if games.selected == true {
            cell.favoriteButton.tag = indexPath.row
            cell.favoriteButton.isSelected = true
            cell.favoriteButton.addTarget(self, action: #selector(didTapFavorite(_:)), for: .touchUpInside)
            cell.favoriteButton.setImage(UIImage(systemName: "heart.fill"), for: .selected)
        } else {
            cell.favoriteButton.tag = indexPath.row
            cell.favoriteButton.addTarget(self, action: #selector(didTapFavorite(_:)), for: .touchUpInside)
            cell.favoriteButton.setImage(UIImage(systemName: "heart.fill"), for: .selected)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let gameDetailId = gameItems[indexPath.row].id else { return }        
        let detailVC = DetailVC(nibName: "DetailVC", bundle: nil)
        detailVC.detailID = gameDetailId        
        self.navigationController?.pushViewController(detailVC, animated: true)
    }
    
}

// MARK: - Search Bar Delegate
extension GamesVC: UISearchBarDelegate {
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
        searchBar.becomeFirstResponder()
    }
    
    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        return true
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard !searchText.replacingOccurrences(of: " ", with: "").isEmpty else {
            return
        }
        gameItems.removeAll()
        gamesManager.searchGame(searchName: searchText)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchBar.text = ""
        searchBar.showsCancelButton = false
        spinner.show(in: view)
        gameItems.removeAll()
        gamesManager.fetchGame()
    }
    
}

