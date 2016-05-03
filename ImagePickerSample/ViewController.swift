//
//  ViewController.swift
//  ImagePickerSample
//
//  Created by Amelia Boli on 4/14/16.
//  Copyright © 2016 Amelia Boli. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {

    @IBOutlet weak var pickedImage: UIImageView!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var topNavigationBar: UINavigationBar!
    @IBOutlet weak var bottomToolbar: UIToolbar!
    
    let memeTextAttributes = [
        NSStrokeColorAttributeName : UIColor.blackColor(),
        NSForegroundColorAttributeName : UIColor.whiteColor(),
        NSFontAttributeName : UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
        NSStrokeWidthAttributeName : -3.0
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        topTextField.text = "TOP"
        bottomTextField.text = "BOTTOM"
        topTextField.defaultTextAttributes = memeTextAttributes
        bottomTextField.defaultTextAttributes = memeTextAttributes
        topTextField.textAlignment = .Center
        bottomTextField.textAlignment = .Center
        topTextField.delegate = self
        bottomTextField.delegate = self
        
        UIApplication.sharedApplication().statusBarHidden = true
        shareButton.enabled = false
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        cameraButton.enabled = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    // Text Field Configuration
    func textFieldDidBeginEditing(textField: UITextField) {
        if textField == topTextField && textField.text == "TOP" {
            textField.text = ""
        } else if textField == bottomTextField && textField.text == "BOTTOM" {
            textField.text = ""
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // Image Picker Configuration
    @IBAction func pickImage(sender: UIBarButtonItem) {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.sourceType = .PhotoLibrary
        self.presentViewController(pickerController, animated: true, completion: nil)
    }
    
    @IBAction func takeImageWithCamera(sender: UIBarButtonItem) {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.sourceType = .Camera
        pickerController.view.layoutIfNeeded()
        self.presentViewController(pickerController, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            pickedImage.image = image
            shareButton.enabled = true
        }
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // Keyboard Confirguration
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.CGRectValue().height
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if bottomTextField.isFirstResponder() {
            view.frame.origin.y -= getKeyboardHeight(notification)
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if bottomTextField.isFirstResponder() {
            view.frame.origin.y += getKeyboardHeight(notification)
        }
    }
    
    func subscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.keyboardWillShow), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.keyboardWillHide), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name:
            UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    // Sharing and saving a meme
    struct Meme {
        let topText: String
        let bottomText: String
        let image: UIImage
        let memedImage: UIImage
    }
    
    func saveMeme(memedImage: UIImage) {
        let meme = Meme(topText: topTextField.text!, bottomText: bottomTextField.text!, image:
            pickedImage.image!, memedImage: memedImage)
    }
    
    func generateMemedImage() -> UIImage
    {
        topNavigationBar.hidden = true
        bottomToolbar.hidden = true
        
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawViewHierarchyInRect(self.view.frame, afterScreenUpdates: true)
        let memedImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        topNavigationBar.hidden = false
        bottomToolbar.hidden = false
        
        return memedImage
    }
    
    @IBAction func shareMeme(sender: UIBarButtonItem) {
        let memedImage = generateMemedImage()
        let activityView = UIActivityViewController(activityItems: [memedImage], applicationActivities: nil)
        self.presentViewController(activityView, animated: true, completion: nil)
        
        // I needed help working out how to use completionWithItemsHandler. This StackOverflow post helped: http://stackoverflow.com/questions/28169192/uiactivityviewcontroller-completion-handler-returns-success-when-tweet-has-faile
        activityView.completionWithItemsHandler = {(activityType, completed, returnedItems, activityError) in
            if completed {self.saveMeme(memedImage)}
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    // Clear choices
    @IBAction func cancelPressed(sender: UIBarButtonItem) {
        topTextField.text = "TOP"
        bottomTextField.text = "BOTTOM"
        pickedImage.image = nil
        shareButton.enabled = false
    }
}

