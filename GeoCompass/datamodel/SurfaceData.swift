//
//  SurfaceData.swift
//  
//
//  Created by 何嘉 on 15/11/1.
//
//

import Foundation
import CoreData
import MapKit


@objc(SurfaceData)
class SurfaceData: NSManagedObject, MKAnnotation {

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
    @NSManaged var describeS: NSString
    
    
    //returning the coordinate so as to conform to MKAnnotation protocol
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latS as Double, longitude: lonS as Double)
    }


}

