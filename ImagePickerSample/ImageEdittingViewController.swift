//
//  ImageEdittingViewController.swift
//  ImagePickerSample
//
//  Created by Amelia Boli on 5/19/16.
//  Copyright © 2016 Amelia Boli. All rights reserved.
//

import UIKit
import AVFoundation

class ImageEdittingViewController: UIViewController {

    @IBOutlet weak var imageToEdit: UIImageView!
    @IBOutlet weak var imageCropper: UIView!
    
    var image = UIImage()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageToEdit.image = image
        imageCropper.layer.borderWidth = 1.0
        imageCropper.layer.borderColor = UIColor.whiteColor().CGColor
//        let resizedImageFrame = AVMakeRectWithAspectRatioInsideRect(imageToEdit.image!.size, imageToEdit.bounds)
//        imageCropper.Frame = resizedImageFrame
//        print(resizedImageFrame)
//        imageCropper.layer.frame = CGRect(origin: imageCropper.layer.frame.origin, size: imageToEdit.image!.size)
//        print("test")
        // Do any additional setup after loading the view.
        //print(imageToEdit.frame)
    }

//    override func viewWillAppear(animated: Bool) {
//        super.viewWillAppear(true)
//        print(imageToEdit.frame)
//        //imageCropper.layer.frame.size = imageToEdit.image!.size
//        let resizedImageFrame = AVMakeRectWithAspectRatioInsideRect(imageToEdit.image!.size, imageToEdit.bounds)
//        imageCropper.frame = resizedImageFrame
//        print(resizedImageFrame)
//    }
    
    //AVMakeRectWithAspect
    
//    override func viewDidAppear(animated: Bool) {
//        super.viewDidAppear(false)
//        print(imageToEdit.frame)
//        print(imageToEdit.image!.size)
//        let resizedImageFrame = AVMakeRectWithAspectRatioInsideRect(imageToEdit.image!.size, imageoToEdit.bounds)
//        imageCropper.frame = resizedImageFrame
//        print(resizedImageFrame)
//
//    }
    
    override func viewDidLayoutSubviews() {
        var resizedImageFrame = AVMakeRectWithAspectRatioInsideRect(imageToEdit.image!.size, imageToEdit.bounds)
        let resizedImageCenter = imageToEdit.center
        let resizedImageX = resizedImageCenter.x - (resizedImageFrame.width / 2)
        let resizedImageY = resizedImageCenter.y - (resizedImageFrame.height / 2)
        resizedImageFrame.origin = CGPoint(x: resizedImageX, y: resizedImageY)
        //resizedImageFrame.origin = (imageToEdit)
//        let xOffset = imageToEdit.constraints
//        
//        for constraint in xOffset {
//            print(constraint.constant)
//        }
        imageCropper.frame = resizedImageFrame
//        print(resizedImageFrame)
        //updateViewConstraints()
        print(imageToEdit.frame)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
