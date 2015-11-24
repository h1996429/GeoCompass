//
//  ThirdViewTrackController.swift
//  GeoCompass
//
//  Created by 何嘉 on 15/11/22.
//  Copyright © 2015年 何嘉. All rights reserved.
//

import Foundation
import UIKit
import CoreData


class ThirdViewTrackController:UITableViewController,UITabBarControllerDelegate,NSFetchedResultsControllerDelegate {
    let cdControl = NewsCoreDataController();
    var managedObjectContext: NSManagedObjectContext?
    //获取数据的控制器
    var addObjectContext: NSManagedObjectContext!
    var delegate: SecondViewController!
    
    var fetchedResultsController: NSFetchedResultsController?
    var rightBarButtonItem: UIBarButtonItem?
    var dateFormatter = NSDateFormatter()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.navigationItem.rightBarButtonItem = self.editButtonItem()
        self.editButtonItem().title = "编辑"
        //执行获取数据，并处理异常
        do {
            try self.initFetchedResultsController().performFetch()
        } catch let error as NSError {
            if error != 0 {abort()}
        }
    }
    
    // 自定义编辑单元格时的动作，可编辑样式包括UITableViewCellEditingStyleInsert（插入）、UITableViewCellEditingStyleDelete（删除）。
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            //删除sqlite库中对应的数据
            let context = self.fetchedResultsController?.managedObjectContext
            context!.deleteObject(self.fetchedResultsController?.objectAtIndexPath(indexPath) as! NSManagedObject)
            //删除后要进行保存
            do{ try context?.save() }
            catch let error as NSError {
                if error != 0 {
                    abort()
                }}
        }
    }

    
    //设置单元格的信息
    func setCellInfo(cell: UITableViewCell, indexPath: NSIndexPath) {
        dateFormatter.dateFormat = "记录起始于 yyyy-MM-dd HH时mm分"
            let walk = self.fetchedResultsController?.objectAtIndexPath(indexPath) as! Walk
            cell.textLabel!.text = dateFormatter.stringFromDate(walk.startTimestamp!)
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        //分组数量
        return self.fetchedResultsController!.sections!.count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //每个分组的数据数量
        let section = self.fetchedResultsController!.sections![section]
        return section.numberOfObjects
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        // 为列表Cell赋值
        self.setCellInfo(cell, indexPath: indexPath)
        return cell
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        //分组表头显示
        return self.fetchedResultsController!.sections![section].name
    }
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // 移动单元格时不要重新排序
        return false
    }
    
    //编辑状态影藏右侧按钮
    override func setEditing(editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        
        if (editing) {
            self.editButtonItem().title = "完成"
            self.rightBarButtonItem = self.navigationItem.rightBarButtonItem;
        }
        else {
            self.editButtonItem().title = "编辑"
            self.navigationItem.rightBarButtonItem = self.editButtonItem()
        }
        
    }
    // MARK: - NSFetchedResultsController delegate methods to respond to additions, removals and so on.
    
    //初始化获取数据的控制器
    func initFetchedResultsController() ->NSFetchedResultsController
    {
        let entityName = "Walk"
        if (self.fetchedResultsController != nil) {
            return self.fetchedResultsController!
        }

        // 创建一个获取数据的实例，用来查询实体
        let fetchRequest = NSFetchRequest()
        let entity = cdControl.EntityDescription(entityName)
        fetchRequest.entity = entity
        
        // 创建排序规则
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        let Descriptor = NSSortDescriptor(key: "startTimestamp", ascending: false)
        let sortDescriptors = [Descriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        
        // 创建获取数据的控制器，将section的name设置为author，可以直接用于tableViewSourceData
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: cdControl.cdh.managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        self.fetchedResultsController = fetchedResultsController
        return fetchedResultsController
    }
    
    //通知控制器即将开始处理一个或多个的单元格变化，包括添加、删除、移动或更新。在这里处理变化时对tableView的影响，例如删除sqlite数据时同时要删除tableView中对应的单元格
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch(type) {
        case .Insert:
            self.tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: UITableViewRowAnimation.Automatic)
        case .Delete:
            self.tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: UITableViewRowAnimation.Automatic)
        case .Update:
            self.setCellInfo(self.tableView.cellForRowAtIndexPath(indexPath!)!, indexPath: indexPath!)
        case .Move:
            self.tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: UITableViewRowAnimation.Automatic)
            self.tableView.insertRowsAtIndexPaths([indexPath!], withRowAnimation: UITableViewRowAnimation.Automatic)
        }
    }
    
    //通知控制器即将开始处理一个或多个的分组变化，包括添加、删除、移动或更新。
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        switch(type) {
        case .Insert:
            self.tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: UITableViewRowAnimation.Automatic)
        case .Delete:
            self.tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: UITableViewRowAnimation.Automatic)
        case .Update:
            break
        case .Move:
            break
        }
    }
    
    //通知控制器即将有变化
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        //tableView启动变更，需要endUpdates来结束变更，类似于一个事务，统一做变化处理
        self.tableView.beginUpdates()
    }
    
    //通知控制器变化完成
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        self.tableView.endUpdates()
    }
    
    func setSelectedRow() {
        if let selectedWalkRow = WalkStore.sharedInstance.indexOfCurrentWalk() {
            self.tableView.selectRowAtIndexPath(NSIndexPath(forRow: selectedWalkRow, inSection: 0),
                animated: true, scrollPosition:  UITableViewScrollPosition.Middle)
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let walk = self.fetchedResultsController?.objectAtIndexPath(indexPath) as! Walk
        WalkStore.sharedInstance.currentWalk = walk
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}