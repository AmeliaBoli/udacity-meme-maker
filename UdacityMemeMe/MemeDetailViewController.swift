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

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
