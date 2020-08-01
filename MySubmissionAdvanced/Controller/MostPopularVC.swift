//
//  ViewController.swift
//  MySubmissionAdvanced
//
//  Created by Faisal Arif on 04/07/20.
//  Copyright © 2020 Dicoding Indonesia. All rights reserved.
//

import UIKit

class GamesVC: UIViewController {
    
    private var gameItems = [GamesModel]()
    private var gamesManager = GamesManager()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.gamesManager.delegate = self
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "GameCell", bundle: nil), forCellReuseIdentifier: "GameCell")
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.jsonData()
        alertWelcome()
    }
    
    private func jsonData() {
        self.gamesManager.performQuery(completion: { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
                case .failure(let error):
                print(error)
                case .success(let model):
                    strongSelf.gameItems = model
                    DispatchQueue.main.async {
                        self?.tableView.reloadData()
                }
            }
        })
    }
    
    private func alertWelcome() {
        let alert = UIAlertController(title: "Hello World", message: "Welcome to my Game Catalog Apps", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Lets see", style: .cancel, handler: nil))
        present(alert, animated: true)
    }
    
}

extension GamesVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return gameItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GameCell", for: indexPath) as! GameCell
        
        let games = gameItems[indexPath.row]
        
        URLSession.shared.dataTask(with: URL(string: games.backgroundImage)!) { (data, _, _) in
                guard let safeData = data else { return }
            DispatchQueue.main.async {
                cell.gameImage.image = UIImage(data: safeData)
            }
        }.resume()
        
        cell.gameName.text = games.name
        cell.dateLabel.text = games.dateRealese
        cell.genreLabel.numberOfLines = games.genres.count
        cell.genreLabel.text = games.genres.joined(separator: ",")
        cell.ratingLabel.text = String(games.rating)
        
        return cell
    }
        
}

extension GamesVC: GameManagerDelegate {
    func didUpdateGameModel(with gameManager: GamesManager, gameModel: [GamesModel]) {
        
            gameItems = gameModel
    }
    
    func didFail(error: Error) {
        print(error)
    }
    
    
}
