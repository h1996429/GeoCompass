//
//  Walk.swift
//  GeoCompass
//
//  Created by 何嘉 on 15/11/19.
//  Copyright © 2015年 何嘉. All rights reserved.
//

import Foundation
import CoreData
import CoreLocation

@objc(Walk)
class Walk: NSManagedObject {

// Insert code here to add functionality to your managed object subclass
    var duration: NSTimeInterval {
        get {
            return endTimestamp!.timeIntervalSinceDate(startTimestamp!)
        }
    }
    
    func addDistance(distance: Double) {
        self.distance = NSNumber(double: (self.distance!.doubleValue + distance))
    }
    
    func addNewLocation(location: CLLocation) {
        locations.append(CoordsTransform.transformMarsToGpsCoordsWithCLLocation(location))
    }
    
    override func awakeFromInsert() {
        super.awakeFromInsert()
        
        locations = [CLLocation]()
        startTimestamp = NSDate()
        distance = 0.0
    }


}







