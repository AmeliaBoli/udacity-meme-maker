//
//  HandleView.swift
//  ImagePickerSample
//
//  Created by Amelia Boli on 6/1/16.
//  Copyright © 2016 Amelia Boli. All rights reserved.
//

import UIKit

@IBDesignable
class HandleView: UIView {

    @IBInspectable var borderColor = UIColor.whiteColor()
    @IBInspectable var borderWidth: CGFloat = 1
    
    override func drawRect(rect: CGRect) {
        layer.borderColor = borderColor.CGColor
        layer.borderWidth = borderWidth
    }
 }
