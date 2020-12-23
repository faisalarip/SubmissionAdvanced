//
//  CreateAccountVC.swift
//  MySubmissionAdvanced
//
//  Created by Faisal Arif on 19/07/20.
//  Copyright © 2020 Dicoding Indonesia. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift

class CreateAccountVC: UIViewController {
    
    @IBOutlet weak var photoProfile: UIImageView!
    @IBOutlet weak var usernameProfile: UITextField!
    @IBOutlet weak var emailProfile: UITextField!
    @IBOutlet weak var professionProfile: UITextField!
    @IBOutlet weak var aboutProfile: UITextView!
    @IBOutlet weak var githubProfile: UITextField!
    @IBOutlet weak var linkedinProfile: UITextField!
    @IBOutlet weak var createButton: RoundedButton!
    
    private var newPngImage = Data()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Create New Account"
        updateUI()
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(self.didTapChangePhotoProfile))
        gesture.numberOfTapsRequired = 1
        photoProfile.addGestureRecognizer(gesture)
    }
    
    @IBAction func createButtonTapped(_ sender: Any) {
        if let name = usernameProfile.text,
            let photo = photoProfile.image,
            let pngData = photo.pngData(),
            let email = emailProfile.text,
            let about = aboutProfile.text,
            let profession = professionProfile.text,
            let github = githubProfile.text,
            let linkedin = linkedinProfile.text {
            
            if pngData != newPngImage {                
                textEmpty("Photo")
            } else if name.isEmpty{
                textEmpty("Name")
            } else if email.isEmpty {
                textEmpty("Email")
            } else if about.isEmpty {
                textEmpty("About")
            } else if profession.isEmpty {
                textEmpty("Profession")
            } else if github.isEmpty {
                textEmpty("Github")
            } else if linkedin.isEmpty {
                textEmpty("Linkedin")
            } else {
                saveProfile(name, pngData, email, profession, about, github, linkedin)
                self.navigationController?.dismiss(animated: true, completion: nil)
            }
            
        }
    }
    
    @objc private func didTapChangePhotoProfile() {
        print("Tapped photo profile")
        presentPhotoActionSheet()
    }
    
    func saveProfile(_ name: String,
                     _ photo: Data,
                     _ email: String,
                     _ profession: String,
                     _ about: String,
                     _ githubUrl: String,
                     _ linkedinUrl: String)
    {
        ProfileModel.stateLogin = true
        ProfileModel.name = name
        ProfileModel.photo = photo
        ProfileModel.email = email
        ProfileModel.profession = profession
        ProfileModel.about = about
        ProfileModel.githubUrl = githubUrl
        ProfileModel.linkedinUrl = linkedinUrl
    }
    
    private func textEmpty(_ field: String) {
        let alert = UIAlertController(title: "Oppss.. \(field) is empty", message: "Please, enter all information to log in", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true)
    }
    
    private func updateUI() {
        usernameProfile.autocorrectionType = .no
        emailProfile.autocorrectionType = .no
        professionProfile.autocorrectionType = .no
        githubProfile.autocorrectionType = .no
        linkedinProfile.autocorrectionType = .no
        aboutProfile.autocorrectionType = .no
        
        createButton.greenColorForButton()
        aboutProfile.delegate = self
        aboutProfile.layer.cornerRadius = aboutProfile.frame.height * 0.042
        aboutProfile.layer.borderWidth = 1
        aboutProfile.layer.borderColor = UIColor.systemGray5.cgColor
        aboutProfile.text = "Type something about you.."
        aboutProfile.textColor = UIColor.systemGray5
    }
}

extension CreateAccountVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func presentPhotoActionSheet() {
        
        let actionSheet = UIAlertController(title: "Profile picture", message: "How would you like to select a picture", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        actionSheet.addAction(UIAlertAction(title: "Take photo", style: .default, handler: { (_) in
            self.presentCamera()
        }))
        actionSheet.addAction(UIAlertAction(title: "Choose photo", style: .default, handler: { (_) in
            self.presentPhotoPicker()
        }))
        
        present(actionSheet, animated: true)
    }
    
    func presentCamera() {
        let vc = UIImagePickerController()
        vc.sourceType = .camera
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true)
    }
    
    func presentPhotoPicker() {
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        
        guard let selectedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage, let pngData = selectedImage.pngData() else { return }
        newPngImage = pngData
        photoProfile.image = selectedImage
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

extension CreateAccountVC: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if aboutProfile.textColor == UIColor.systemGray5 {
            aboutProfile.text = nil
            aboutProfile.textColor = UIColor.label
        }
    }
    
}
