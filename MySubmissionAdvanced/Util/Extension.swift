//
//  Extension.swift
//  MySubmissionAdvanced
//
//  Created by Faisal Arif on 30/07/20.
//  Copyright © 2020 Dicoding Indonesia. All rights reserved.
//

import UIKit
import AVKit

extension AVPlayerViewController {
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        self.player?.pause()
        NotificationCenter.default.post(name: Notification.Name(rawValue: "avPalyerDidDismiss"), object: nil, userInfo: nil)
    }
}

extension UIView {
    func zoomOut(duration: TimeInterval = 0.2) {
        self.transform = CGAffineTransform(scaleX: 0.0, y: 0.0)
        UIView.animate(withDuration: duration, delay: 0.0, options: [.curveLinear], animations: { () -> Void in
            self.transform = .identity
        }) { (animationComplete: Bool) -> Void in
        }
    }
    
    func zoomInWithEasing(duration: TimeInterval = 0.2, easingOffeset: CGFloat = 0.4) {
        let easeScale = 1.0 + easingOffeset
        let easingDuration = TimeInterval(easingOffeset) * duration / TimeInterval(easeScale)
        let scalingDuration = duration - easingDuration
        UIView.animate(withDuration: scalingDuration, delay: 0.0, options: .curveEaseIn, animations: { () -> Void in
            self.transform = CGAffineTransform(scaleX: easeScale, y: easeScale)
        }) { (completion) in
            UIView.animate(withDuration: easingDuration, delay: 0.0, options: .curveEaseOut, animations: {
                self.transform = .identity
            }) { (completed: Bool) -> Void in
            }
        }
    }
    
}
