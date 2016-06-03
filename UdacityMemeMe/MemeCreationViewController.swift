//
//  MemeCreationViewController.swift
//  ImagePickerSample
//
//  Created by Amelia Boli on 4/14/16.
//  Copyright © 2016 Amelia Boli. All rights reserved.
//

import UIKit

class MemeCreationViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {

    @IBOutlet var pickedImage: UIImageView!
    // Friend suggested that I add some text to indicate that a picked photo would appear in the middle of the view
    @IBOutlet var imagePlaceholderText: UILabel!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var topNavigationBar: UINavigationBar!
    @IBOutlet weak var bottomToolbar: UIToolbar!
    @IBOutlet weak var cropButton: UIBarButtonItem!
    // Friend suggested that the cancel button be called "clear" for clarity from a UX perspective
    @IBOutlet weak var clearButton: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()
        topTextField.text = "TOP"
        bottomTextField.text = "BOTTOM"
       
        setFont(topTextField, title: "Helvetica Neue")
        setFont(bottomTextField, title: "Helvetica Neue")
       
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
    
    // Added programmatic capitalization after suggestion from Udacity reviewer
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {

        let capitalizedString = string.uppercaseString

        if string != capitalizedString {
            if let currentText = textField.text {
                textField.text = currentText + capitalizedString
            } else {
                textField.text = string.capitalizedString
            }
            return false
        } else {
            return true
        }
    }
    
    // From UITextFieldDelegate Protocol- called when user presses keyboard's return button
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    @IBAction func pickFont(sender: UIBarButtonItem!) {
        let fontView = UIAlertController(title: "Fonts", message: nil, preferredStyle: .ActionSheet)

        //While sharing my progress with someone, they recommended that I add a message in order to make the alert clearer.
        fontView.message = "Select a New Font"

        let setAmericanTypewriter = UIAlertAction(title: "American Typewriter", style: .Default) {action in
            if let title = action.title {
                self.setFont(self.topTextField, title: title)
                self.setFont(self.bottomTextField, title: title)
            }}
        let setBradleyHand = UIAlertAction(title: "Bradley Hand", style: .Default) {action in
            if let title = action.title {
                self.setFont(self.topTextField, title: title)
                self.setFont(self.bottomTextField, title: title)
            }}
        let setCopperplate = UIAlertAction(title: "Copperplate", style: .Default) {action in
            if let title = action.title {
                self.setFont(self.topTextField, title: title)
                self.setFont(self.bottomTextField, title: title)
            }}
        let setHelvetica = UIAlertAction(title: "Helvetica Neue", style: .Default) {action in
            if let title = action.title {
                self.setFont(self.topTextField, title: title)
                self.setFont(self.bottomTextField, title: title)
            }}
        let cancel = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        fontView.addAction(setAmericanTypewriter)
        fontView.addAction(setBradleyHand)
        fontView.addAction(setCopperplate)
        fontView.addAction(setHelvetica)
        fontView.addAction(cancel)
        
        presentViewController(fontView, animated: true, completion: nil)
    }
    
    // Abstracted the code below into this function after a suggestion from a Udacity reviewer
    func setFont(textField: UITextField, title: String) {
        
        var newFont = UIFont()

        switch title {
        case "American Typewriter": newFont = UIFont(name: "AmericanTypewriter-CondensedBold", size: 40)!
        case "Bradley Hand": newFont = UIFont(name: "BradleyHandITCTT-Bold", size: 50)!
        case "Copperplate": newFont = UIFont(name: "Copperplate-Bold", size: 40)!
        case "Helvetica Neue": newFont = UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!
        default: newFont = UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!
        }
        
        var memeTextAttributes = [
            NSStrokeColorAttributeName: UIColor.blackColor(),
            NSForegroundColorAttributeName: UIColor.whiteColor(),
            NSFontAttributeName: newFont,
            NSStrokeWidthAttributeName: -3.0
        ]

        memeTextAttributes[NSFontAttributeName] = newFont
        
        textField.defaultTextAttributes = memeTextAttributes
        textField.textAlignment = .Center
    }

    // Image Picker Configuration
    @IBAction func pickImage(sender: UIBarButtonItem) {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.sourceType = .PhotoLibrary
        presentViewController(pickerController, animated: true, completion: nil)
    }

    @IBAction func takeImageWithCamera(sender: UIBarButtonItem) {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.sourceType = .Camera
        pickerController.view.layoutIfNeeded()
        presentViewController(pickerController, animated: true, completion: nil)
    }

    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: AnyObject]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            pickedImage.image = image
            shareButton.enabled = true
            cropButton.enabled = true
            // Friend suggested that the clear button only been enabled once something in the view has been changed by the user
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

    // Adjusted view moving logic to account for custom keyboards after a suggestion from a Udacity reviewer
    func keyboardWillShow(notification: NSNotification) {
        if bottomTextField.isFirstResponder() {
            view.frame.origin.y = -getKeyboardHeight(notification)
        }
    }

    // Simplified view moving logic after a suggestion from a Udacity reviewer
    func keyboardWillHide(notification: NSNotification) {
        view.frame.origin.y = 0
    }

    func subscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MemeCreationViewController.keyboardWillShow), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MemeCreationViewController.keyboardWillHide), name: UIKeyboardWillHideNotification, object: nil)
    }

    func unsubscribeFromKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name:
            UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }

    // Source for code: http://stackoverflow.com/questions/24126678/close-ios-keyboard-by-touching-anywhere-using-swift
    @IBAction func dismissKeyboardOnTap(sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }

    // Sharing and saving a meme
    struct Meme {
        let topText: String
        let bottomText: String
        let image: UIImage
        let memedImage: UIImage
    }

    // It was shared with me that you should try to never deploy an app with warnings. However, I'm assuming we are going to do something specific with this object in v2.
    func saveMeme(memedImage: UIImage) {
        let meme = Meme(topText: topTextField.text!, bottomText: bottomTextField.text!, image:
            pickedImage.image!, memedImage: memedImage)
    }

    func generateMemedImage() -> UIImage {
        topNavigationBar.hidden = true
        bottomToolbar.hidden = true

        UIGraphicsBeginImageContext(view.frame.size)
        view.drawViewHierarchyInRect(view.frame, afterScreenUpdates: true)
        let memedImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        topNavigationBar.hidden = false
        bottomToolbar.hidden = false

        return memedImage
    }
    
    @IBAction func shareMeme(sender: UIBarButtonItem) {
        let memedImage = generateMemedImage()
        let activityView = UIActivityViewController(activityItems: [memedImage], applicationActivities: nil)
        presentViewController(activityView, animated: true, completion: nil)

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
        setFont(topTextField, title: "Helvetica Neue")
        setFont(bottomTextField, title: "Helvetica Neue")
        imagePlaceholderText.hidden = false
    }

    // Transition Management
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "editImage" {
            let controller = segue.destinationViewController as! ImageEdittingViewController
            controller.image = pickedImage.image!
        }
    }

    @IBAction func prepareForUnwind(segue: UIStoryboardSegue){
        if segue.identifier == "done" {
            let sourceViewController = segue.sourceViewController as! ImageEdittingViewController
            pickedImage.image = sourceViewController.imageToEdit.image
        }
    }
}
