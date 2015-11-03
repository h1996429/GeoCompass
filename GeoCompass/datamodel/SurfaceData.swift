//
//  SurfaceData.swift
//  
//
//  Created by 何嘉 on 15/11/1.
//
//

import Foundation
import CoreData

@objc(SurfaceData)
class SurfaceData: NSManagedObject {

    @NSManaged var adrS: String
    @NSManaged var dipdirS: NSNumber
    @NSManaged var dipS: NSNumber
    @NSManaged var hightErrorS: NSNumber
    @NSManaged var hightS: NSNumber
    @NSManaged var id: NSNumber
    @NSManaged var imageS: NSData
    @NSManaged var latS: NSNumber
    @NSManaged var locErrorS: NSNumber
    @NSManaged var lonS: NSNumber
    @NSManaged var magErrorS: NSNumber
    @NSManaged var strikeS: NSNumber
    @NSManaged var timeS: NSDate

}

