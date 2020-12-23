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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        NotificationCenter.default.addObserver(self, selector: #selector(avPlayerClosed), name: Notification.Name.AVPlayerItemDidPlayToEndTime, object: playerVC.player)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        if ProfileModel.stateLogin == false {
            let nav = UINavigationController(rootViewController: CreateAccountVC())
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: false)
        } else {
            gamesManager.fetchGame()
        }
        
    }
    
    @objc private func avPlayerClosed() {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
            self.player.pause()
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
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in
                    self.searchBar.searchTextField.text = ""
                    self.searchBar.becomeFirstResponder()
                }))
                
                self.present(alert, animated: true)
                
            } else {
                
                for index in (0..<self.gameItems.count).reversed() {
                    if self.gameItems[index].clip != "" {
                        guard let clip = self.gameItems[index].clip else { return }
                        self.videoURL.append(clip)
                    }
                    if self.gameItems[index].clip == "" {
                        let randomInt = Int.random(in: 0..<self.videoURL.count)
                        self.gameItems[index].clip = self.videoURL[randomInt]
                    }
                }
                
                self.tableView.reloadData()
                self.spinner.dismiss()
            }
            
        }
    }
    
}

// MARK: - Table View Management
extension GamesVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return gameItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "GameCell", for: indexPath) as? GameCell {
            
            let games = gameItems[indexPath.row]
            
            /// Setup view game image in cell
            if let bgImage = games.backgroundImage, let urlString = URL(string: bgImage), let defaultImage = bgImage.first?.description {
                cell.imageView?.contentMode = .scaleAspectFit
                cell.imageView?.translatesAutoresizingMaskIntoConstraints = false
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
            
            // UITableViewCell Setup games view
            if let name = games.name,
                let date = games.dateRealese,
                let genre = games.genres,
                let rating = games.rating,
                let platform = games.platforms,
                let ratingsCount = games.ratingsCount,
                let clip = games.clip {
                
                cell.gameName.text = name
                cell.dateLabel.text = date
                cell.platformLabel.numberOfLines = platform.count
                cell.platformLabel.text = platform.joined(separator: ", ")
                cell.genreLabel.numberOfLines = genre.count
                cell.genreLabel.text = genre.joined(separator: ", ")
                cell.ratingVotes.text = String(ratingsCount)
                cell.ratingLabel.text = String(rating)
                cell.starsView.rating = rating
                
                // Configuring cache video
                VideoCacheManager.shared.getFileWith(stringUrl: clip) { (result) in
                    switch result {
                        case .success(let url):
                            self.player = AVPlayer(url: url)
                            break;
                        case .failure(let error):
                            print(error, "failure in the cache of video")
                            break;
                    }
                }
                
            }
            // Video Palyer Configure
            playerVC = AVPlayerViewController()            
            playerVC.player = player
            playerVC.view.frame = cell.videoView.bounds
            cell.videoView.addSubview(playerVC.view)
            addChild(playerVC)
            playerVC.player?.pause()
            
            return cell
        }
        return UITableViewCell()
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
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchText = searchBar.text?.replacingOccurrences(of: " ", with: ""), !searchText.isEmpty else {
            return
        }
        spinner.show(in: view)
        gameItems.removeAll()
        gamesManager.searchGame(searchName: searchText)
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

