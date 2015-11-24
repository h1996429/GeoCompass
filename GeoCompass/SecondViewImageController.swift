//
//  SecondViewImageController.swift
//  GeoCompass
//
//  Created by 何嘉 on 15/11/9.
//  Copyright (c) 2015年 何嘉. All rights reserved.
//

import UIKit

class SecondViewImageController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIActionSheetDelegate {
    var actionSheet: UIAlertController!
    var actionPhotoSheet: UIAlertController!
    var fileManagerImage = NSFileManager.defaultManager()
    var add = false
    var delet = false
    var dir:String = ""
    var sourceType = UIImagePickerControllerSourceType.PhotoLibrary
    var photoDate = ""
    var deletButton:UIBarButtonItem{
        return UIBarButtonItem(title:"删除", style:.Done, target: self, action: "deletPhotoAction:")
    }
    
    func deletPhotoAction(deletBarButton:UIBarButtonItem){
        for (var i=0;i < displayView.needGou.count;i++){
            if displayView.needGou[i] == true {
                do{try fileManagerImage.removeItemAtPath(dir+photoDate+" "+"\(i)"+".png")}catch let error as NSError{if error != 0 {abort()}}
            }
        }
        load()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //初始化
        
        self.view.backgroundColor = UIColor.whiteColor()
        
        self.navigationItem.title = langType == LangType.Chinese ? "照片" : "Photo"
        
        self.navigationItem.rightBarButtonItem = self.editButtonItem()
        self.editButtonItem().title = "编辑"
        
        
        actionSheet = UIAlertController(title: "编辑", message: "选择添加或是删除照片", preferredStyle: UIAlertControllerStyle.ActionSheet)
        // 定义 添加和删除 的 UIAlertAction
        let cancelAction = UIAlertAction(title: "取消", style: UIAlertActionStyle.Destructive){
            (action: UIAlertAction!) -> Void in
            self.navigationItem.rightBarButtonItem = self.editButtonItem()
        }
        let addAction = UIAlertAction(title: "添加", style: UIAlertActionStyle.Default){
            (action: UIAlertAction!) -> Void in
            self.setEditing(false, animated: true)
            self.presentViewController(self.actionPhotoSheet, animated: true, completion: nil)
            self.add = true
        }
        let deletAction = UIAlertAction(title: "删除", style: UIAlertActionStyle.Default){
            (action: UIAlertAction!) -> Void in
            self.displayView.needDelete = true
            self.navigationItem.leftBarButtonItem = self.deletButton
            self.delet = false
        }
        actionSheet.addAction(addAction)
        actionSheet.addAction(deletAction)
        actionSheet.addAction(cancelAction)
        
        actionPhotoSheet = UIAlertController(title: "添加照片", message: "", preferredStyle: UIAlertControllerStyle.ActionSheet)
        // 定义 拍照和相册 的 UIAlertAction
        let cancelAddAction = UIAlertAction(title: "取消", style: UIAlertActionStyle.Cancel){
            (action: UIAlertAction!) -> Void in
            self.navigationItem.rightBarButtonItem = self.editButtonItem()
        }
        let cameraAction = UIAlertAction(title: "拍照", style: UIAlertActionStyle.Default){
            (action: UIAlertAction!) -> Void in
            if(UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)){
                self.sourceType = UIImagePickerControllerSourceType.Camera
                let imagePickerController:UIImagePickerController = UIImagePickerController()
                imagePickerController.delegate = self
                imagePickerController.allowsEditing = false //true为拍照、选择完进入图片编辑模式
                imagePickerController.sourceType = self.sourceType
                self.presentViewController(imagePickerController, animated: true, completion: {})
            }
            else{let alert1 = UIAlertController(title: "错误", message: "相机不可用", preferredStyle: UIAlertControllerStyle.Alert)
                alert1.addAction(cancelAction)
                self.presentViewController(alert1, animated: true, completion: nil)}
        }
        let fromPhotoAction = UIAlertAction(title: "相册", style: UIAlertActionStyle.Default){
            (action: UIAlertAction!) -> Void in
            self.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            let imagePickerController:UIImagePickerController = UIImagePickerController()
            imagePickerController.delegate = self
            imagePickerController.allowsEditing = false //true为拍照、选择完进入图片编辑模式
            imagePickerController.sourceType = self.sourceType
            self.presentViewController(imagePickerController, animated: true, completion: {})
        }
        actionPhotoSheet.addAction(cancelAddAction)
        actionPhotoSheet.addAction(cameraAction)
        actionPhotoSheet.addAction(fromPhotoAction)
        
        load()

    }
    
    func load(){
        for view in displayView.subviews {view.removeFromSuperview()}
        self.localImages = []
        if self.fileManagerImage.subpathsAtPath(self.dir)?.count != nil {
            for f in fileManagerImage.subpathsAtPath(dir)! {self.localImages.append(dir+"\(f)")}
            if photoType == PhotoType.Local { //本地
                displayView.imgsPrepare(localImages, isLocal: true)
            }
            view.addSubview(displayView)
            
            let wh = min(UIScreen.mainScreen().bounds.size.width, UIScreen.mainScreen().bounds.size.height)
            
            displayView.make_center(offsest: CGPointZero, width: wh, height: wh)
            
            
            displayView.tapedImageV = {[unowned self] index in
                
                if self.photoType == PhotoType.Local { //本地
                    self.showLocal(index)
                }
            }
        }
    }
    
    func imagePickerControllerDidCancel(picker:UIImagePickerController) {
        self.dismissViewControllerAnimated(true, completion: nil)    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        let count = fileManagerImage.subpathsAtPath(dir)?.count ?? 0
        let data:NSData = UIImagePNGRepresentation((info[UIImagePickerControllerOriginalImage] as? UIImage)!)!
        do{try fileManagerImage.createDirectoryAtPath(dir, withIntermediateDirectories: true, attributes: nil)}catch let error as NSError { if error != 0 { abort()}}
        data.writeToFile(dir+photoDate+" "+"\(count)"+".png", atomically: true)
        self.dismissViewControllerAnimated(true, completion: nil)
        load()
        }

    enum LangType: Int{
        
        case English
        case Chinese
    }
    
    /**  展示样式  */
    enum ShowType{
        
        /**  push展示：网易新闻  */
        case Push
        
        /**  modal展示：可能有需要  */
        case Modal
        
        /**  frame放大模式：单击相册可关闭 */
        case ZoomAndDismissWithSingleTap
        
        /**  frame放大模式：点击按钮可关闭 */
        case ZoomAndDismissWithCancelBtnClick
    }
    
    
    /**  相册类型  */
    enum PhotoType{
        
        /**  本地相册  */
        case Local
        
        /**  服务器相册  */
        case Host
    }
    
    var titleLocalCH: String {return "构造照片"}
    var titleEN: String {return "Photos of structure"}
    
    
    
    var descLocalCH: [String] {
        return [
            ""

        ]
    }
    
    var descLocalEN: [String] {
        return [
            "",
        ]
    }


    var langType: LangType = LangType.Chinese
    
    var photoType: PhotoType = PhotoType.Local
    
    var showType: PhotoBrowser.ShowType = PhotoBrowser.ShowType.ZoomAndDismissWithCancelBtnClick
    
    
    var localImages: [String] = []

    
    let displayView = DisplayView()
    
    func showLocal(index: Int){

        
        
        let pbVC = PhotoBrowser()
        
        /**  设置相册展示样式  */
        pbVC.showType = showType
        
        /**  设置相册类型  */
        pbVC.photoType = PhotoBrowser.PhotoType.Local
        
        //强制关闭显示一切信息
        pbVC.hideMsgForZoomAndDismissWithSingleTap = true
        
        var models: [PhotoBrowser.PhotoModel] = []
        
        let title = langType == LangType.Chinese ? titleLocalCH : titleEN
        let desc = langType == LangType.Chinese ? descLocalCH : descLocalEN
        
        //模型数据数组
        for (var i=0; i<self.fileManagerImage.subpathsAtPath(self.dir)?.count; i++){
            
            let model = PhotoBrowser.PhotoModel(localImg:UIImage(contentsOfFile:"\(localImages[i])")! , titleStr: title, descStr:desc[0], sourceView: displayView.subviews[i] )
            
            models.append(model)
        }
        
        /**  设置数据  */
        pbVC.photoModels = models
        
            pbVC.show(inVC: self,index: index)
    }
    
    //设置为编辑模式时调用
    override func setEditing(var editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        
        self.navigationItem.setHidesBackButton(editing, animated: animated)
        
        //编辑状态时设置撤销管理器
        if(editing){
            self.editButtonItem().title = "完成"
            self.presentViewController(self.actionSheet, animated: true, completion: nil)

            if add == true {editing = false}
        }else
            //非编辑状态时取消撤销管理器并保存数据
        {   self.displayView.needDelete = false
            self.navigationItem.leftBarButtonItem = nil
            self.editButtonItem().title = "编辑"
            self.add = false
            self.delet = false
            load()
        }
    }

    
      
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
