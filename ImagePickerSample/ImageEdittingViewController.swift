//
//  ImageEdittingViewController.swift
//  ImagePickerSample
//
//  Created by Amelia Boli on 5/19/16.
//  Copyright © 2016 Amelia Boli. All rights reserved.
//

import UIKit
import AVFoundation
//import CoreImage

enum Edge {
    case Left, Right, Top, Bottom
}

class ImageEdittingViewController: UIViewController, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var maskedImage: UIImageView!
    @IBOutlet weak var imageToEdit: UIImageView!
    @IBOutlet weak var imageCropper: UIView!
    @IBOutlet weak var imageCropperBorder: UIView!
    
    @IBOutlet var panGesture: UIPanGestureRecognizer!
    
    var image = UIImage()
    let panBuffer = CGFloat(15)
    var axisChange = [Edge]() //(horizontalChange: Edge.None, verticleChange: Edge.None)
    var currentImageFrame = CGRect()
    
    var imageCropperFrame: CGRect {
        return imageCropper.frame
    }
    
    var resizedImageFrame = CGRect()
    
    let outOfBoundsBuffer = CGFloat(5)
    let minimumSideLength = CGFloat(40)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageToEdit.image = image
        maskedImage.image = image
       
        panGesture.delegate = self
        
        //imageToEdit.maskView = imageCropper
        
        imageCropperBorder.layer.borderColor = UIColor.whiteColor().CGColor
        imageCropperBorder.layer.borderWidth = 3
    }
    
    override func viewDidLayoutSubviews() {
        resizedImageFrame = AVMakeRectWithAspectRatioInsideRect(imageToEdit.image!.size, imageToEdit.bounds)
        let resizedImageCenter = imageToEdit.center
        let resizedImageX = resizedImageCenter.x - (resizedImageFrame.width / 2)
        let resizedImageY = resizedImageCenter.y - (resizedImageFrame.height / 2)
        resizedImageFrame.origin = CGPoint(x: resizedImageX, y: resizedImageY)
        maskedImage.frame = resizedImageFrame
        imageCropper.frame = resizedImageFrame
        imageCropperBorder.frame = resizedImageFrame
        currentImageFrame = resizedImageFrame
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        
        axisChange.removeAll()
        
        let imageCropperFrame = imageCropper.frame
        let leftBorder = UIView(frame: CGRect(x: imageCropperFrame.origin.x - panBuffer, y: imageCropperFrame.origin.y - panBuffer, width: 2 * panBuffer, height: imageCropperFrame.height + (2 * panBuffer)))
        let rightBorder = UIView(frame: CGRectOffset(leftBorder.frame, imageCropperFrame.width, 0))
        let topBorder = UIView(frame: CGRect(x: imageCropperFrame.origin.x - panBuffer, y: imageCropperFrame.origin.y - panBuffer, width: imageCropperFrame.width + (2 * panBuffer), height: 2 * panBuffer))
        let bottomBorder = UIView(frame: CGRectOffset(topBorder.frame, 0, imageCropperFrame.height))
        
        let touchRelativeToLeftBorder = touch.locationInView(leftBorder)
        let touchRelativeToRightBorder = touch.locationInView(rightBorder)
        let touchRelativeToTopBorder = touch.locationInView(topBorder)
        let touchRelativeToBottomBorder = touch.locationInView(bottomBorder)
        
        let inLeftBorder = leftBorder.pointInside(touchRelativeToLeftBorder, withEvent: nil)
        let inRightBorder = rightBorder.pointInside(touchRelativeToRightBorder, withEvent: nil)
        let inTopBorder = topBorder.pointInside(touchRelativeToTopBorder, withEvent: nil)
        let inBottomBorder = bottomBorder.pointInside(touchRelativeToBottomBorder, withEvent: nil)
        
        if inLeftBorder || inRightBorder || inTopBorder || inBottomBorder {
            if inLeftBorder {
                axisChange.append(.Left)
            } else if inRightBorder {
                axisChange.append(.Right)
            }
            
            if inTopBorder {
                axisChange.append(.Top)
            } else if inBottomBorder {
                axisChange.append(.Bottom)
            }
            return true
        } else {
            return false
        }
    }
    
    @IBAction func handlePan(recognizer:UIPanGestureRecognizer) {
        
        if recognizer.state == .Began || recognizer.state == .Changed {
            
            let translation = recognizer.translationInView(self.view)
            var currentFrame = imageCropper.frame
            
            for change in axisChange {
                switch change {
                case .Left: moveLeft(translation, currentFrame: &currentFrame)
                case .Right: moveRight(translation, currentFrame: &currentFrame)
                case .Top: moveTop(translation, currentFrame: &currentFrame)
                case .Bottom: moveBottom(translation, currentFrame: &currentFrame)
                }
            }
            
            imageCropper.frame = currentFrame
            imageCropperBorder.frame = currentFrame
            recognizer.setTranslation(CGPointZero, inView: self.view)
        }
        
        if recognizer.state == .Ended {
            NSTimer.scheduledTimerWithTimeInterval(0.7, target: self, selector: #selector(self.updateImage), userInfo: nil, repeats: false)
        }
    }
    
    func moveLeft(translation: CGPoint, inout currentFrame: CGRect) {
        
        if (currentFrame.width == minimumSideLength && translation.x > 0) ||
            currentFrame.minX < currentImageFrame.minX - outOfBoundsBuffer && (translation.x < 0 || currentFrame.width == minimumSideLength) {
            return
        }
        
        currentFrame.origin.x = currentFrame.origin.x + translation.x
        currentFrame.size.width = currentFrame.width - translation.x
        
        if currentFrame.width < minimumSideLength {
            currentFrame.origin.x += currentFrame.width - minimumSideLength
            currentFrame.size.width = minimumSideLength
        }
        
        if currentFrame.minX < currentImageFrame.minX - outOfBoundsBuffer {
            let previousOriginX = currentFrame.origin.x
            
            currentFrame.origin.x = currentImageFrame.minX - outOfBoundsBuffer
            currentFrame.size.width -= currentFrame.origin.x - previousOriginX
        }
    }
    
    func moveRight(translation: CGPoint, inout currentFrame: CGRect) {
        
        if (currentFrame.width == minimumSideLength && translation.x < 0) ||
            currentFrame.maxX > currentImageFrame.maxX - outOfBoundsBuffer && (translation.x > 0 || currentFrame.width == minimumSideLength) {
            return
        }
        
        currentFrame.size.width = currentFrame.width + translation.x
        
        if currentFrame.width < minimumSideLength {
            currentFrame.size.width = minimumSideLength
        }
        
        if currentFrame.maxX > (currentImageFrame.maxX + outOfBoundsBuffer) {
            currentFrame.size.width -= currentFrame.maxX - (currentImageFrame.maxX + outOfBoundsBuffer)
        }
    }
    
    func moveTop(translation: CGPoint, inout currentFrame: CGRect) {
        
        if (currentFrame.height == minimumSideLength && translation.y > 0) ||
            currentFrame.minY < currentImageFrame.minY - outOfBoundsBuffer && (translation.y < 0 || currentFrame.height == minimumSideLength) {
            return
        }
        
        currentFrame.origin.y = currentFrame.origin.y + translation.y
        currentFrame.size.height = currentFrame.height - translation.y
        
        if currentFrame.height < minimumSideLength {
            currentFrame.origin.y += currentFrame.height - minimumSideLength
            currentFrame.size.height = minimumSideLength
        }
        
        if currentFrame.minY < currentImageFrame.minY - outOfBoundsBuffer {
            let previousOriginY = currentFrame.origin.y
            
            currentFrame.origin.y = currentImageFrame.minY - outOfBoundsBuffer
            currentFrame.size.height -= currentFrame.origin.y - previousOriginY
        }
    }
    
    func moveBottom(translation: CGPoint, inout currentFrame: CGRect) {
        
        if (currentFrame.height == minimumSideLength && translation.y < 0) ||
            currentFrame.maxY > currentImageFrame.maxY - outOfBoundsBuffer && (translation.y > 0 || currentFrame.height == minimumSideLength) {
            return
        }
        
        currentFrame.size.height = currentFrame.height + translation.y
        
        if currentFrame.height < minimumSideLength {
            currentFrame.size.height = minimumSideLength
        }
        
        if currentFrame.maxY > (currentImageFrame.maxY + outOfBoundsBuffer) {
            currentFrame.size.height -= currentFrame.maxY - (currentImageFrame.maxY + outOfBoundsBuffer)
        }
    }
    
    func updateImage() {
        let croppingFrame = imageCropper.frame
        var orientationToSet = UIImageOrientation.Up
        
        let xScale = imageToEdit.image!.size.width / currentImageFrame.size.width
        let yScale = imageToEdit.image!.size.height / currentImageFrame.size.height
        
        let xRelativeToImage = croppingFrame.origin.x - currentImageFrame.origin.x
        let yRelativeToImage = croppingFrame.origin.y - currentImageFrame.origin.y
        
        var newX = xScale * xRelativeToImage
        var newY = yScale * yRelativeToImage
        
        var newWidth = xScale * croppingFrame.width
        var newHeight = yScale * croppingFrame.height
        
        if imageToEdit.image!.imageOrientation == .Right {
            newX = xScale * yRelativeToImage
            newY = yScale * (currentImageFrame.maxX - croppingFrame.maxX)
            newWidth = xScale * croppingFrame.height
            newHeight = yScale * croppingFrame.width
            orientationToSet = .Right
        }
        
        let newOrigin = CGPoint(x: newX, y: newY)
        let newSize = CGSize(width: newWidth, height: newHeight)
        let newFrame = CGRect(origin: newOrigin, size: newSize)
        
        let croppableImage = imageToEdit.image!.CGImage
        let croppedImage = CGImageCreateWithImageInRect(croppableImage, newFrame)
        let croppedUIImage = UIImage(CGImage: croppedImage!, scale: 1, orientation: orientationToSet)
        imageToEdit.image = croppedUIImage
        maskedImage.image = croppedUIImage
    }
}