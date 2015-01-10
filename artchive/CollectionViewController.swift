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

class CollectionViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, CHTCollectionViewDelegateWaterfallLayout, NSFetchedResultsControllerDelegate {
    

    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBAction func unwindToHomeScreen(segue:UIStoryboardSegue){
        
    }

    private var artCollections: [Artwork] = []
    private var fetchResult: PHFetchResult!
    private var cellSizes:NSMutableArray = NSMutableArray() // Different cell sizes for the collection view
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let layout:CHTCollectionViewWaterfallLayout = collectionView.collectionViewLayout as CHTCollectionViewWaterfallLayout
        layout.columnCount = 2
        layout.sectionInset = UIEdgeInsetsMake(0, 10, 0, 10)
        layout.itemRenderDirection = .CHTCollectionViewWaterfallLayoutItemRenderDirectionShortestFirst

        initArtCollections()
        initCellSizes()

    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        // Testing Mode
        // getAllImages()
    }
    
    private func initCellSizes(){
        for (var index=0; index<artCollections.count; index++) {
            let height = CGFloat(arc4random() % 50 + 70)
            let width = CGFloat(arc4random() % 50 + 60)
            var cellSize:CGSize = CGSizeMake(width, height)
            cellSizes[index] = NSValue(CGSize: cellSize)
        }
    }
    
    private func getAllImages(){
        fetchResult = PHAsset.fetchAssetsWithMediaType(PHAssetMediaType.Image, options: nil)
    }
    
    private func initArtCollections(){
        // Get context for core data
        var appDelegate:AppDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        var context:NSManagedObjectContext = appDelegate.managedObjectContext!

        // Fetch all Artwork from core data
        var request = NSFetchRequest(entityName: "Artwork")
        var error:NSError?
        if let results = context.executeFetchRequest(request, error: nil) as? [Artwork]{
            if(results.count > 0){
                println(results.count)
                artCollections = results
            }
        }
        else{
            println(error?.localizedDescription)
        }
    }
    
    // UICollectionViewDataSource
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return artCollections.count

//        return fetchResult.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        // Create a cell to be populated with image
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("CollectionCell", forIndexPath: indexPath) as ArtworkCollectionViewCell
        
        // Get an instance of PHImageManager
        let imageManager = PHImageManager.defaultManager()
        
        // Use the stored local identifer to fetch PHAsset
        let artwork:Artwork = artCollections[indexPath.row] as Artwork
        let localIdentifier:String = artwork.imgRef
        
        // Retrieve the cell size for the image
        let cellSize:NSValue = cellSizes[indexPath.row] as NSValue
        
        // Fetch the PHAsset with the localIdenifier
        let fetchResult:PHFetchResult = PHAsset.fetchAssetsWithLocalIdentifiers([localIdentifier], options: nil)
        
        // Give the PHAsset to image manger to create create
        if (fetchResult.count > 0){
            let asset:PHAsset = fetchResult.firstObject as PHAsset
            imageManager.requestImageForAsset(asset, targetSize: CGSize(width:140, height:140), contentMode: .AspectFill, options: nil, resultHandler: { (result, info) in
                cell.setArtwork(result)
            })
        }
        

//        let asset:PHAsset = fetchResult[indexPath.row] as PHAsset
//        imageManager.requestImageForAsset(asset, targetSize: cellSize.CGSizeValue(), contentMode: .AspectFill, options: nil, resultHandler: { (result, info) in
//            
//            cell.setArtwork(result)
//            
//        })
        
        
        // Set the image in the cell
        return cell
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
//         let imageHeight = image.size.height*gridWidth/image.size.width
        let cellSize:NSValue = cellSizes[indexPath.row] as NSValue
        print(cellSize.CGSizeValue())
        return cellSize.CGSizeValue()
    }

//    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
//        let leftRightInset = self.view.frame.size.width / 50.0
////        println(leftRightInset)
////        return UIEdgeInsetsMake(0, leftRightInset, 0, leftRightInset)
////        return UIEdgeInsetsMake(0, 5, 0, 5)
//    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showArtworkDetail" {
            println("whats up")
            let indexPaths:[NSIndexPath] = self.collectionView.indexPathsForSelectedItems() as [NSIndexPath]
            if let indexPath = indexPaths.first {
                let destinationController = segue.destinationViewController as DetailViewController
                destinationController.artwork = artCollections[indexPath.row]
            }
        }
    }

}
