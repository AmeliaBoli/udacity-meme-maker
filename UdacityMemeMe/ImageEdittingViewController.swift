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
    let minimumSideLength = CGFloat(40)

    var cropperXOffset = CGFloat(0)
    var cropperYOffset = CGFloat(0)

    var currentImageFrame = CGRect()
    var resizedImageFrame = CGRect()

    override func viewDidLoad() {
        super.viewDidLoad()
        imageToEdit.image = image
        maskedImage.image = image

        panGesture.delegate = self

        // I did not know that setting imageCropper to be the maskView of imageToEdit made imageCropper a subview of imageToEdit. I ended up posting this StackOverflow question as well as asking my local developer group. Based on the input from both, I figured out how to adjust the logic to make the frame appear where I wanted it. http://stackoverflow.com/questions/37517294/uiview-as-maskview-origin-shifted-by-constraint-constants/37519941#37519941
        imageToEdit.maskView = imageCropper

        imageCropper.frame = imageToEdit.bounds
        imageCropperBorder.frame = imageToEdit.frame

        imageCropperBorder.layer.borderColor = UIColor.whiteColor().CGColor
        imageCropperBorder.layer.borderWidth = 1
    }

    override func viewDidLayoutSubviews() {
        if let imageFrame = imageToEdit.resizedFrame {

            resizedImageFrame = imageFrame
            currentImageFrame = resizedImageFrame

            imageCropperBorder.frame = resizedImageFrame
            addCornerHandles(imageCropperBorder.bounds)

            imageCropper.frame = CGRectOffset(resizedImageFrame, -imageToEdit.frame.origin.x, -imageToEdit.frame.origin.y)
        }
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }

    // I used an answer on the following StackOverflow post as a jumping point for how I added the handles to the cropping view. http://stackoverflow.com/questions/17355280/how-to-add-a-border-just-on-the-top-side-of-a-uiview
    func addCornerHandles(bounds: CGRect) {

        if let sublayers = imageCropperBorder.layer.sublayers {
            for layer in sublayers {
                layer.removeFromSuperlayer()
            }
        }

        let frameOffset = CGFloat(2)

        let horizontalSize = CGSize(width: 22, height: 2)
        let verticalSize = CGSize(width: 2, height: 22)

        let leftX = CGFloat(bounds.origin.x - frameOffset)
        let rightHorizontalX = CGFloat(bounds.maxX - horizontalSize.width + frameOffset)
        let rightVerticalX = CGFloat(bounds.maxX)

        let topY = CGFloat(bounds.origin.y - frameOffset)
        let bottomHorizontalY = CGFloat(bounds.maxY)
        let bottomVerticalY = CGFloat(bounds.maxY - verticalSize.height + frameOffset)

        let backgroundColor = UIColor.whiteColor().CGColor

        // Used Natasha The Robot's post about configuring constants with shorthand names  as my pattern below. https://www.natashatherobot.com/swift-configuring-a-constant-using-shorthand-argument-names/
        let topLeft: CALayer = {
            $0.backgroundColor = backgroundColor
            $0.frame = CGRect(origin: CGPoint(x: leftX, y: topY), size: horizontalSize)
            return $0
        } (CALayer())
        imageCropperBorder.layer.addSublayer(topLeft)

        let topRight: CALayer = {
            $0.backgroundColor = backgroundColor
            $0.frame = CGRect(origin: CGPoint(x: rightHorizontalX, y: topY), size: horizontalSize)
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
            $0.frame = CGRect(origin: CGPoint(x: rightHorizontalX, y: bottomHorizontalY), size: horizontalSize)
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
            $0.frame = CGRect(origin: CGPoint(x: leftX, y: bottomVerticalY), size: verticalSize)
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
            $0.frame = CGRect(origin: CGPoint(x: rightVerticalX, y: bottomVerticalY), size: verticalSize)
            return $0
        } (CALayer())
        imageCropperBorder.layer.addSublayer(rightBottom)
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

    @IBAction func handlePan(recognizer: UIPanGestureRecognizer) {

        if recognizer.state == .Began || recognizer.state == .Changed {

            let translation = recognizer.translationInView(view)
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
            imageCropperBorder.frame = CGRectOffset(currentFrame, imageToEdit.frame.origin.x, imageToEdit.frame.origin.y)
            addCornerHandles(imageCropperBorder.bounds)

            recognizer.setTranslation(CGPointZero, inView: view)
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

        var scale = CGFloat(1)

        var imageToCrop = UIImage()

        if let image = imageToEdit.image {
            scale = image.size.width / currentImageFrame.size.width
            imageToCrop = image
        } else {
            print("Error")
        }

        let xRelativeToImage = (croppingFrame.origin.x + imageToEdit.frame.origin.x) - currentImageFrame.origin.x
        let yRelativeToImage = (croppingFrame.origin.y + imageToEdit.frame.origin.y) - currentImageFrame.origin.y

        var newX = scale * xRelativeToImage
        var newY = scale * yRelativeToImage

        var newWidth = scale * croppingFrame.width
        var newHeight = scale * croppingFrame.height

        if imageToEdit.image?.imageOrientation == .Right {
            newX = scale * yRelativeToImage
            newY = scale * (currentImageFrame.maxX - (croppingFrame.maxX + imageToEdit.frame.minX))
            newWidth = scale * croppingFrame.height
            newHeight = scale * croppingFrame.width
            orientationToSet = .Right
        }

        let newOrigin = CGPoint(x: newX, y: newY)
        let newSize = CGSize(width: newWidth, height: newHeight)
        let newFrame = CGRect(origin: newOrigin, size: newSize)

        let croppedUIImage: UIImage
        let croppableImage = imageToCrop.CGImage

        if let croppedImage = CGImageCreateWithImageInRect(croppableImage, newFrame) {
            croppedUIImage = UIImage(CGImage: croppedImage, scale: 1, orientation: orientationToSet)
        } else {
            croppedUIImage = image
        }

        imageToEdit.image = croppedUIImage
        maskedImage.image = croppedUIImage
    }
 }
