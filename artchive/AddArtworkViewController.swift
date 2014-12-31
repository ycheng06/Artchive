//
//  AddArtworkViewController.swift
//  artchive
//
//  Created by Jason Cheng on 12/25/14.
//  Copyright (c) 2014 oceanapart. All rights reserved.
//

import Foundation
import UIKit
import MobileCoreServices
import Photos
import CoreData


class AddArtworkViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    let albumName = "artchive"
    var albumFound: Bool = false
    var assetCollection: PHAssetCollection!
    var assetPlaceHolder:PHObjectPlaceholder?
    var context:NSManagedObjectContext!
    
    // Actions & Outlets
    @IBOutlet weak var artTitle: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    
    // Hide keyboard if view is tapped
    @IBAction func viewTapped(sender: AnyObject) {
        artTitle.resignFirstResponder()
    }
    
    @IBAction func cancelArtwork(sender: UIBarButtonItem) {
        dismissViewControllerAnimated(true, completion: nil)
    }
   
    
    @IBAction func saveArtwork(sender: UIBarButtonItem) {
        
        var newArtwork = NSEntityDescription.insertNewObjectForEntityForName("Artwork", inManagedObjectContext: self.context) as NSManagedObject
        
        newArtwork.setValue(artTitle.text, forKey: "title")
        if let imageLocalIdentifier:String = assetPlaceHolder?.localIdentifier {
            newArtwork.setValue(imageLocalIdentifier, forKey: "imgRef")
        }
        
        var error: NSError?
        if !self.context.save(&error){
            println("Could not save \(error), \(error?.userInfo)")
        }
        else{
            println(newArtwork)
            self.dismissViewControllerAnimated(true, completion: nil)
        }

    }
    
    @IBAction func takePhoto(sender: AnyObject) {
        if (UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)){
            
            // Load camera interface
            var picker = UIImagePickerController()
            picker.delegate = self
            picker.sourceType = UIImagePickerControllerSourceType.Camera
            picker.allowsEditing = false
            
            // Start the default camera
            self.presentViewController(picker, animated: true, completion: nil)
        }
        else{
            // No camera available
            var alert = UIAlertController(title: "Error", message: "There is no camera available", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "Okay", style: .Default, handler: {
                (alertAction) in
                alert.dismissViewControllerAnimated(true, completion: nil)
            }))
            
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Get context
        var appDelegate:AppDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        var context:NSManagedObjectContext = appDelegate.managedObjectContext!
        
        // Check if folder exists, if not, create it
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "title = %@", albumName)
        let collection:PHFetchResult = PHAssetCollection.fetchAssetCollectionsWithType(.Album, subtype: .Any, options: fetchOptions)
        
        if let firstObject: AnyObject = collection.firstObject{
            self.albumFound = true
            self.assetCollection = collection.firstObject as PHAssetCollection
        }
        else{
            // Album placeholder for the asset collection, used to reference collection in completion handler
            var albumPlaceholder: PHObjectPlaceholder!
            
            // Create the folder
            PHPhotoLibrary.sharedPhotoLibrary().performChanges({
                // Create asset collection change request
                let request = PHAssetCollectionChangeRequest.creationRequestForAssetCollectionWithTitle(self.albumName)
                
                // Save the album place holder so we can fetch the album in the completion handler
                albumPlaceholder = request.placeholderForCreatedAssetCollection
                
                }, completionHandler: {
                    (success:Bool, error:NSError!) in
                    self.albumFound = success
                    
                    if(success){
                        // Use the place holder to fetch the created album and save it locally
                        let collection = PHAssetCollection.fetchAssetCollectionsWithLocalIdentifiers([albumPlaceholder.localIdentifier], options: nil)
                        self.assetCollection = collection?.firstObject as PHAssetCollection
                    }
            })
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //UIIImagePickerControllerDelegate Methods
    func imagePickerController(picker: UIImagePickerController!, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {

        self.dismissViewControllerAnimated(true, completion: nil)
        
        let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
        // Dispatch onto a worker thread
        dispatch_async(dispatch_get_global_queue(priority, 0), {
            PHPhotoLibrary.sharedPhotoLibrary().performChanges({
                // Create Image and add it into album
                let createAssetRequest = PHAssetChangeRequest.creationRequestForAssetFromImage(image)
                
                // Save the local identifier from this place holder so image can be retrieved in the future
                self.assetPlaceHolder = createAssetRequest.placeholderForCreatedAsset
                
                let albumChangeRequest = PHAssetCollectionChangeRequest(forAssetCollection: self.assetCollection)
                
                albumChangeRequest.addAssets([self.assetPlaceHolder!])
                
                }, completionHandler: {(success:Bool, error:NSError!) in
            
                    let fetchResult:PHFetchResult = PHAsset.fetchAssetsWithLocalIdentifiers([self.assetPlaceHolder!.localIdentifier], options: nil)
                    
                    if(fetchResult.count > 0){
                        let asset:PHAsset = fetchResult.firstObject as PHAsset
                        
                        // Get an instance of PHImageManager
                        let imageManager = PHImageManager.defaultManager()
                        imageManager.requestImageForAsset(asset, targetSize: CGSize(width:150, height:150), contentMode: .AspectFill, options: nil, resultHandler: {
                            (result, info) in
                            
                            // Assign image to image view in main thread
                            dispatch_async(dispatch_get_main_queue(), {
                                self.imageView.image = result
                            })
                        })
                    }
            })
        })

    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
}