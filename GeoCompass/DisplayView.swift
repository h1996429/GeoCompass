//
//  DisplayView.swift
//  PhotoBrowser
//
//  Created by 冯成林 on 15/8/14.
//  Copyright (c) 2015年 冯成林. All rights reserved.
//

import UIKit

class DisplayView: UIView {

    var needDelete = false

    var tapedImageV: ((index: Int)->())?
    
    var imageCount = 0
    var goux:[CGFloat] = []
    var gouy:[CGFloat] = []
    var gouNumber = 0
    var needGou:[Bool]=[]
    

}


extension DisplayView{
    
    /** 准备 */
    func imgsPrepare(imgs: [String], isLocal: Bool){
        imageCount = imgs.count
        gouNumber = 0
        goux = []
        gouy = []
        needGou = []
        for (var i=0; i<imgs.count; i++){
            
            let imgV = UIImageView(frame: CGRectMake(0, 0, 200, 200))
            imgV.backgroundColor = UIColor.lightGrayColor()
            imgV.userInteractionEnabled = true
            imgV.contentMode = UIViewContentMode.ScaleAspectFill
            imgV.clipsToBounds = true
            imgV.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "tapAction:"))
            imgV.tag = i
            needGou.append(false)
            if isLocal {
                imgV.image = UIImage(contentsOfFile: imgs[i])
            }else{
                imgV.hnk_setImageFromURL(NSURL(string: imgs[i])!)
            }
            self.addSubview(imgV)
        }
    }
    
    
    func tapAction(tap: UITapGestureRecognizer){
        if needDelete == false {
            tapedImageV?(index: tap.view!.tag)}
        else{
            self.needGou[tap.view!.tag] = !self.needGou[tap.view!.tag]
            let gouV = UIImageView(image: UIImage(named:"勾"))
            gouV.tag = tap.view!.tag
            self.addSubview(gouV)

        }
    }

    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        var totalRow:Int = 0
        var yShift:CGFloat = 0
        
        if imageCount<=9 {
            totalRow = 3}
        else if imageCount>9 {
            totalRow = 3
            yShift = 50}
        else if imageCount>=12 {
            totalRow = 4}
        else if imageCount>16 {
            totalRow = 4
            yShift = 25}

        let totalWidth = self.bounds.size.width
        
        let margin: CGFloat = 10
        let itemWH = (totalWidth - margin * CGFloat(totalRow + 1)) / CGFloat(totalRow)
        /** 数组遍历 */
        var i=0
        for view in self.subviews{
            if i < imageCount {
            let row = i / totalRow
            let col = i % totalRow
            
            let x = ((CGFloat(col) + 1) * margin + CGFloat(col) * itemWH)
            let y = ((CGFloat(row) + 1) * margin + CGFloat(row) * itemWH) - yShift
                if gouNumber < imageCount {
                self.goux.append(x+itemWH/3)
                self.gouy.append(y+itemWH/3)
                self.gouNumber++}
            let frame = CGRectMake(x, y, itemWH, itemWH)
                view.frame = frame}
            else {
                    view.frame.origin = CGPoint(x:self.goux[view.tag],y:self.gouy[view.tag])
                    if self.needGou[view.tag] == false {view.hidden = true}
                    else{view.hidden = false}
                  }
            i++
            }
    }
}