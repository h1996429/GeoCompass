//
//  SecondViewImageController.swift
//  GeoCompass
//
//  Created by 何嘉 on 15/11/9.
//  Copyright (c) 2015年 何嘉. All rights reserved.
//

import Foundation
import UIKit

class SecondViewImageController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.view.backgroundColor = UIColor.whiteColor()
        
        self.navigationItem.title = langType == LangType.Chinese ? "照片" : "Photo"
        
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
    
    lazy var localImages: [String] = {["1.jpg","2.jpg","3.jpg","4.jpg","5.jpg","6.jpg","7.jpg","8.jpg","9.jpg"]}()
    
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
        for (var i=0; i<9; i++){
            
            let model = PhotoBrowser.PhotoModel(localImg:UIImage(named: "\(i+1).jpg")! , titleStr: title, descStr:desc[0], sourceView: displayView.subviews[i] )
            
            models.append(model)
        }
        
        /**  设置数据  */
        pbVC.photoModels = models
        
        pbVC.show(inVC: self,index: index)
    }

    
      
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
