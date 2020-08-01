//
//  ProfileVC.swift
//  MySubmissionAdvanced
//
//  Created by Faisal Arif on 04/07/20.
//  Copyright © 2020 Dicoding Indonesia. All rights reserved.
//

import UIKit
import WebKit
import SafariServices

class ProfileVC: UIViewController {
    
    @IBOutlet weak var myProfileImageView: UIImageView!
    @IBOutlet weak var myNameLabel: UILabel!
    @IBOutlet weak var myProfesiLabel: UILabel!
    @IBOutlet weak var aboutMeLabel: UILabel!
    @IBOutlet weak var myEmailLabel: UILabel!
    @IBOutlet weak var myGithubLabel: UILabel!
    @IBOutlet weak var myLinkedinLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit", style: .done, target: self, action: #selector(didTapEditButton))
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        ProfileModel.synchronize()
        if let dataPhotoPng = ProfileModel.photo {
            myProfileImageView.image = UIImage(data: dataPhotoPng)
        }
        
        myNameLabel.text = ProfileModel.name
        myProfesiLabel.text = ProfileModel.profession
        aboutMeLabel.text = ProfileModel.about
        myEmailLabel.text = ProfileModel.email
        myGithubLabel.text = ProfileModel.githubUrl
        myLinkedinLabel.text = ProfileModel.linkedinUrl
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        myGithubLabel.textColor = .systemBlue
        myLinkedinLabel.textColor = .systemBlue
    }
    
    @objc private func didTapEditButton() {
        print("Editt tapped")
        let nav = UINavigationController(rootViewController: UpdateProfileVC())
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true)
    }
    
    @IBAction func myGitHub() {
        guard let urlGitHub = URL(string: ProfileModel.githubUrl) else { return }
        let vc = SFSafariViewController(url: urlGitHub)
        present(vc, animated: true)
    }
    
    @IBAction func myLinkedin() {
        guard let urlLinkedIn = URL(string: ProfileModel.linkedinUrl) else { return }
        let vc = SFSafariViewController(url: urlLinkedIn)
        present(vc, animated: true)
    }
    
}
