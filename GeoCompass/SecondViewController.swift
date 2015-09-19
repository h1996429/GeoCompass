//
//  SecondViewController.swift
//  GeoCompass
//
//  Created by 何嘉 on 15/9/3.
//  Copyright (c) 2015年 何嘉. All rights reserved.
//

import UIKit
import CoreData

var data1num = 0;
var data2num = 0;
class SecondViewController: UIViewController,NSFetchedResultsControllerDelegate {
   /* var managedObjectContext: NSManagedObjectContext?
    //获取数据的控制器
    var fetchedResultsController: NSFetchedResultsController?
    
    var rightBarButtonItem: UIBarButtonItem?
    
    var surfacedata : SurfaceData!
    
    

        
     override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        

    }
    
    func setUpundoManager() {
        if self.surfacedata.managedObjectContext?.undoManager == nil {
            self.surfacedata.managedObjectContext?.undoManager =  NSUndoManager()
            self.surfacedata.managedObjectContext?.undoManager?.levelsOfUndo = 3//撤销最大数
        }
        
        var surfacedataUndoManager = self.surfacedata.managedObjectContext?.undoManager
        
        //监听撤回和取消撤回
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "undoManagerDidUndo:", name: NSUndoManagerDidUndoChangeNotification, object: surfacedataUndoManager)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "undoManagerDidRedo:", name: NSUndoManagerDidRedoChangeNotification, object: surfacedataUndoManager)
    }
    
    //取消撤回管理器
    func cleanUpUndoManager() {
        var surfacedataUndoManager = self.surfacedata.managedObjectContext?.undoManager
        
        //移除撤回和取消撤回监听
        NSNotificationCenter.defaultCenter().removeObserver(self, name: NSUndoManagerWillUndoChangeNotification, object: surfacedataUndoManager)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: NSUndoManagerWillRedoChangeNotification, object: surfacedataUndoManager)
        
        //置空context的撤回管理器
        self.surfacedata.managedObjectContext?.undoManager = nil
    }*/


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

