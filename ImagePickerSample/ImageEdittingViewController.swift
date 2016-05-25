//
//  ImageEdittingViewController.swift
//  ImagePickerSample
//
//  Created by Amelia Boli on 5/19/16.
//  Copyright © 2016 Amelia Boli. All rights reserved.
//

import UIKit
import AVFoundation

enum Edge {
    case Left, Right, Top, Bottom
}

class ImageEdittingViewController: UIViewController, UIGestureRecognizerDelegate {

    @IBOutlet weak var imageToEdit: UIImageView!
    @IBOutlet weak var imageCropper: UIView!
    @IBOutlet var panGesture: UIPanGestureRecognizer!
    
    var image = UIImage()
    let panBuffer = CGFloat(15)
    var axisChange = [Edge]() //(horizontalChange: Edge.None, verticleChange: Edge.None)
    var currentImageFrame = CGRect()
    
    var imageCropperFrame: CGRect {
        return imageCropper.frame
    }
    
    let outOfBoundsBuffer = CGFloat(5)
    let minimumSideLength = CGFloat(40)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageToEdit.image = image
        imageCropper.layer.borderWidth = 1.0
        imageCropper.layer.borderColor = UIColor.whiteColor().CGColor
        panGesture.delegate = self
    }
    override func viewDidLayoutSubviews() {
        var resizedImageFrame = AVMakeRectWithAspectRatioInsideRect(imageToEdit.image!.size, imageToEdit.bounds)
        let resizedImageCenter = imageToEdit.center
        let resizedImageX = resizedImageCenter.x - (resizedImageFrame.width / 2)
        let resizedImageY = resizedImageCenter.y - (resizedImageFrame.height / 2)
        resizedImageFrame.origin = CGPoint(x: resizedImageX, y: resizedImageY)
        imageCropper.frame = resizedImageFrame
        currentImageFrame = resizedImageFrame
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        
        // FIXME: If the sides are too close how does it know which one it is moving?
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
        
        recognizer.setTranslation(CGPointZero, inView: self.view)
    }
    
    func moveLeft(translation: CGPoint, inout currentFrame: CGRect) {
        currentFrame.origin.x = currentFrame.origin.x + translation.x
        print("Translation is \(translation.x) and CurrentFrameX is \(currentFrame.origin.x) and CurrentImageFrameX is \(currentImageFrame.minX)")
        print(translation.x < 0 && currentFrame.origin.x <= (currentImageFrame.minX - outOfBoundsBuffer))
        currentFrame.size.width = currentFrame.width - translation.x
        
        if currentFrame.width < minimumSideLength {
            currentFrame.size.width = minimumSideLength
            
            if currentFrame.maxX > (currentImageFrame.maxX + outOfBoundsBuffer) {
                currentFrame.origin.x = currentFrame.origin.x - (currentFrame.maxX - (currentImageFrame.maxX + outOfBoundsBuffer))
            }
        }
        
        if currentFrame.minX < currentImageFrame.minX - outOfBoundsBuffer {
            currentFrame.origin.x = currentImageFrame.minX - outOfBoundsBuffer
            
            if currentFrame.maxX > (currentImageFrame.maxX + outOfBoundsBuffer) {
                currentFrame.size.width = (currentImageFrame.maxX + outOfBoundsBuffer) - currentFrame.origin.x
            }
        }
    }
    
    func moveRight(translation: CGPoint, inout currentFrame: CGRect) {
        currentFrame.size.width = currentFrame.maxX + translation.x
        
        if currentFrame.width < minimumSideLength {
            currentFrame.size.width = minimumSideLength
        }
        
        if currentFrame.maxX > (currentImageFrame.maxX + outOfBoundsBuffer) {
            currentFrame.origin.x = currentFrame.origin.x - (currentFrame.maxX - (currentImageFrame.maxX + outOfBoundsBuffer))
        }
    }
    
    func moveTop(translation: CGPoint, inout currentFrame: CGRect) {
        currentFrame.origin.y = currentFrame.origin.y + translation.y
        currentFrame.size.height = currentFrame.height - translation.y
        
        if currentFrame.height < minimumSideLength {
            currentFrame.size.height = minimumSideLength
            
            if currentFrame.maxY > (currentImageFrame.maxY + outOfBoundsBuffer) {
                currentFrame.origin.y = currentFrame.origin.y - (currentFrame.maxY - (currentImageFrame.maxY + outOfBoundsBuffer))
            }
        }
        
        if currentFrame.minY < currentImageFrame.minY - outOfBoundsBuffer {
            currentFrame.origin.y = currentImageFrame.minY - outOfBoundsBuffer
        }

    }
    
    func moveBottom(translation: CGPoint, inout currentFrame: CGRect) {
        currentFrame.size.height = currentFrame.maxY + translation.y
        
        if currentFrame.height < minimumSideLength {
            currentFrame.size.height = minimumSideLength
        }
        
        if currentFrame.maxY > (currentImageFrame.maxY + outOfBoundsBuffer) {
            currentFrame.origin.y = currentFrame.origin.y - (currentFrame.maxY - (currentImageFrame.maxY + outOfBoundsBuffer))
        }

    }
}
        
//        var changes = (xOrigin: 0, yOrigin: 0, width: 0, height: 0)
//        
//        if axisChange.horizontalChange == .Left {
//            changes.xOrigin = 1
//            changes.width = 1
//        } else if axisChange.horizontalChange == .Right {
//            changes.width = -1
//        }
//        
//        if axisChange.verticleChange == .Top {
//            changes.yOrigin = 1
//            changes.height  = 1
//        } else if axisChange.verticleChange == .Bottom {
//            changes.height = -1
//        }
//        
//        updateFrame(changes, translation: translation)
//        recognizer.setTranslation(CGPointZero, inView: self.view)
//        
//        if recognizer.state == .Ended {
//            axisChange = (.None, .None)
//        }
//    }
//    
//    func updateFrame(changes: (xOrigin: Int, yOrigin: Int, width: Int, height: Int), translation: CGPoint) {
//        let outOfBoundsBuffer = CGFloat(5)
//        let minimumSideLength = CGFloat(40)
//
//        
//        let imageCropperFrame = imageCropper.frame
//        
//        imageCropper.frame = newFrame
//        
//                var newFrame = CGRect()
//                newFrame.origin = CGPoint(x: newXOrigin, y: newYOrigin)
//                newFrame.size = CGSize(width: newWidth, height: newHeight)


        
//        let maximumWidth = currentImageFrame.width + (2 * outOfBoundsBuffer)
//        let maximumHeight = currentImageFrame.height + (2 * outOfBoundsBuffer)
//        
//        var newXOrigin = imageCropperFrame.origin.x + (CGFloat(changes.xOrigin) * translation.x)
//        
//        if newXOrigin < currentImageFrame.minX - outOfBoundsBuffer {
//            newXOrigin = currentImageFrame.minX - outOfBoundsBuffer
//        }
//        
//        if newXOrigin  > (currentImage.frame.maxX + outOfBoundsBuffer) {
//            frame.origin.x = frame.origin.x - (frame.maxX - (currentImage.frame.maxX + outOfBoundsBuffer))
//        }
//        
//        print("==========\nnewXOrigin is \(newXOrigin)")
//        
//        var newYOrigin = imageCropperFrame.origin.y + (CGFloat(changes.yOrigin) * translation.y)
//        
//        if newYOrigin < imageCropperFrame.minY - outOfBoundsBuffer {
//            newYOrigin = imageCropperFrame.minY - outOfBoundsBuffer
//        }
//        
//        print("===========\n---newXOrigin is \(newXOrigin)\n---newYOrigin is \(newYOrigin)")
//        
//        var newWidth = imageCropperFrame.width - (CGFloat(changes.width) * translation.x)
//        
//        if newWidth < minimumSideLength {
//            newWidth = minimumSideLength
//            
//            if (newXOrigin + newWidth) > (currentImageFrame.maxX + outOfBoundsBuffer) {
//                newXOrigin = (currentImageFrame.maxX + outOfBoundsBuffer) - newWidth
//            }
//        
//        } else if newWidth > maximumWidth {
//            newWidth = maximumWidth
//        }
//        
//        print("===========\n---newXOrigin is \(newXOrigin)\n---newYOrigin is \(newYOrigin)\n---newWidth is \(newWidth)")
//
//        
//        var newHeight = imageCropperFrame.height - (CGFloat(changes.height) * translation.y)
//        
//        if newHeight < minimumSideLength {
//            newHeight = minimumSideLength
//            
//            if (newYOrigin + newHeight) > (currentImageFrame.maxY + outOfBoundsBuffer) {
//                newYOrigin = (currentImageFrame.maxY + outOfBoundsBuffer) - newHeight
//            }
//            
//        } else if newHeight > maximumHeight {
//            newHeight = maximumHeight
//        }
//    
//        print("===========\n---newXOrigin is \(newXOrigin)\n---newYOrigin is \(newYOrigin)\n---newWidth is \(newWidth)\n---newHeight is \(newHeight)")
//        
        
        //checkFrameForMinimumSize(&newFrame)
        //checkFrameForOutOfBounds(&newFrame)

//    }
    
//    func checkFrameForMinimumSize(inout frame: CGRect) {
//        let minimumSideLength = CGFloat(40)
//        let outOfBoundsBuffer = CGFloat(5)
//        
//        if frame.width < minimumSideLength {
//            
//            frame.size.width = minimumSideLength
//            
//            if frame.minX < currentImageFrame.minX - outOfBoundsBuffer {
//                frame.origin.x = currentImageFrame.minX - outOfBoundsBuffer
//            }
//            
//            if frame.minY < currentImageFrame.minY - outOfBoundsBuffer {
//                frame.origin.y = currentImageFrame.minY - outOfBoundsBuffer
//            }
//            
//            if frame.maxX > currentImageFrame.maxX + outOfBoundsBuffer {
//                frame.origin.x = frame.minX - (currentImageFrame.maxX + outOfBoundsBuffer)
//            }
//            
//            if frame.maxY > currentImageFrame.maxY + outOfBoundsBuffer {
//                frame.origin.y = frame.minY - (currentImageFrame.maxY + outOfBoundsBuffer)
//            }
//        }
//        
//        if frame.height < minimumSideLength {
//            
//            frame.size.height = minimumSideLength
//            
//            if frame.minX < currentImageFrame.minX - outOfBoundsBuffer {
//                frame.origin.x = currentImageFrame.minX - outOfBoundsBuffer
//            }
//            
//            if frame.minY < currentImageFrame.minY - outOfBoundsBuffer {
//                frame.origin.y = currentImageFrame.minY - outOfBoundsBuffer
//            }
//            
//            if frame.maxX > currentImageFrame.maxX + outOfBoundsBuffer {
//                frame.origin.x = frame.minX - (currentImageFrame.maxX + outOfBoundsBuffer)
//            }
//            
//            if frame.maxY > currentImageFrame.maxY + outOfBoundsBuffer {
//                frame.origin.y = frame.minY - (currentImageFrame.maxY + outOfBoundsBuffer)
//            }
//        }
//        
//        if frame.minX < currentImageFrame.minX - outOfBoundsBuffer {
//            frame.origin.x = currentImageFrame.minX - outOfBoundsBuffer
//        }
//        if frame.maxX > currentImageFrame.maxX + outOfBoundsBuffer {
//            frame.size.width = frame.width - (frame.maxX - currentImageFrame.maxX) + outOfBoundsBuffer
//        }
//        if frame.minY < currentImageFrame.minY - outOfBoundsBuffer {
//            frame.origin.y = currentImageFrame.minY - outOfBoundsBuffer
//        }
//        if frame.maxY > currentImageFrame.maxY + outOfBoundsBuffer {
//            frame.size.height = frame.height - (frame.maxY - currentImageFrame.maxY) + outOfBoundsBuffer
//        }
//    }
//    
//    func checkFrameForOutOfBounds(inout frame: CGRect) {
//
//        let outOfBoundsBuffer = CGFloat(5)
//        
//        if frame.minX < currentImageFrame.minX - outOfBoundsBuffer {
//            frame.origin.x = currentImageFrame.minX - outOfBoundsBuffer
//        }
//        if frame.maxX > currentImageFrame.maxX + outOfBoundsBuffer {
//            frame.size.width = frame.width - (frame.maxX - currentImageFrame.maxX) + outOfBoundsBuffer
//        }
//        if frame.minY < currentImageFrame.minY - outOfBoundsBuffer {
//            frame.origin.y = currentImageFrame.minY - outOfBoundsBuffer
//        }
//        if frame.maxY > currentImageFrame.maxY + outOfBoundsBuffer {
//            frame.size.height = frame.height - (frame.maxY - currentImageFrame.maxY) + outOfBoundsBuffer
//        }
//    }
