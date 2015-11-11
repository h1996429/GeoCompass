//
//  SurfaceImage.swift
//  
//
//  Created by 何嘉 on 15/11/1.
//
//

import Foundation
import CoreData

class SurfaceImage: NSManagedObject {

    @NSManaged var id: NSNumber
    @NSManaged var imageS: NSData
    @NSManaged var describe: NSString


}
