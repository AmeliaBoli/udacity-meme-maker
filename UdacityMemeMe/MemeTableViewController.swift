  //
//  MemeTableViewController.swift
//  UdacityMemeMe
//
//  Created by Amelia Boli on 6/23/16.
//  Copyright © 2016 Amelia Boli. All rights reserved.
//

import UIKit

class MemeTableViewController: UITableViewController {

    //@IBOutlet weak var noMemesLabel: UILabel!
    
    var noMemesLabel = UILabel()
    var memes: [Meme] {
        return (UIApplication.sharedApplication().delegate as! AppDelegate).memes
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func viewWillAppear(animated: Bool) {
        tableView.reloadData()
        
        if memes.count == 0 {
            let backgroundView = UIView()
            let noMemesLabel = UILabel()
            noMemesLabel.text = "Your Memes Here"
            noMemesLabel.sizeToFit()
            backgroundView.addSubview(noMemesLabel)
            tableView.backgroundView = backgroundView
            
            noMemesLabel.translatesAutoresizingMaskIntoConstraints = false
            noMemesLabel.centerXAnchor.constraintEqualToAnchor(noMemesLabel.superview?.centerXAnchor).active = true
            noMemesLabel.centerYAnchor.constraintEqualToAnchor(noMemesLabel.superview?.centerYAnchor).active = true

        } else {
            tableView.backgroundView!.hidden = true
        }
    }
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return memes.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("memeCell", forIndexPath: indexPath) as! TableViewCell

        // Configure the cell...
        let meme = memes[indexPath.row]
        cell.thumbnailImage.image = meme.memedImage
        cell.memeText.text = meme.topText + "..." + meme.bottomText
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 100
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let detailController = self.storyboard!.instantiateViewControllerWithIdentifier("memeDetails") as! MemeDetailViewController
        detailController.imageToDisplay = memes[indexPath.item].memedImage
        self.navigationController!.pushViewController(detailController, animated: true)
    }
}
