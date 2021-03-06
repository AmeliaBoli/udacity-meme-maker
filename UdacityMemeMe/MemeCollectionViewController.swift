//
//  MemeCollectionViewController.swift
//  UdacityMemeMe
//
//  Created by Amelia Boli on 6/23/16.
//  Copyright © 2016 Amelia Boli. All rights reserved.
//

import UIKit

private let reuseIdentifier = "memeGridItem"

class MemeCollectionViewController: UICollectionViewController {

    @IBOutlet weak var noMemsLabel: UILabel!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!

    let cellSpacing = CGFloat(5)

    var memes: [Meme] {
        return (UIApplication.sharedApplication().delegate as! AppDelegate).memes
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        flowLayout.minimumLineSpacing = cellSpacing
        flowLayout.minimumInteritemSpacing = cellSpacing
    }

    override func viewWillLayoutSubviews() {
        let imageSideLength: CGFloat
        let screenSize = UIScreen.mainScreen().bounds.size

        if screenSize.height > screenSize.width {
            imageSideLength = (view.frame.width - (2 * cellSpacing)) / 3
        } else {
            imageSideLength = (view.frame.width - (4 * cellSpacing)) / 5
        }

         flowLayout.itemSize = CGSize(width: imageSideLength, height: imageSideLength)
    }

    override func viewWillAppear(animated: Bool) {
        collectionView?.reloadData()
        if memes.count > 0 {
            noMemsLabel.hidden = true
        }
    }

    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return memes.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! MemeCollectionViewCell
        cell.memeImage.image = memes[indexPath.item].memedImage
        return cell
    }

    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {

        guard let storyboard = storyboard else {
            return
        }

        guard let navigationController = navigationController else {
            return
        }

        let detailController = storyboard.instantiateViewControllerWithIdentifier("memeDetails") as! MemeDetailViewController
        detailController.meme = memes[indexPath.item]
        detailController.index = indexPath.item
        navigationController.pushViewController(detailController, animated: true)
    }
}
