//
//  VideoCacheManager.swift
//  MySubmissionAdvanced
//
//  Created by Faisal Arif on 30/07/20.
//  Copyright © 2020 Dicoding Indonesia. All rights reserved.
//

import Foundation

public enum Result<T> {
    case success(T)
    case failure(NSError)
}

class VideoCacheManager {
    
    static let shared = VideoCacheManager()
    private let fileManager = FileManager.default
    private lazy var mainDirectory: URL? = {
        if let documentUrl = self.fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first {
            return documentUrl
        }
        return nil
    }()
    
    func getFileWith(stringUrl: String, completionHandler: @escaping (Result<URL>) -> Void ) {
        
        guard let file = directoryFor(stringUrl: stringUrl) else { return }
        
        guard !fileManager.fileExists(atPath: file.path) else {
            completionHandler(.success(file))
            return
        }
        
        DispatchQueue.global().async {
            if let url = URL(string: stringUrl), let videoData = NSData(contentsOf: url) {
                videoData.write(to: file, atomically: true)
                DispatchQueue.main.async {
                    let error = NSError(domain: "SomeErrorDomain" , code: -2001 /* some error code */, userInfo: ["description": "Can't download video, maybe your connection not good"])
                    completionHandler(.failure(error))
                }
            }
        }
        
    }
    
    private func directoryFor(stringUrl: String) -> URL? {
        
        if let fileURL = URL(string: stringUrl)?.lastPathComponent, let file = self.mainDirectory?.appendingPathComponent(fileURL) {
            
            return file
        }
        return nil
    }
    
}
