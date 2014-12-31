//
//  ArtworkCollectionViewCell.swift
//  artchive
//
//  Created by Jason Cheng on 12/30/14.
//  Copyright (c) 2014 oceanapart. All rights reserved.
//

import Foundation
import UIKit
import Photos

class ArtworkCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var artworkImageView: UIImageView!
    
    func setArtwork(image: UIImage ){
        artworkImageView.image = image
    }
}
