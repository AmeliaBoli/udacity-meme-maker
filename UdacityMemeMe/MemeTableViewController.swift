//
//  MemeTableViewController.swift
//  UdacityMemeMe
//
//  Created by Amelia Boli on 6/23/16.
//  Copyright © 2016 Amelia Boli. All rights reserved.
//

import UIKit

class MemeTableViewController: UITableViewController {

    var noMemesLabel = UILabel()
    var memes: [Meme] {
        return (UIApplication.sharedApplication().delegate as! AppDelegate).memes
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        //tableView.editing = true
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
            if let backgroundView = tableView.backgroundView {
                backgroundView.hidden = true
            }
        }
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return memes.count
    }


    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("memeCell", forIndexPath: indexPath) as! TableViewCell

        // Configure the cell
        let meme = memes[indexPath.row]
        cell.thumbnailImage.image = meme.memedImage
        cell.memeText.text = meme.topText + "..." + meme.bottomText
        return cell
    }

    // MARK: - Table view delegate methods

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

        guard let storyboard = storyboard else {
            return
        }

        guard let navigationController = navigationController else {
            return
        }

        let detailController = storyboard.instantiateViewControllerWithIdentifier("memeDetails") as! MemeDetailViewController
        detailController.meme = memes[indexPath.row]
        detailController.index = indexPath.row
        navigationController.pushViewController(detailController, animated: true)
    }

    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: UITableViewRowActionStyle.Destructive, title: "Delete") { (delete, indexPath) in

            (UIApplication.sharedApplication().delegate as! AppDelegate).memes.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Top)
        }
        return [deleteAction]
    }
}
