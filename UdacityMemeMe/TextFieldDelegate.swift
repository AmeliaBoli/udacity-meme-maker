//
//  TextFieldDelegate.swift
//  UdacityMemeMe
//
//  Created by Amelia Boli on 7/1/16.
//  Copyright © 2016 Amelia Boli. All rights reserved.
//

import UIKit

// TextFieldDelegate code moved to sepearte file after Udacity reviewer's suggestion.
extension MemeCreationViewController: UITextFieldDelegate {
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
}
