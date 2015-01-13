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


class AddArtworkViewController: UITableViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    let albumName = "artchive"
    var albumFound: Bool = false
    var assetCollection: PHAssetCollection!
    var chosenImage:UIImage?
    
    var context:NSManagedObjectContext!
    
    // Actions & Outlets
    @IBOutlet weak var artTitle: UITextField!
    @IBOutlet weak var artArtist: UITextField!
    @IBOutlet weak var artLocation: UITextField!
    @IBOutlet weak var artYear: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    
    // Hide keyboard if view is tapped
    @IBAction func viewTapped(sender: AnyObject) {
        artTitle.resignFirstResponder()
    }
    
    @IBAction func saveArtwork(sender: UIBarButtonItem) {
        let titleText:String = artTitle.text
        
        if !titleText.isEmpty {
            println(titleText)
            var newArtwork = NSEntityDescription.insertNewObjectForEntityForName("Artwork", inManagedObjectContext: self.context) as Artwork

            newArtwork.title = titleText
            
            if !artArtist.text.isEmpty {
                
            }
            
            if !artLocation.text.isEmpty {
                
            }
            
            if !artYear.text.isEmpty {
                
            }

            if let image = chosenImage{
                var assetPlaceHolder:PHObjectPlaceholder?
                
                newArtwork.originHeight = image.size.height
                newArtwork.originWidth = image.size.width
                
                PHPhotoLibrary.sharedPhotoLibrary().performChanges({
                    // Create Image and add it into album
                    let createAssetRequest = PHAssetChangeRequest.creationRequestForAssetFromImage(image)
                    
                    // Save the local identifier from this place holder so image can be retrieved in the future
                    assetPlaceHolder = createAssetRequest.placeholderForCreatedAsset
                    
                    newArtwork.imgRef = assetPlaceHolder?.localIdentifier
                    println(newArtwork.imgRef)
                    
                    let albumChangeRequest = PHAssetCollectionChangeRequest(forAssetCollection: self.assetCollection)
                    
                    albumChangeRequest.addAssets([assetPlaceHolder!])
                        
                },
                completionHandler: {(success:Bool, error:NSError!) in
                    var error: NSError?
                    if !self.context.save(&error){
                        println("Could not save \(error), \(error?.userInfo)")
                    }
                    else{
                        println(newArtwork)
                        self.performSegueWithIdentifier("unwindToHomeScreen", sender: self)
                    }
                })
            }
        }
        else{
            // spawn UIAlert here
            var alert = UIAlertController(title: "Oops", message: "We can't proceed as you forgot to fill in the title. This field is mandatory", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: {
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
        context = appDelegate.managedObjectContext!
        
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
    
    // UITableView
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        // First cell opens Camera or PhotoLibrary
        if indexPath.row == 0 {
            if (UIImagePickerController.isSourceTypeAvailable(.Camera)){
                
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.allowsEditing = false
                imagePicker.sourceType = .Camera
                
                self.presentViewController(imagePicker, animated: true, completion: nil)
            }
            
            // Development setting
            else if (UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary)){
                
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.allowsEditing = false
                imagePicker.sourceType = .PhotoLibrary
                
                self.presentViewController(imagePicker, animated: true, completion: nil)
            }
            else{
                // No camera available
                var alert = UIAlertController(title: "Oops", message: "Camera and PhotoLibrary are not available. We can't continue without at least one. Please check your device", preferredStyle: .Alert)
                alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: {
                    (alertAction) in
                    alert.dismissViewControllerAnimated(true, completion: nil)
                }))
    
                self.presentViewController(alert, animated: true, completion: nil)
            }
        }
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    // Color of status bar changed from white to black after displaying photo library. Use this as a quick fix
    func navigationController(navigationController: UINavigationController, willShowViewController viewController: UIViewController, animated: Bool) {
        UIApplication.sharedApplication().setStatusBarStyle(.LightContent, animated: false)
    }

    // UIIImagePickerControllerDelegate Methods
    func imagePickerController(picker: UIImagePickerController!, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {

        self.dismissViewControllerAnimated(true, completion: nil)
        chosenImage = image
        self.imageView.image = image
        self.imageView.contentMode = UIViewContentMode.ScaleAspectFill
        self.imageView.clipsToBounds = true
        
        print(image.size)

        
//        let sourceType:UIImagePickerControllerSourceType = picker.sourceType
        
        // If source is camera we need to save the image as a PHAsset and save it into the device's album
//        if sourceType == .Camera {
        
//        }
        
//        // Development option
//        else if sourceType == .PhotoLibrary{
//            imageView.image = image
//            imageView.contentMode = UIViewContentMode.ScaleAspectFill
//            imageView.clipsToBounds = true
//        }
//        else{}
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
}