//
//  UpdateProfileVC.swift
//  MySubmissionAdvanced
//
//  Created by Faisal Arif on 30/07/20.
//  Copyright © 2020 Dicoding Indonesia. All rights reserved.
//

import UIKit

class UpdateProfileVC: UIViewController {
    
    @IBOutlet weak var photoProfileUpdate: UIImageView!
    @IBOutlet weak var usernameUpdateField: UITextField!
    @IBOutlet weak var professionUpdateField: UITextField!
    @IBOutlet weak var aboutUpdateTextView: UITextView!
    @IBOutlet weak var emailUpdateField: UITextField!
    @IBOutlet weak var githubUpdateField: UITextField!
    @IBOutlet weak var linkedinUpdateField: UITextField!
    @IBOutlet weak var updateButtonOutlet: RoundedButton!
    @IBOutlet weak var cancelButtonOutlet: RoundedButton!
    @IBOutlet weak var resetButtonOutlet: RoundedButton!
    
    private var newPngData = Data()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "EditAccount"
        
        updateUI()
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(didTapPhoto))
        gesture.numberOfTapsRequired = 1
        photoProfileUpdate.addGestureRecognizer(gesture)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        if ProfileModel.stateLogin == false {
            print("statelogin")
        } else {
            ProfileModel.synchronize()
            if let photo = ProfileModel.photo {
                photoProfileUpdate.image = UIImage(data: photo)
            }
            usernameUpdateField.text = ProfileModel.name
            professionUpdateField.text = ProfileModel.profession
            aboutUpdateTextView.text = ProfileModel.about
            emailUpdateField.text = ProfileModel.email
            githubUpdateField.text = ProfileModel.githubUrl
            linkedinUpdateField.text = ProfileModel.linkedinUrl
            
        }
        
    }
    
    @objc private func didTapPhoto() {
        presentPhotoActionSheet()
    }
    
    @IBAction func updateButtonAction(_ sender: Any) {
        
        if let name = usernameUpdateField.text,
            let photo = photoProfileUpdate.image,
            let pngData = photo.pngData(),
            let email = emailUpdateField.text,
            let about = aboutUpdateTextView.text,
            let profession = professionUpdateField.text,
            let github = githubUpdateField.text,
            let linked = linkedinUpdateField.text
        {
            
            if pngData != newPngData {
                photoAlert("Image photo")
            } else if name.isEmpty{
                textEmpty("Name")
            } else if email.isEmpty {
                textEmpty("Email")
            } else if about.isEmpty {
                textEmpty("about")
            } else if profession.isEmpty {
                textEmpty("profession")
            } else if github.isEmpty {
                textEmpty("gitHub")
            } else if linked.isEmpty {
                textEmpty("LinkedId")
            } else {
                saveProfile(name, newPngData, email, profession, about, github, linked)
                
                self.navigationController?.dismiss(animated: true, completion: nil)
            }
            
        }
        
    }
    
    @IBAction func cancelButtonAction(_ sender: Any) {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func resetButtonAction(_ sender: Any) {
        if ProfileModel.deleteAll() {
            let nav = UINavigationController(rootViewController: CreateAccountVC())
            nav.modalPresentationStyle = .fullScreen
            self.present(nav, animated: true)
        }
    }
    
    private func saveProfile(_ name: String,
                             _ photo: Data,
                             _ email: String,
                             _ profession: String,
                             _ about: String,
                             _ github: String,
                             _ linkedin: String)
    {
        ProfileModel.stateLogin = true
        ProfileModel.name = name
        ProfileModel.photo = photo
        ProfileModel.email = email
        ProfileModel.profession = profession
        ProfileModel.about = about
        ProfileModel.githubUrl = github
        ProfileModel.linkedinUrl = linkedin
    }
    
    private func textEmpty(_ field: String) {
        let alert = UIAlertController(title: "Oppss.. \(field) is empty", message: "Please, enter all information to update your profile", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default , handler: nil))
        self.present(alert, animated: true)
    }
    
    private func photoAlert(_ field: String) {
        let alert = UIAlertController(title: "Oppss.. your \(field) hasn't changed", message: "Are you sure to keep the previous photo?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            guard let pngPhoto = self.photoProfileUpdate.image?.pngData() else { return }
            self.newPngData = pngPhoto
        }))
        self.present(alert, animated: true)
    }
    
    private func updateUI() {
        usernameUpdateField.autocorrectionType = .no
        professionUpdateField.autocorrectionType = .no
        aboutUpdateTextView.autocorrectionType = .no
        emailUpdateField.autocorrectionType = .no
        githubUpdateField.autocorrectionType = .no
        linkedinUpdateField.autocorrectionType = .no
        
        updateButtonOutlet.greenColorForButton()
        aboutUpdateTextView.layer.cornerRadius = aboutUpdateTextView.frame.height * 0.042
        aboutUpdateTextView.layer.borderWidth = 1
        aboutUpdateTextView.layer.borderColor = UIColor.systemGray5.cgColor
        
        cancelButtonOutlet.borderColor = UIColor(red: 46/255, green: 204/255, blue: 113/255, alpha: 1)
        cancelButtonOutlet.setTitleColor(UIColor(red: 46/255, green: 204/255, blue: 113/255, alpha: 1), for: .normal)
        resetButtonOutlet.borderColor = UIColor(red: 231/255, green: 76/255, blue: 60/255, alpha: 1)
        resetButtonOutlet.setTitleColor(UIColor(red: 231/255, green: 76/255, blue: 60/255, alpha: 1), for: .normal)
        resetButtonOutlet.backgroundColor = .systemBackground
    }
}

extension UpdateProfileVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func presentPhotoActionSheet() {
        
        let actionSheet = UIAlertController(title: "Profile Picture", message: "How would you like to select a picture", preferredStyle: .actionSheet)
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
        
        guard let selectedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage, let pngData = selectedImage.pngData() else { return }
        newPngData = pngData
        photoProfileUpdate.image = selectedImage
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

