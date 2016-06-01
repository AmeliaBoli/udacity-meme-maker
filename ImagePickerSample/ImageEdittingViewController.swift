//
//  ImageEdittingViewController.swift
//  ImagePickerSample
//
//  Created by Amelia Boli on 5/19/16.
//  Copyright © 2016 Amelia Boli. All rights reserved.
//

import UIKit
import AVFoundation

class ImageEdittingViewController: UIViewController, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var maskedImage: UIImageView!
    @IBOutlet weak var imageToEdit: UIImageView!
    @IBOutlet weak var imageCropper: UIView!
    @IBOutlet weak var imageCropperBorder: UIView!
    
    @IBOutlet var panGesture: UIPanGestureRecognizer!
    
    enum Edge {
        case Left, Right, Top, Bottom
    }
    
    var image = UIImage()
    var axisChange = [Edge]()

    let panBuffer = CGFloat(15)
    let outOfBoundsBuffer = CGFloat(5)
    let minimumSideLength = CGFloat(40)
    
    var cropperXOffset = CGFloat(0)
    var cropperYOffset = CGFloat(0)
    
    var currentImageFrame = CGRect()
    var resizedImageFrame = CGRect()
    
    var newGesture = UIPanGestureRecognizer()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageToEdit.image = image
        maskedImage.image = image
        
        panGesture.delegate = self

        imageToEdit.maskView = imageCropper
        
        imageCropperBorder.layer.borderColor = UIColor.whiteColor().CGColor
        imageCropperBorder.layer.borderWidth = 1
    }
    
    override func viewDidLayoutSubviews() {
        resizedImageFrame = AVMakeRectWithAspectRatioInsideRect(imageToEdit.image!.size, imageToEdit.bounds)
        let resizedImageCenter = imageToEdit.center
        let resizedImageX = resizedImageCenter.x - (resizedImageFrame.width / 2)
        let resizedImageY = resizedImageCenter.y - (resizedImageFrame.height / 2)
        resizedImageFrame.origin = CGPoint(x: resizedImageX, y: resizedImageY)
        currentImageFrame = resizedImageFrame
        imageCropperBorder.frame = resizedImageFrame
        addCornerHandles(imageCropperBorder.bounds)
        imageCropper.frame = CGRectOffset(resizedImageFrame, -imageToEdit.frame.origin.x, -imageToEdit.frame.origin.y)
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    func addCornerHandles(bounds: CGRect) {
        //imageCropperBorder.layer.layoutSublayers()
        
        if let sublayers = imageCropperBorder.layer.sublayers {
            for layer in sublayers {
                layer.removeFromSuperlayer()
            }
        }
        
        let frameOffset = CGFloat(2)
        
        let horizontalSize = CGSize(width: 22, height: 2)
        let verticalSize = CGSize(width: 2, height: 22)
        
        let leftX = CGFloat(bounds.origin.x - frameOffset)
        let rightX = CGFloat(bounds.maxX - horizontalSize.width + frameOffset)
        let rightVerticalX = CGFloat(bounds.maxX)
        let topY = CGFloat(bounds.origin.y - frameOffset)
        let bottomY = CGFloat(bounds.maxY - verticalSize.height + frameOffset)
        let bottomHorizontalY = CGFloat(bounds.maxY)
        
        let backgroundColor = UIColor.whiteColor().CGColor
        
        let topLeft: CALayer = {
            $0.backgroundColor = backgroundColor
            $0.frame = CGRect(origin: CGPoint(x: leftX, y: topY), size: horizontalSize)
            return $0
        } (CALayer())
        imageCropperBorder.layer.addSublayer(topLeft)
        
        let topRight: CALayer = {
            $0.backgroundColor = backgroundColor
            $0.frame = CGRect(origin: CGPoint(x: rightX, y: topY), size: horizontalSize)
            return $0
        } (CALayer())
        imageCropperBorder.layer.addSublayer(topRight)
        
        let bottomLeft: CALayer = {
            $0.backgroundColor = backgroundColor
            $0.frame = CGRect(origin: CGPoint(x: leftX, y: bottomHorizontalY), size: horizontalSize)
            return $0
        } (CALayer())
        imageCropperBorder.layer.addSublayer(bottomLeft)

        let bottomRight: CALayer = {
            $0.backgroundColor = backgroundColor
            $0.frame = CGRect(origin: CGPoint(x: rightX, y: bottomHorizontalY), size: horizontalSize)
            return $0
        } (CALayer())
        imageCropperBorder.layer.addSublayer(bottomRight)
        
        let leftTop: CALayer = {
            $0.backgroundColor = backgroundColor
            $0.frame = CGRect(origin: CGPoint(x: leftX, y: topY), size: verticalSize)
            return $0
        } (CALayer())
        imageCropperBorder.layer.addSublayer(leftTop)
        
        let leftBottom: CALayer = {
            $0.backgroundColor = backgroundColor
            $0.frame = CGRect(origin: CGPoint(x: leftX, y: bottomY), size: verticalSize)
            return $0
        } (CALayer())
        imageCropperBorder.layer.addSublayer(leftBottom)
        
        let rightTop: CALayer = {
            $0.backgroundColor = backgroundColor
            $0.frame = CGRect(origin: CGPoint(x: rightVerticalX, y: topY), size: verticalSize)
            return $0
        } (CALayer())
        imageCropperBorder.layer.addSublayer(rightTop)
        
        let rightBottom: CALayer = {
            $0.backgroundColor = backgroundColor
            $0.frame = CGRect(origin: CGPoint(x: rightVerticalX, y: bottomY), size: verticalSize)
            return $0
        } (CALayer())
        imageCropperBorder.layer.addSublayer(rightBottom)
        
//        imageCropperBorder.layer.borderColor = UIColor.whiteColor().CGColor
//        imageCropperBorder.layer.borderWidth = 1
    }

    @IBAction func resetImage(sender: UIBarButtonItem) {
        maskedImage.image = image
        imageToEdit.image = image
    }
    
    // Cropping Handling
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        
        axisChange.removeAll()
        
        let imageCropperBorderFrame = imageCropperBorder.frame
        let leftBorder = UIView(frame: CGRect(x: imageCropperBorderFrame.origin.x - panBuffer, y: imageCropperBorderFrame.origin.y - panBuffer, width: 2 * panBuffer, height: imageCropperBorderFrame.height + (2 * panBuffer)))
        let rightBorder = UIView(frame: CGRectOffset(leftBorder.frame, imageCropperBorderFrame.width, 0))
        let topBorder = UIView(frame: CGRect(x: imageCropperBorderFrame.origin.x - panBuffer, y: imageCropperBorderFrame.origin.y - panBuffer, width: imageCropperBorderFrame.width + (2 * panBuffer), height: 2 * panBuffer))
        let bottomBorder = UIView(frame: CGRectOffset(topBorder.frame, 0, imageCropperBorderFrame.height))
        
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
            
            //UIView.animateWithDuration(0) {
                self.imageCropperBorder.frame = CGRectOffset(currentFrame, self.imageToEdit.frame.origin.x, self.imageToEdit.frame.origin.y)
            addCornerHandles(imageCropperBorder.bounds)
            //}
            //imageCropperBorder.layer.layoutSublayers()
            recognizer.setTranslation(CGPointZero, inView: self.view)
        }
        
        if recognizer.state == .Ended {
            NSTimer.scheduledTimerWithTimeInterval(0.7, target: self, selector: #selector(self.updateImage), userInfo: nil, repeats: false)
        }
    }
    
    func moveLeft(translation: CGPoint, inout currentFrame: CGRect) {
        let minX = resizedImageFrame.minX - imageToEdit.frame.minX
        
        if translation.x == 0 {
            return
        } else if translation.x < 0 && currentFrame.minX == minX  {
            return
        } else if translation.x > 0 && currentFrame.width == minimumSideLength {
            return
        }
        
        currentFrame.origin.x = currentFrame.origin.x + translation.x
        currentFrame.size.width = currentFrame.width - translation.x
        
        if currentFrame.width < minimumSideLength {
            currentFrame.origin.x += currentFrame.width - minimumSideLength
            currentFrame.size.width = minimumSideLength
        }
        
        if currentFrame.minX < minX {
            let previousOriginX = currentFrame.origin.x
            
            currentFrame.origin.x = minX
            currentFrame.size.width += previousOriginX - minX
        }
    }
    
    func moveRight(translation: CGPoint, inout currentFrame: CGRect) {
        let maxX = currentFrame.minX + currentImageFrame.width
        
        if translation.x == 0 {
            return
        } else if translation.x < 0 && currentFrame.width == minimumSideLength {
            return
        } else if translation.x > 0 && currentFrame.maxX == maxX {
            return
        }
        
        currentFrame.size.width = currentFrame.width + translation.x
        
        if currentFrame.width < minimumSideLength {
            currentFrame.size.width = minimumSideLength
        }
        
        if currentFrame.maxX > maxX {
            currentFrame.size.width -= (currentFrame.maxX + imageToEdit.frame.origin.x) - currentImageFrame.maxX
        }
    }
    
    func moveTop(translation: CGPoint, inout currentFrame: CGRect) {
        let minY = resizedImageFrame.minY - imageToEdit.frame.minY
        
        if translation.y == 0 {
            return
        } else if translation.y < 0 && currentFrame.minY == minY {
            return
        } else if translation.y > 0 && currentFrame.height == minimumSideLength {
            return
        }
        
        currentFrame.origin.y = currentFrame.origin.y + translation.y
        currentFrame.size.height = currentFrame.height - translation.y
        
        if currentFrame.height < minimumSideLength {
            currentFrame.origin.y += currentFrame.height - minimumSideLength
            currentFrame.size.height = minimumSideLength
        }
        
        if currentFrame.minY < minY {
            let previousOriginY = currentFrame.origin.y
            
            currentFrame.origin.y = minY
            currentFrame.size.height += previousOriginY - minY
        }
    }
    
    func moveBottom(translation: CGPoint, inout currentFrame: CGRect) {
        let maxY = currentFrame.minY + currentImageFrame.height
        
        if translation.y == 0 {
            return
        } else if translation.y < 0 && currentFrame.height == minimumSideLength {
            return
        } else if translation.y > 0 && currentFrame.maxY == maxY {
            return
        }
        
        currentFrame.size.height = currentFrame.height + translation.y
        
        if currentFrame.height < minimumSideLength {
            currentFrame.size.height = minimumSideLength
        }
        
        if currentFrame.maxY > maxY {
            currentFrame.size.height -= (currentFrame.maxY + imageToEdit.frame.origin.y) - currentImageFrame.maxY
        }
    }
    
    func updateImage() {
        let croppingFrame = imageCropper.frame
        
        if currentImageFrame == CGRectOffset(croppingFrame, imageToEdit.frame.origin.x, imageToEdit.frame.origin.y) {
            return
        }
        
        var orientationToSet = UIImageOrientation.Up
        
        let scale = imageToEdit.image!.size.width / currentImageFrame.size.width
        //let yScale = imageToEdit.image!.size.height / currentImageFrame.size.height
        
        let xRelativeToImage = (croppingFrame.origin.x + imageToEdit.frame.origin.x) - currentImageFrame.origin.x
        let yRelativeToImage = (croppingFrame.origin.y + imageToEdit.frame.origin.y) - currentImageFrame.origin.y
        
        var newX = scale * xRelativeToImage
        var newY = scale * yRelativeToImage
        
        var newWidth = scale * croppingFrame.width
        var newHeight = scale * croppingFrame.height
        
        if imageToEdit.image!.imageOrientation == .Right {
            newX = scale * yRelativeToImage
            newY = scale * (currentImageFrame.maxX - (croppingFrame.maxX + imageToEdit.frame.minX))
            newWidth = scale * croppingFrame.height
            newHeight = scale * croppingFrame.width
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