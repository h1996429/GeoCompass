//
//  AppDelegate.swift
//  test
//
//  Created by 何嘉 on 15/9/17.
//  Copyright (c) 2015年 何嘉. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    //app 开始启动时调用
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
    
        return true    }
    
    //app将要入非活动状态时调用，在此期间，应用程序不接收消息或事件，比如来电话了；保存数据
    func applicationWillResignActive(application: UIApplication) {
    }
    
    //app被推送到后台时调用，所以要设置后台继续运行，则在这个函数里面设置即可；保存数据
    func applicationDidEnterBackground(application: UIApplication) {
        WalkStore.sharedInstance.saveContext()
    }
    
    //app从后台将要重新回到前台非激活状态时调用
    func applicationWillEnterForeground(application: UIApplication) {
    }
    
    //app进入活动状态执行时调用
    func applicationDidBecomeActive(application: UIApplication) {
    }
    
    // #pragma mark - Core Data Helper
    var cdstore: CoreDataStore {
        if _cdstore == nil {
            _cdstore = CoreDataStore()
        }
        return _cdstore!
    }
    var _cdstore: CoreDataStore? = nil
    var cdh: CoreDataHelper {
        if _cdh == nil {
            _cdh = CoreDataHelper()
        }
        return _cdh!
    }
    var _cdh: CoreDataHelper? = nil
    
    //app将要退出是被调用，通常是用来保存数据和一些退出前的清理工作；保存数据
    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.cdh.saveContext()
    }
    
}


