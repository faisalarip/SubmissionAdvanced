//
//  FavoriteTableViewVC.swift
//  MySubmissionAdvanced
//
//  Created by Faisal Arif on 21/07/20.
//  Copyright © 2020 Dicoding Indonesia. All rights reserved.
//

import UIKit
import AVKit
import Cosmos
import JGProgressHUD

class FavoriteTableViewVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    private let spinner = JGProgressHUD(style: .dark)
    
    
    var gamesModelFav = [GamesModel]()
    var gamesVC = GamesVC()
    private lazy var gamesProvider: GamesProvider = {
        return GamesProvider()
    }()
    
    private var player: AVPlayer!
    private var playerVC: AVPlayerViewController!
    
    private let ImageNotFound: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(named: "no_result")
        image.translatesAutoresizingMaskIntoConstraints = false
        image.contentMode = .scaleAspectFit
        image.layer.masksToBounds = true
        image.clipsToBounds = true
        image.isHidden = true
        return image
    }()
    
    @IBOutlet var viewFav: UIView!
    @IBOutlet weak var tableViewFav: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        configureNavigationItem()
        
        view.addSubview(ImageNotFound)
        NSLayoutConstraint.activate([
            ImageNotFound.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            ImageNotFound.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            ImageNotFound.topAnchor.constraint(equalTo: view.topAnchor, constant: 100),
            ImageNotFound.widthAnchor.constraint(equalToConstant: 200),
            ImageNotFound.heightAnchor.constraint(equalToConstant: 200)
        ])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        loadGames()
    }
    
    private func loadGames() {
        self.gamesProvider.getAllGames { (result) in
            DispatchQueue.main.async {
                if result.isEmpty {
                    self.ImageNotFound.isHidden = false
                    self.tableViewFav.isHidden = true
                    let alert = UIAlertController(title: "Oppss, Your favorite doesn't exist", message: "Go to the games lists and add games anything you like to favorite", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true)
                } else {
                    self.ImageNotFound.isHidden = true
                    self.tableViewFav.isHidden = false
                    self.gamesModelFav = result
                    
                    self.tableViewFav.reloadData()
                }
                
            }
        }
    }
    
    private func configureTableView() {
        tableViewFav.delegate = self
        tableViewFav.dataSource = self
        tableViewFav.register(UINib(nibName: "GameCell", bundle: nil), forCellReuseIdentifier: "GameCell")
    }
    
    private func configureNavigationItem() {
        let editingItem = UIBarButtonItem(title: tableViewFav.isEditing ? "Done" : "Delete", style: .done, target: self, action: #selector(self.toggleEditing))
        navigationItem.rightBarButtonItems = [editingItem]
    }
    
    @objc private func toggleEditing() {
        tableViewFav.setEditing(!tableViewFav.isEditing, animated: true)
        configureNavigationItem()
    }
    
    // MARK: - TableView Data Source
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return gamesModelFav.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "GameCell", for: indexPath) as? GameCell {
            
            let games = gamesModelFav[indexPath.row]
            
            if let bgImage = games.backgroundImage, let urlString = URL(string: bgImage), let defaultImage = bgImage.first?.description {
                if games.backgroundImage == "", let urlFirstImage = URL(string: defaultImage) {
                    URLSession.shared.dataTask(with: urlFirstImage) { (data, _, _) in
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
            
            // UITableview (View cell) Setup
            if let name = games.name,
                let date = games.dateRealese,
                let genre = games.genres,
                let rating = games.rating,
                let platform = games.platforms,
                let ratingCount = games.ratingsCount,
                let clip = games.clip {
                
                cell.gameName.text = name
                cell.dateLabel.text = date
                cell.platformLabel.numberOfLines = platform.count
                cell.platformLabel.text = platform.joined(separator: ", ")
                cell.genreLabel.numberOfLines = genre.count
                cell.genreLabel.text = genre.joined(separator: ", ")
                cell.ratingVotes.text = String(ratingCount)
                cell.ratingLabel.text = String(rating)
                cell.starsView.rating = rating
                
                // Configuring cache video
                VideoCacheManager.shared.getFileWith(stringUrl: clip) { (result) in
                    switch result {
                        case .success(let url):
                            self.player = AVPlayer(url: url)
                            break;
                        case .failure(let error):
                            print(error, "failure error in the cache of video")
                            break;
                    }
                }
            }
            
            // Video Player Configure
            playerVC = AVPlayerViewController()
            playerVC.player = player
            playerVC.view.frame = cell.videoView.bounds
            addChild(playerVC)
            playerVC.player?.pause()
            cell.videoView.addSubview(playerVC.view)
            
            return cell
        }
        return UITableViewCell()
    }
    
    // MARK: - TableView Delegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let gamesId = gamesModelFav[indexPath.row].id else { return }
        let detailVC = DetailVC(nibName: "DetailVC", bundle: nil)
        detailVC.detailID = gamesId
        self.navigationController?.pushViewController(detailVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete, let gameId = gamesModelFav[indexPath.row].id, let gameName = gamesModelFav[indexPath.row].name {
            
            let alert = UIAlertController(title: "Confirm", message: "You want to delete \(gameName) from favorite?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in
                self.gamesModelFav.remove(at: indexPath.row)
                self.tableViewFav.deleteRows(at: [indexPath], with: .automatic)
                self.gamesProvider.deleteGamesById(gameId) {
                    DispatchQueue.main.async {
                        self.loadGames()
                        let alert = UIAlertController(title: "Successful", message: "Your favorite games has been deleted", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in
                            self.spinner.show(in: self.view)
                            self.navigationController?.popViewController(animated: true)
                            self.spinner.dismiss()
                        }))
                        self.present(alert, animated: true)
                    }
                }
                
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (_) in
                self.navigationController?.popViewController(animated: true)
            }))
            
            self.present(alert, animated: true)
        }
    }
    
}
