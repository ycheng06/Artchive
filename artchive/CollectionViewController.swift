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

class CollectionViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, CHTCollectionViewDelegateWaterfallLayout {

    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBAction func unwindToHomeScreen(segue:UIStoryboardSegue){
        
    }

    private var artCollections: [Artwork] = []
    private var cellSizes:[Int: CGSize] = [Int: CGSize]()

    var fetchResultController:NSFetchedResultsController!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let layout:CHTCollectionViewWaterfallLayout = collectionView.collectionViewLayout as CHTCollectionViewWaterfallLayout
        layout.columnCount = 2
        layout.sectionInset = UIEdgeInsetsMake(0, 10, 0, 10)
        layout.itemRenderDirection = .CHTCollectionViewWaterfallLayoutItemRenderDirectionShortestFirst
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        //Probabaly not the best way to refresh data. View will appear is called
        //everytime this view appears. CollectionView doesn't really work nicely
        //with NSFetchedDelegate.....
        initArtCollections()
        
        collectionView.reloadData()
    }
    
    private func initArtCollections(){
        var fetchRequest = NSFetchRequest(entityName: "Artwork")
        let sortDescriptor = NSSortDescriptor(key: "title", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        if let managedObjectContext = (UIApplication.sharedApplication().delegate as AppDelegate).managedObjectContext{
            fetchResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
            
//            fetchResultController.delegate = self
         
            var error:NSError?
            var result = fetchResultController.performFetch(&error)
            artCollections = fetchResultController.fetchedObjects as [Artwork]
            
            if result != true {
                println(error?.localizedDescription)
            }
        }
    }
    
    // UICollectionViewDataSource
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return artCollections.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        // Create a cell to be populated with image
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("CollectionCell", forIndexPath: indexPath) as ArtworkCollectionViewCell
        
        // Get an instance of PHImageManager
        let imageManager = PHImageManager.defaultManager()
        
        // Use the stored local identifer to fetch PHAsset
        let artwork:Artwork = artCollections[indexPath.row] as Artwork
        let localIdentifier:String = artwork.imgRef
        
        // Fetch the PHAsset with the localIdenifier
        let fetchResult:PHFetchResult = PHAsset.fetchAssetsWithLocalIdentifiers([localIdentifier], options: nil)
        
        // Give the PHAsset to image manger to create create
        if (fetchResult.count > 0){
            let asset:PHAsset = fetchResult.firstObject as PHAsset
            imageManager.requestImageForAsset(asset, targetSize: CGSizeMake(150, 150), contentMode: .AspectFill, options: nil, resultHandler: { (result, info) in
                cell.setArtwork(result)
            })
        }
        
        // Set the image in the cell
        return cell
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        let artwork = artCollections[indexPath.row] as Artwork
        
        var cellSize:CGSize!
        // Landscape
        if (artwork.originWidth.integerValue > artwork.originHeight.integerValue){
            cellSize = CGSizeMake(60, 50)
        }
        // Portrait
        else {
            cellSize = CGSizeMake(60, 110)
        }
        
        return cellSize
    }
    
    // NSFetchedResultsControllerDelegate
//    func controllerWillChangeContent(controller: NSFetchedResultsController) {
//
//    }
//    
//    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
//        
//        var change:[NSFetchedResultsChangeType: NSIndexPath] = [NSFetchedResultsChangeType: NSIndexPath]()
//        switch type{
//        case .Insert:
//            println(newIndexPath)
//            change.updateValue(newIndexPath!, forKey: type)
//        case .Delete:
//            change.updateValue(indexPath!, forKey: type)
//        case .Update:
//            change.updateValue(indexPath!, forKey: type)
//        default:
//            println("nothing here")
//        }
//        
//        objectChanges.append(change)
//    }
//    
//    func controllerDidChangeContent(controller: NSFetchedResultsController) {
////        if shouldReloadCollectionView() {
////            self.collectionView.reloadData()
////        }
////        else {
////            if objectChanges.count > 0 {
////                self.collectionView.performBatchUpdates({
////                    
////                    for change in self.objectChanges {
////                        for(changeType, indexPath) in change{
////                            switch(changeType){
////                            case .Insert:
////                                self.collectionView.insertItemsAtIndexPaths([indexPath])
////                            case .Delete:
////                                self.collectionView.deleteItemsAtIndexPaths([indexPath])
////                            case .Update:
////                                self.collectionView.reloadItemsAtIndexPaths([indexPath])
////                            default:
////                                self.collectionView.reloadData()
////                            }
////                        }
////                    }
////                    
////                    }, completion: nil)
////            }
////            
////            objectChanges.removeAll(keepCapacity: true)
////        }
//    }
//    
//    func shouldReloadCollectionView() -> Bool {
//        var shouldReload:Bool = false
//        
//        for change in self.objectChanges {
//            for(changeType, indexPath) in change{
//                switch(changeType){
//                case .Insert:
//                    if(self.collectionView.numberOfItemsInSection(indexPath.section) == 0){
//                        shouldReload = true
//                    } else {
//                        shouldReload = false
//                    }
//                case .Delete:
//                    if(self.collectionView.numberOfItemsInSection(indexPath.section) == 1){
//                        shouldReload = true
//                    } else {
//                        shouldReload = false
//                    }
//
//                default:
//                    shouldReload = false
//
//                }
//            }
//        }
//
//        return shouldReload
//    }
//    
    // Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "showArtworkDetail" {
            let indexPaths:[NSIndexPath] = self.collectionView.indexPathsForSelectedItems() as [NSIndexPath]
            if let indexPath = indexPaths.first {
                let destinationController = segue.destinationViewController as DetailViewController
                destinationController.artwork = artCollections[indexPath.row]
            }
        }
        
    }

}
