//
//  ViewController.swift
//  ImagePickerSample
//
//  Created by Amelia Boli on 4/14/16.
//  Copyright © 2016 Amelia Boli. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {

    @IBOutlet var pickedImage: UIImageView!
    @IBOutlet var imagePlaceholderText: UILabel!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var topNavigationBar: UINavigationBar!
    @IBOutlet weak var bottomToolbar: UIToolbar!
    @IBOutlet weak var cropButton: UIBarButtonItem!
    @IBOutlet weak var clearButton: UIBarButtonItem!
    
    var memeTextAttributes = [
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
        cropButton.enabled = false
        clearButton.enabled = false
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
    
    func textFieldDidEndEditing(textField: UITextField) {
        if topTextField.text != "TOP" || bottomTextField.text != "BOTTOM" {
            clearButton.enabled = true
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func pickFont(sender: UIBarButtonItem!) {
        let fontView = UIAlertController(title: "Fonts", message: nil, preferredStyle: .ActionSheet)
        
        //While sharing my progress with someone, they recommended that I add a message in order to make the alert clearer.
        fontView.message = "Select a New Font"
        
        let setAmericanTypewriter = UIAlertAction(title: "American Typewriter", style: .Default) {action in
            let title = action.title!
            self.changeFont(title)}
        let setBradleyHand = UIAlertAction(title: "Bradley Hand", style: .Default) {action in
            let title = action.title!
            self.changeFont(title)}
        let setCopperplate = UIAlertAction(title: "Copperplate", style: .Default) {action in
            let title = action.title!
            self.changeFont(title)}
        let setHelvetica = UIAlertAction(title: "Helvetica Neue", style: .Default) {action in
            let title = action.title!
            self.changeFont(title)}
        let cancel = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        fontView.addAction(setAmericanTypewriter)
        fontView.addAction(setBradleyHand)
        fontView.addAction(setCopperplate)
        fontView.addAction(setHelvetica)
        fontView.addAction(cancel)
        
        presentViewController(fontView, animated: true, completion: nil)
    }
    
    func changeFont(title: String) {
        let newFont: UIFont
        switch title {
        case "American Typewriter": newFont = UIFont(name: "AmericanTypewriter-CondensedBold", size: 40)!
        case "Bradley Hand": newFont = UIFont(name: "BradleyHandITCTT-Bold", size: 50)!
        case "Copperplate": newFont = UIFont(name: "Copperplate-Bold", size: 40)!
        case "Helvetica Neue": newFont = UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!
            
        default: newFont = UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!
        }
        memeTextAttributes[NSFontAttributeName] = newFont
        topTextField.defaultTextAttributes = memeTextAttributes
        bottomTextField.defaultTextAttributes = memeTextAttributes
        topTextField.textAlignment = .Center
        bottomTextField.textAlignment = .Center
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
            cropButton.enabled = true
            clearButton.enabled = true
            imagePlaceholderText.hidden = true
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
        cropButton.enabled = false
        clearButton.enabled = false
        changeFont("Helvetica Neue")
        imagePlaceholderText.hidden = false
    }
    
    // Transition Management
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "editImage" {
            let controller = segue.destinationViewController as! ImageEdittingViewController
            controller.image = self.pickedImage.image!
        }
    }
    
    @IBAction func prepareForUnwind(segue: UIStoryboardSegue){
        if segue.identifier == "done" {
            let sourceViewController = segue.sourceViewController as! ImageEdittingViewController
            self.pickedImage.image = sourceViewController.imageToEdit.image
        }
    }
}

