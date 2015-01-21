//
//  Artwork.swift
//  artchive
//
//  Created by Jason Cheng on 1/9/15.
//  Copyright (c) 2015 oceanapart. All rights reserved.
//

import Foundation
import CoreData

class Artwork:NSManagedObject{
    @NSManaged var title:String!
    @NSManaged var artistName:String!
    @NSManaged var year:String!
    @NSManaged var imgRef:String!
    @NSManaged var locationName:String!
    @NSManaged var locationAddress:String!
    @NSManaged var originWidth:NSNumber!
    @NSManaged var originHeight:NSNumber!

}
