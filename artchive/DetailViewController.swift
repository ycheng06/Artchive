//
//  DetailViewController.swift
//  artchive
//
//  Created by Jason Cheng on 1/10/15.
//  Copyright (c) 2015 oceanapart. All rights reserved.
//

import UIKit
import Photos
import CoreData

class DetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var artworkImageView: UIImageView!
    var artwork: Artwork!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        // Get an instance of PHImageManager
        let imageManager = PHImageManager.defaultManager()
        
        // Use the stored local identifer to fetch PHAsset
        let localIdentifier:String = artwork.imgRef
        let fetchResult:PHFetchResult = PHAsset.fetchAssetsWithLocalIdentifiers([localIdentifier], options: nil)

        // Give the PHAsset to image manger to create create
        if (fetchResult.count > 0){
            let asset:PHAsset = fetchResult.firstObject as PHAsset
            imageManager.requestImageForAsset(asset, targetSize: CGSize(width:140, height:140), contentMode: .AspectFill, options: nil, resultHandler: { (result, info) in
                self.artworkImageView.image = result
            })
        }
        
        
//        tableView.estimatedRowHeight = 36.0
//        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.hidesBarsOnSwipe = false
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("DetailTableViewCell", forIndexPath: indexPath) as DetailTableViewCell

        //Configure the cell
        switch indexPath.row {
        case 0:
            cell.fieldLabel.text = "Title"
            cell.valueLabel.text = artwork.title
        case 1:
            cell.fieldLabel.text = "Artist"
//            cell.valueLabel.text = restaurant.type
        case 2:
            cell.fieldLabel.text = "Location"
//            cell.valueLabel.text = restaurant.location
        case 3:
            cell.fieldLabel.text = "Year"
//            cell.valueLabel.text = (restaurant.isVisited.boolValue) ? "Yes, I’ve been here before" : "No"
        default:
            cell.fieldLabel.text = ""
            cell.valueLabel.text = ""
        }
        
        return cell
    }
}
