//
//  MemeCreationViewController.swift
//  ImagePickerSample
//
//  Created by Amelia Boli on 4/14/16.
//  Copyright © 2016 Amelia Boli. All rights reserved.
//

import UIKit

class MemeCreationViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

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
    @IBOutlet weak var doneButton: UIBarButtonItem!
    @IBOutlet var saveChangesButton: UIBarButtonItem!
    @IBOutlet weak var navigationBar: UINavigationBar!

    let textToFrameBuffer = CGFloat(20)
    var currentFont = "Helvetica Neue"

    var meme: Meme?
    var index = 0
    var editingMeme = false

    override func viewDidLoad() {
        super.viewDidLoad()

        if editingMeme {
            if let meme = meme {
                topTextField.text = meme.topText
                bottomTextField.text = meme.bottomText

                pickedImage.image = meme.image

                currentFont = meme.fontTitle
            }

            setFont(topTextField, title: currentFont)
            setFont(bottomTextField, title: currentFont)

            doneButton.title = "Cancel"
            shareButton.enabled = true
            cropButton.enabled = true
            clearButton.enabled = true

            // I started with the code in an answer on this StackOverflow post to show/hide the saveChanges button. http://stackoverflow.com/questions/10021748/how-do-i-show-hide-a-uibarbuttonitem
            if var toolbarButtons = navigationBar.topItem?.leftBarButtonItems {
                if !toolbarButtons.contains(saveChangesButton) {
                    toolbarButtons.append(saveChangesButton)
                    navigationBar.topItem?.leftBarButtonItems = toolbarButtons
                }
            }
        } else {
            topTextField.text = "TOP"
            bottomTextField.text = "BOTTOM"

            currentFont = "Helvetica Neue"

            setFont(topTextField, title: "Helvetica Neue")
            setFont(bottomTextField, title: "Helvetica Neue")

            doneButton.title = "Done"
            shareButton.enabled = false
            cropButton.enabled = false
            clearButton.enabled = false

            if var toolbarButtons = navigationBar.topItem?.leftBarButtonItems {
                if let index = toolbarButtons.indexOf(saveChangesButton) {
                    toolbarButtons.removeAtIndex(index)
                    navigationBar.topItem?.leftBarButtonItems = toolbarButtons
                }
            }
        }

        topTextField.delegate = self
        bottomTextField.delegate = self

        UIApplication.sharedApplication().statusBarHidden = true
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        cameraButton.enabled = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)
        subscribeToKeyboardNotifications()
    }

    // Added code to move the text fields based on the image's location after resizing based on the recomendation of the Udacity reviewer
    override func viewDidLayoutSubviews() {
        guard let imageFrame = pickedImage.resizedFrame else {
            return
        }

        if imageFrame.height <= (topTextField.frame.height + bottomTextField.frame.height + (2 * textToFrameBuffer)) {
            topTextField.frame.origin = CGPoint(x: topTextField.frame.origin.x, y: imageFrame.origin.y - topTextField.frame.height)
            bottomTextField.frame.origin = CGPoint(x: bottomTextField.frame.origin.x, y: imageFrame.maxY)

        } else {
            if topTextField.frame.minY < imageFrame.minY {
                topTextField.frame.origin = CGPoint(x: topTextField.frame.origin.x, y: imageFrame.origin.y + textToFrameBuffer)
            }

            if bottomTextField.frame.maxY > imageFrame.maxY {
                bottomTextField.frame.origin = CGPoint(x: bottomTextField.frame.origin.x, y: imageFrame.maxY - bottomTextField.frame.height - textToFrameBuffer)
            }
        }
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
        editingMeme = false
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }

    func makeAlertAction(title: String) -> UIAlertAction {
        let alertAction = UIAlertAction(title: title, style: .Default) {action in
            if let title = action.title {
                self.setFont(self.topTextField, title: title)
                self.setFont(self.bottomTextField, title: title)
            }}
        return alertAction
    }
    
    @IBAction func pickFont(sender: UIBarButtonItem!) {
        let fontView = UIAlertController(title: "Fonts", message: nil, preferredStyle: .ActionSheet)

        //While sharing my progress with someone, they recommended that I add a message in order to make the alert clearer.
        fontView.message = "Select a New Font"

        let setAmericanTypewriter = makeAlertAction("American Typewriter")
        let setBradleyHand = makeAlertAction("Bradley Hand")
        let setCopperplate = makeAlertAction("Copperplate")
        let setHelvetica = makeAlertAction("Helvetica Neue")
        
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

        currentFont = title

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

    func presentImagePicker(sourceType: UIImagePickerControllerSourceType) {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.sourceType = sourceType
        pickerController.view.layoutIfNeeded()
        presentViewController(pickerController, animated: true, completion: nil)
    }
    
    // Image Picker Configuration
    @IBAction func pickImage(sender: UIBarButtonItem) {
       presentImagePicker(.PhotoLibrary)
    }

    @IBAction func takeImageWithCamera(sender: UIBarButtonItem) {
      presentImagePicker(.Camera)
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

        guard let userInfo = notification.userInfo else {
            return 0
        }

        let keyboardSize = userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
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

    func saveMeme(memedImage: UIImage) {
        let meme = Meme(topText: topTextField.text!, bottomText: bottomTextField.text!, fontTitle: currentFont, image:
            pickedImage.image!, memedImage: memedImage)
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate

        if !editingMeme {
            appDelegate.memes.append(meme)
        } else {
            appDelegate.memes[index] = meme
        }

        self.meme = meme
    }

    func generateMemedImage() -> UIImage {
        topNavigationBar.hidden = true
        bottomToolbar.hidden = true

        var imageFrame = view.frame
        if let frame = pickedImage.resizedFrame {
            imageFrame = frame
        }

        if topTextField.frame.minY < imageFrame.minY {
            imageFrame = CGRectOffset(imageFrame, 0, -topTextField.frame.height)
            imageFrame.size.height += topTextField.frame.height + bottomTextField.frame.height
        }

        UIGraphicsBeginImageContext(imageFrame.size)
        let frameToDraw = CGRect(origin: CGPoint(x: -imageFrame.origin.x, y: -imageFrame.origin.y), size: view.frame.size)
        view.drawViewHierarchyInRect(frameToDraw, afterScreenUpdates: true)
        let memedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        topNavigationBar.hidden = false
        bottomToolbar.hidden = false

        return memedImage
    }

    func saveChanges() {
        let memedImage = generateMemedImage()
        saveMeme(memedImage)
    }

    @IBAction func shareMeme(sender: UIBarButtonItem) {
        let memedImage = generateMemedImage()
        let activityView = UIActivityViewController(activityItems: [memedImage], applicationActivities: nil)
        presentViewController(activityView, animated: true, completion: nil)

        // I needed help working out how to use completionWithItemsHandler. This StackOverflow post helped: http://stackoverflow.com/questions/28169192/uiactivityviewcontroller-completion-handler-returns-success-when-tweet-has-faile
        activityView.completionWithItemsHandler = {(activityType, completed, returnedItems, activityError) in
            if completed {self.saveMeme(memedImage)}
            // I did not feel that dismissing the shareController and going straight back to savedMemes view seemed natural. So I commented out this dismiss.
            //self.dismissViewControllerAnimated(true, completion: nil)
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

            if let image = pickedImage.image {
                controller.image = image
            }
        } else if segue.identifier == "saveChanges" {
            saveChanges()
        }
    }

    @IBAction func prepareForUnwind(segue: UIStoryboardSegue){
        if segue.identifier == "done" {
            let sourceViewController = segue.sourceViewController as! ImageEdittingViewController
            pickedImage.image = sourceViewController.imageToEdit.image
        }
    }

    @IBAction func dismissViewController(sender: UIBarButtonItem) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}
