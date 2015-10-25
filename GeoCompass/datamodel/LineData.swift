//
//  LineData.swift
//  
//
//  Created by 何嘉 on 15/9/20.
//
//

import Foundation
import CoreData

@objc(LineData)
class LineData: NSManagedObject {

    @NSManaged var adrS: String
    @NSManaged var hightErrorS: NSNumber
    @NSManaged var hightS: NSNumber
    @NSManaged var imageS: NSData
    @NSManaged var latS: NSNumber
    @NSManaged var locErrorS: NSNumber
    @NSManaged var lonS: NSNumber
    @NSManaged var magErrorS: NSNumber
    @NSManaged var pitchS: NSNumber
    @NSManaged var pluangS: NSNumber
    @NSManaged var plusynS: NSNumber
    @NSManaged var strikeS: NSNumber
    @NSManaged var timeS: NSDate
    @NSManaged var id: NSNumber

}
