//
//  WalkStore.swift
//  walktracker
//
//  Created by Kevin VanderLugt on 1/10/15.
//  Copyright (c) 2015 Alpine Pipeline. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import CoreLocation

private var store: CoreDataStore! = CoreDataStore()
private var cdh: CoreDataHelper! = CoreDataHelper()
private let _WalkStoreSharedInstance = WalkStore()

class WalkStore:NSObject {
    
    // Singleton instance - Trying this for dealing with core data
    class var sharedInstance: WalkStore {
        return _WalkStoreSharedInstance
    }
    
    var currentWalk: Walk?
    
    override init() {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        store = appDelegate.cdstore
        cdh = appDelegate.cdh
    }

    let cdControl = NewsCoreDataController()
    
    lazy var allWalks: [Walk] = {
        let fetchRequest = NSFetchRequest()
        let entity = NSEntityDescription.entityForName("Walk", inManagedObjectContext: cdh.managedObjectContext)
        fetchRequest.entity = entity
        let sortDescriptor = NSSortDescriptor(key: "startTimestamp", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        if let fetchResults = (try? cdh.managedObjectContext.executeFetchRequest(fetchRequest)) as? [Walk] {
            return fetchResults
        }
        return [Walk]()
    }()
    
    func startWalk() {
        if (currentWalk == nil) {
            currentWalk = NSEntityDescription.insertNewObjectForEntityForName("Walk", inManagedObjectContext: cdh.managedObjectContext) as? Walk
            allWalks.append(currentWalk!)
        }
    }
    
    func stopWalk() {
        if currentWalk != nil {
            currentWalk?.endTimestamp = NSDate()
            cdh.saveContext()
        }
        
        currentWalk = nil
    }
    
    func indexOfCurrentWalk() -> Int? {
        if currentWalk != nil {
            return allWalks.indexOf(currentWalk!)
        }
        return nil
    }
    
    // MARK: - Core Data stack
    
    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.alpinepipeline.test" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1]
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        if let moc:NSManagedObjectContext = cdh.managedObjectContext {
            var error: NSError? = nil
            if moc.hasChanges {
                do {
                    try moc.save()
                } catch let error1 as NSError {
                    error = error1
                    // Replace this implementation with code to handle the error appropriately.
                    // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    NSLog("Unresolved error \(error), \(error!.userInfo)")
                    abort()
                }
            }
        }
    }
    
    
}