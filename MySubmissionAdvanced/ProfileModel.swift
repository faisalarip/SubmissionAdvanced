//
//  ProfileModel.swift
//  MySubmissionAdvanced
//
//  Created by Faisal Arif on 30/07/20.
//  Copyright © 2020 Dicoding Indonesia. All rights reserved.
//

import Foundation

struct ProfileModel {
    static let stateLoginKey = "state"
    static let nameKey = "name"
    static let emailKey = "email"
    static let photoKey = "photo"
    static let aboutKey = "about"
    static let professionKey = "profession"
    static let githubUrlKey = "githubUrl"
    static let linkedinUrlKey = "linkedinUrl"
    
    static var stateLogin: Bool {
        get {
            return UserDefaults.standard.bool(forKey: stateLoginKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: stateLoginKey)
        }
    }
    
    static var name: String {
        get {
            return UserDefaults.standard.string(forKey: nameKey) ?? ""
        }
        set {
            UserDefaults.standard.set(newValue, forKey: nameKey)
        }
    }
    
    static var email: String {
        get {
            return UserDefaults.standard.string(forKey: emailKey) ?? ""
        }
        set {
            UserDefaults.standard.set(newValue, forKey: emailKey)
        }
    }
    
    static var photo: Data? {
        get {
            if let data = UserDefaults.standard.data(forKey: photoKey) {
                return data
            }
            return nil
        }
        set {
            UserDefaults.standard.set(newValue, forKey: photoKey)
        }
    }
    
    static var about: String {
        get {
            return UserDefaults.standard.string(forKey: aboutKey) ?? ""
        }
        set {
            return UserDefaults.standard.set(newValue, forKey: aboutKey)
        }
    }
    
    static var profession: String {
        get {
            UserDefaults.standard.string(forKey: professionKey) ?? ""
        }
        set {
            UserDefaults.standard.set(newValue, forKey: professionKey)
        }
    }
    
    static var githubUrl: String {
        get {
            UserDefaults.standard.string(forKey: githubUrlKey) ?? ""
        }
        set {
            UserDefaults.standard.set(newValue, forKey: githubUrlKey)
        }
    }
    
    static var linkedinUrl: String {
        get {
            UserDefaults.standard.string(forKey: linkedinUrlKey) ?? ""
        }
        set {
            UserDefaults.standard.set(newValue, forKey: linkedinUrlKey)
        }
    }
    
    static func deleteAll() -> Bool {
        if let domain = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: domain)
            synchronize()
            return true
        } else { return false }
    }
    
    static func synchronize() {
        UserDefaults.standard.synchronize()
    }
}
