//
//  CollectionViewController.swift
//  artchive
//
//  Created by Jason Cheng on 12/30/14.
//  Copyright (c) 2014 oceanapart. All rights reserved.
//

import UIKit
import CoreData
import Photos

class CollectionViewController: UIViewController, UICollectionViewDataSource {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    private var artCollections: [NSManagedObject] = []
//    private var fetchResult: PHFetchResult!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.reloadData()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        initArtCollections()
        
        // Testing Mode
//        getAllImages()
    }
    
//    private func getAllImages(){
//        fetchResult = PHAsset.fetchAssetsWithMediaType(PHAssetMediaType.Image, options: nil)
//    }
    
    private func initArtCollections(){
        // Get context for core data
        var appDelegate:AppDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        var context:NSManagedObjectContext = appDelegate.managedObjectContext!

        var request = NSFetchRequest(entityName: "Artwork")
        if let results = context.executeFetchRequest(request, error: nil) as? [NSManagedObject]{
            if(results.count > 0){
                println(results.count)
                artCollections = results
                print(artCollections)
            }
        }
//        
//        if(results.count > 0 ){
//            artCollections = results
//        }

        
    }
    
    // UICollectionViewDataSource
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return artCollections.count
//        return fetchResult.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        // Create a cell to be populated with image
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("ArtworkCollectionViewCell", forIndexPath: indexPath) as ArtworkCollectionViewCell
        
        // Get an instance of PHImageManager
        let imageManager = PHImageManager.defaultManager()
        
        // Use the stored local identifer to fetch PHAsset
        let artwork:NSManagedObject = artCollections[indexPath.row] as NSManagedObject
        let localIdentifier:String = artwork.valueForKey("imgRef") as String
        let fetchResult:PHFetchResult = PHAsset.fetchAssetsWithLocalIdentifiers([localIdentifier], options: nil)
        
        
        
        // Give the PHAsset to image manger to create create
        if (fetchResult.count > 0){
            let asset:PHAsset = fetchResult.firstObject as PHAsset
            imageManager.requestImageForAsset(asset, targetSize: CGSize(width:140, height:140), contentMode: .AspectFill, options: nil, resultHandler: {
                (result, info) in
                cell.setArtwork(result)
            })
        }
        
//        let asset:PHAsset = fetchResult[indexPath.row] as PHAsset
//        imageManager.requestImageForAsset(asset, targetSize: CGSize(width: 140, height: 140), contentMode: .AspectFill, options: nil, resultHandler: {
//            (result, info) in
//            cell.setArtwork(result)
//        })
        
        
        // Set the image in the cell
        return cell
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }

    // UICollectionViewFlowLayout
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let picDimension = self.view.frame.size.width / 1.5
        return CGSizeMake(picDimension, picDimension)
    }
    
//    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
//        let leftRightInset = self.view.frame.size.width / 14.0
//        return UIEdgeInsetsMake(0, leftRightInset, 0, leftRightInset)
//    }
//
}
