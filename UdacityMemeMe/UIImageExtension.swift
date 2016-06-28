//
//  UIImageExtension.swift
//  UdacityMemeMe
//
//  Created by Amelia Boli on 6/21/16.
//  Copyright © 2016 Amelia Boli. All rights reserved.
//

import UIKit
import AVFoundation

extension UIImageView {
    var resizedFrame: CGRect? {
        
        guard let image = image else {
            return nil
        }
        
        var resizedImageFrame = AVMakeRectWithAspectRatioInsideRect(image.size, bounds)
        let resizedImageCenter = center
        
        let resizedImageX = resizedImageCenter.x - (resizedImageFrame.width / 2)
        let resizedImageY = resizedImageCenter.y - (resizedImageFrame.height / 2)
        
        resizedImageFrame.origin = CGPoint(x: resizedImageX, y: resizedImageY)
        
        return resizedImageFrame
    }
}
