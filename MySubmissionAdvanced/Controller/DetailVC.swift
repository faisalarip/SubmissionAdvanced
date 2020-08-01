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
    @IBOutlet weak var startsViewDetail: CosmosView!
    
    private var gameModelsDetail: GamesModel?
    private var gamesManager = GamesManager()
    
    private let spinner = JGProgressHUD(style: .dark)
    
    private var player: AVPlayer!
    private var playerVC: AVPlayerViewController!
    
    var detailID = Int32()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.largeTitleDisplayMode = .never
        gamesManager.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        spinner.show(in: view)        
        gamesManager.detailGame(detailId: String(detailID))
    }
    
    @IBAction func showWebsite(_ sender: UIButton) {
        guard let urlString = gameModelsDetail?.websiteURL, let url = URL(string: urlString) else { return }
        let sf = SFSafariViewController(url: url)
        present(sf, animated: true)
        if sf.isBeingDismissed {
            spinner.dismiss()
        }
    }
    
    /// Update data source after fetching data from JSONDecoder
    func didUpdateGames(gamesManager: GamesManager, gamesModel: [GamesModel]) {
        DispatchQueue.main.async {
            self.gameModelsDetail = gamesModel[0]
            self.spinner.dismiss()
            
            self.updateUI() 
            self.updateAVPlayer()
        }
    }
    
    /// Update UI for table view cell
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
                let webUrl = result.websiteURL {
                
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
            }
            
        }
    }
    
    /// Setup video player
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
            playerVC.didMove(toParent: self)
            playerVC.player?.isMuted = false
            self.videoViewDetail.addSubview(playerVC.view)
        }
        
    }
    
}
