//
//  LineImage.swift
//  
//
//  Created by 何嘉 on 15/9/20.
//
//

import Foundation
import CoreData

@objc(LineImage)
class LineImage: NSManagedObject {

    @NSManaged var imageS: NSData
    @NSManaged var id: NSNumber

}
