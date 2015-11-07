//
//  SecondViewController.swift
//  GeoCompass
//
//  Created by 何嘉 on 15/9/3.
//  Copyright (c) 2015年 何嘉. All rights reserved.
//

import UIKit
import CoreData


class SecondViewController:UITableViewController,UITabBarControllerDelegate,NSFetchedResultsControllerDelegate {
    let cdControl = NewsCoreDataController();
    var managedObjectContext: NSManagedObjectContext?
    //获取数据的控制器
    var addObjectContext: NSManagedObjectContext!
    var delegate: SecondViewController!
    
    var fetchedResultsController: NSFetchedResultsController?
    var rightBarButtonItem: UIBarButtonItem?
    var dateFormatter = NSDateFormatter()
    
    var segmentedControlChange = false;

    @IBOutlet weak var segmentedControl: UISegmentedControl!

    @IBAction func indexChange(sender: UISegmentedControl) {
        var error: NSError? = nil
        segmentedControlChange = true;
        if !self.initFetchedResultsController().performFetch(&error){
            NSLog("Unresolved error \(error), \(error!.userInfo)")
            abort()
        }
        self.tableView.reloadData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //为导航栏左边按钮设置编辑按钮
        self.navigationItem.leftBarButtonItem = self.editButtonItem()
        self.editButtonItem().title = "编辑"
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "返回", style: UIBarButtonItemStyle.Plain, target: nil, action: nil)

        //执行获取数据，并处理异常
        var error: NSError? = nil
        if !self.initFetchedResultsController().performFetch(&error){
            NSLog("Unresolved error \(error), \(error!.userInfo)")
            abort()
        }
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //设置单元格的信息
    func setCellInfo(cell: UITableViewCell, indexPath: NSIndexPath) {
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        if segmentedControl.selectedSegmentIndex == 0 {
            var surfacedata = self.fetchedResultsController?.objectAtIndexPath(indexPath) as! SurfaceData
            cell.textLabel!.text = dateFormatter.stringFromDate(surfacedata.timeS) + " 数据"
        }
        else if segmentedControl.selectedSegmentIndex == 1 {
            var linedata = self.fetchedResultsController?.objectAtIndexPath(indexPath) as! LineData
            cell.textLabel!.text = dateFormatter.stringFromDate(linedata.timeS) + " 数据"
        }
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        //分组数量
        return self.fetchedResultsController!.sections!.count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //每个分组的数据数量
        var section = self.fetchedResultsController!.sections![section]as! NSFetchedResultsSectionInfo
        return section.numberOfObjects
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! UITableViewCell
        // 为列表Cell赋值
        self.setCellInfo(cell, indexPath: indexPath)
        return cell
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        //分组表头显示
        return self.fetchedResultsController!.sections![section].name
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    // Return NO if you do not want the specified item to be editable.
    return true
    }
    */
    
    // 自定义编辑单元格时的动作，可编辑样式包括UITableViewCellEditingStyleInsert（插入）、UITableViewCellEditingStyleDelete（删除）。
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            //删除sqlite库中对应的数据
            var context = self.fetchedResultsController?.managedObjectContext
            context!.deleteObject(self.fetchedResultsController?.objectAtIndexPath(indexPath) as! NSManagedObject)
            //删除后要进行保存
            var error: NSError? = nil
            if context?.save(&error) == false {
                NSLog("Unresolved error \(error), \(error!.userInfo)")
                abort()
            }
        } else if editingStyle == .Insert {
            
        }
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
            self.navigationItem.rightBarButtonItem = nil;
        }
        else {
            self.editButtonItem().title = "编辑"
            self.navigationItem.rightBarButtonItem = self.rightBarButtonItem;
            self.rightBarButtonItem = nil;
        }
        
    }
    // MARK: - NSFetchedResultsController delegate methods to respond to additions, removals and so on.
    
    //初始化获取数据的控制器
    func initFetchedResultsController() ->NSFetchedResultsController
    {
        var entityName = "SurfaceData"
        NSLog("===initFetchedResultsController===")
        if (self.fetchedResultsController != nil && segmentedControlChange == false) {
            NSLog("===1===")
            return self.fetchedResultsController!
        }
        else if segmentedControlChange == true {
            segmentedControlChange = false;
        }
        NSLog("===2===")
        // 创建一个获取数据的实例，用来查询实体
        var fetchRequest = NSFetchRequest()
        if segmentedControl.selectedSegmentIndex == 0 {
            entityName = "SurfaceData"
        }
        else if segmentedControl.selectedSegmentIndex == 1 {
            entityName = "LineData"
        }
        var entity = cdControl.EntityDescription(entityName)
        fetchRequest.entity = entity
        
        // 创建排序规则
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        var authorDescriptor = NSSortDescriptor(key: "timeS", ascending: false)
        var titleDescriptor = NSSortDescriptor(key: "adrS", ascending: true)
        var sortDescriptors = [authorDescriptor, titleDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        
        // 创建获取数据的控制器，将section的name设置为author，可以直接用于tableViewSourceData
        var fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: cdControl.cdh.managedObjectContext, sectionNameKeyPath: "adrS", cacheName: "Root")
        fetchedResultsController.delegate = self
        self.fetchedResultsController = fetchedResultsController
        return fetchedResultsController
    }
    
    //通知控制器即将开始处理一个或多个的单元格变化，包括添加、删除、移动或更新。在这里处理变化时对tableView的影响，例如删除sqlite数据时同时要删除tableView中对应的单元格
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        NSLog("==didChangeObject=="+type.rawValue.description)
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
        NSLog("==didChangeSection=="+type.rawValue.description)
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
   
    
    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        //明细查询页面
        if (segue.identifier == "Detail") {
            NSLog("Detail go")
            //将所选择的当前数据赋值给所打开页面的控制器
            var secondViewDetailController = segue.destinationViewController as! SecondViewDetailController
            var currentRow = tableView.indexPathForSelectedRow()
            if segmentedControl.selectedSegmentIndex == 0 {
                var surfacedata = self.fetchedResultsController?.objectAtIndexPath(currentRow!)as! SurfaceData
                secondViewDetailController.surfacedata = surfacedata
                secondViewDetailController.nowData = "surfacedata"}
            else if segmentedControl.selectedSegmentIndex == 1 {
                var linedata = self.fetchedResultsController?.objectAtIndexPath(currentRow!)as! LineData
                secondViewDetailController.linedata = linedata
                secondViewDetailController.nowData = "linedata"}
        }
    }
        

}

