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

    var meme: Meme?
    var index = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        if let memedImage = meme?.memedImage {
            memeImage.image = memedImage
        }
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let creationController = segue.destinationViewController as! MemeCreationViewController
        creationController.meme = meme
        creationController.index = index
        creationController.editingMeme = true
    }

    func didFinishTask(sender: MemeCreationViewController) {
        meme = sender.meme
        memeImage.image = meme?.memedImage
    }

    @IBAction func prepareForUnwind(segue: UIStoryboardSegue) {
        if segue.identifier == "saveChanges" {
            let sourceViewController = segue.sourceViewController as! MemeCreationViewController
            meme = sourceViewController.meme
            memeImage.image = meme?.memedImage
        }
    }

    override func prefersStatusBarHidden() -> Bool {
        return false
    }
}
