//
//  Walk+CoreDataProperties.swift
//  GeoCompass
//
//  Created by 何嘉 on 15/11/19.
//  Copyright © 2015年 何嘉. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData
import CoreLocation

extension Walk {

    @NSManaged var distance: NSNumber?
    @NSManaged var endTimestamp: NSDate?
    @NSManaged var locations: Array<CLLocation>
    @NSManaged var startTimestamp: NSDate?

}
