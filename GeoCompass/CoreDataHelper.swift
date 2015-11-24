//
//  CoreDataHelper.swift
//  GeoCompass
//
//  Created by 何嘉 on 15/9/19.
//  Copyright (c) 2015年 何嘉. All rights reserved.
//

import Foundation
import CoreData
import UIKit
class CoreDataHelper: NSObject{
    let store: CoreDataStore!
    override init(){
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        self.store = appDelegate.cdstore
        super.init()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "contextDidSaveContext:", name: NSManagedObjectContextDidSaveNotification, object: nil)
    }
    deinit{
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    // #pragma mark - Core Data stack
    // main thread context
    var managedObjectContext: NSManagedObjectContext {
        if _managedObjectContext == nil {
            let coordinator = self.store.persistentStoreCoordinator
            if coordinator != 0 {
                _managedObjectContext = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.MainQueueConcurrencyType)
                _managedObjectContext!.persistentStoreCoordinator = coordinator
            }
        }
        return _managedObjectContext!
    }
    var _managedObjectContext: NSManagedObjectContext? = nil
    var backgroundContext: NSManagedObjectContext {
        if _backgroundContext == nil {
            let coordinator = self.store.persistentStoreCoordinator
            if coordinator != 0 {
                _backgroundContext = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.PrivateQueueConcurrencyType)
                _backgroundContext!.persistentStoreCoordinator = coordinator
            }
        }
        return _backgroundContext!
    }
    var _backgroundContext: NSManagedObjectContext? = nil
    // save NSManagedObjectContext
    func saveContext (context: NSManagedObjectContext) {
        if context != 0 {
            if context.hasChanges {
                do {
                    try context.save()
                } catch let error as NSError {
                    if error != 0 {
                        abort()}
                }
            }
        }
    }
    func saveContext () {
        self.saveContext( self.backgroundContext )
    }
    // call back function by saveContext, support multi-thread
    func contextDidSaveContext(notification: NSNotification) {
        let sender = notification.object as! NSManagedObjectContext
        if sender === self.managedObjectContext {
            self.backgroundContext.performBlock {
                self.backgroundContext.mergeChangesFromContextDidSaveNotification(notification)
            }
        } else if sender === self.backgroundContext {
            self.managedObjectContext.performBlock {
                self.managedObjectContext.mergeChangesFromContextDidSaveNotification(notification)
            }
        } else {
            print("======= Saved Context in other thread")
            self.backgroundContext.performBlock {                self.backgroundContext.mergeChangesFromContextDidSaveNotification(notification)
            }
            self.managedObjectContext.performBlock {
                self.managedObjectContext.mergeChangesFromContextDidSaveNotification(notification)
            }
        }
    }
}