//
//  MemeDetailViewController.swift
//  UdacityMemeMe
//
//  Created by Amelia Boli on 6/23/16.
//  Copyright © 2016 Amelia Boli. All rights reserved.
//

import UIKit

class MemeDetailViewController: UIViewController {

    @IBOutlet weak var memeImage: UIImageView!
    var imageToDisplay = UIImage()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        memeImage.image = imageToDisplay
    }
}
