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
        // Get an instance of PHImageManager
        let imageManager = PHImageManager.defaultManager()
        
        // Use the stored local identifer to fetch PHAsset
        let localIdentifier:String = artwork.imgRef
        let fetchResult:PHFetchResult = PHAsset.fetchAssetsWithLocalIdentifiers([localIdentifier], options: nil)

        // Give the PHAsset to image manger to create create
        if (fetchResult.count > 0){
            let asset:PHAsset = fetchResult.firstObject as PHAsset
            imageManager.requestImageForAsset(asset, targetSize: CGSize(width:150, height:150), contentMode: .AspectFill, options: nil, resultHandler: { (result, info) in
                self.artworkImageView.image = result
            })
        }
        
        // Set title of the view
        title = artwork.title
        
        // Remove extra separator
        tableView.tableFooterView = UIView(frame: CGRectZero)
        
        // Change color of the separator
        tableView.separatorColor = UIColor(red:
            240.0/255.0, green: 240.0/255.0, blue: 240.0/255.0,
            alpha: 0.8)
        
        // Self sizing cell
        tableView.estimatedRowHeight = 45.0
        tableView.rowHeight = UITableViewAutomaticDimension
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
            
            cell.valueLabel.text = artwork.artistName
        case 2:
            cell.fieldLabel.text = "Location"
            cell.valueLabel.text = artwork.locationName + "\n" + artwork.locationAddress
        case 3:
            cell.fieldLabel.text = "Year"
            cell.valueLabel.text = artwork.year
        default:
            cell.fieldLabel.text = ""
            cell.valueLabel.text = ""
        }
        
        return cell
    }
}
