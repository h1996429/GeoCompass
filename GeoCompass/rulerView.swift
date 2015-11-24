//
//  LengthMeasureView.swift
//  mici18
//
//  Created by DavidLeeeeeeee  on 15/1/27.
//  Copyright (c) 2015年 ALN. All rights reserved.
//

import UIKit

class rulerView: UIView {
    var btn: UIButton?
    var btn2: UIButton?
    var btn3: UIButton?
    var distance:UILabel?
    

    override func drawRect(rect: CGRect) {
        /********************************判断设备********************************/
        var lengthOfPer:CGFloat = 0.0
        let height = UIScreen.mainScreen().applicationFrame.size.height
        if (height<716){
            lengthOfPer = 0.078*2
        }else{
            lengthOfPer = 0.06634*3
        }
        /********************************绘图**********************************/
        let context:CGContextRef = UIGraphicsGetCurrentContext()!
        UIColor.blackColor().setStroke()
        CGContextSetLineWidth(context, 1.0)
        let s = height*lengthOfPer
        for var i:CGFloat = 0; i < s+1; i++  {//一个i代表一毫米
            /********************************画刻度********************************/
            if(i%5==0){
                if(i%10==0){//10mm处
                    CGContextMoveToPoint(context, 0, i/lengthOfPer+20);
                    CGContextAddLineToPoint(context, 40, i/lengthOfPer+20);
                    //文字
                    let cm:UILabel = UILabel(frame: CGRectMake(40, i/lengthOfPer+10, 40, 20))
                    cm.text = "\(i/10)cm"
                    cm.font=UIFont.systemFontOfSize(12)
                    self.addSubview(cm)
                }else{//5mm处
                    CGContextMoveToPoint(context, 0, i/lengthOfPer+20);
                    CGContextAddLineToPoint(context, 35, i/lengthOfPer+20);
                }
            }else{//1mm处
                CGContextMoveToPoint(context, 0, i/lengthOfPer+20);
                CGContextAddLineToPoint(context, 25, i/lengthOfPer+20);
            }
            
        }
        CGContextStrokePath(context);
    }
    
    
    
    
    
    /********************************手势响应********************************/
    
    
    
    func handlePan(recognizer:UIPanGestureRecognizer) {
        switch recognizer.state {
            /********************************开始滑动********************************/
        case .Began:
            //判断开始触摸的点位置，如果y在两条线中间的上部分，则控制btn,如果y落在下部分，则控制btn2
            //将需要控制的button交给btn3，统一操作btn3
            if(recognizer.locationInView(self).y<=(btn!.frame.origin.y+btn2!.frame.origin.y)*0.5){
                btn3 = btn
            }else{
                btn3 = btn2
            }
            /********************************滑动过程中********************************/
        case .Changed:
            if(btn3==btn){
                if(recognizer.translationInView(self).y+btn!.frame.origin.y>btn2!.frame.origin.y){
                    return
                }
            }else{
                if(recognizer.translationInView(self).y+btn2!.frame.origin.y<btn!.frame.origin.y){
                    return
                }
            }
            //计算单位坐标的实际长度
            var lengthOfPer:CGFloat = 0.0
            let height = UIScreen.mainScreen().applicationFrame.size.height
            if (height<716){
                lengthOfPer = 0.078*2
            }else{
                lengthOfPer = 0.06634*3
            }
            //计算两线直接的距离
            distance?.text = "\(round((btn2!.frame.origin.y-btn!.frame.origin.y)*lengthOfPer*100)/100)mm"
        default:
            return
        }
        let translation:CGPoint = recognizer.translationInView(self)
        btn3?.center = CGPointMake(btn3!.center.x, btn3!.center.y + translation.y)
        recognizer.setTranslation(CGPointMake(0, 0), inView: self)
    }
    /********************************自定义的UIView需要把约束写在此函数********************************/
    override func updateConstraints() {
        struct StaticStruct {
            static var predicate : dispatch_once_t = 0
            
        }
        dispatch_once(&StaticStruct.predicate){ () -> Void in
            /********************************初始化工作只能执行一次********************************/
            self.btn = UIButton()
            self.btn?.translatesAutoresizingMaskIntoConstraints = false
            self.btn?.backgroundColor = UIColor.blackColor()
            self.addSubview(self.btn!)
            
            self.btn2 = UIButton()
            self.btn2?.translatesAutoresizingMaskIntoConstraints = false
            self.btn2?.backgroundColor = UIColor.blackColor()
            self.addSubview(self.btn2!)
            
            self.distance = UILabel(frame: CGRectMake(250, -20, 60, 20))
            self.distance?.font=UIFont.systemFontOfSize(12)
            self.btn2?.addSubview(self.distance!)
            let panGestureRecognizer:UIPanGestureRecognizer=UIPanGestureRecognizer(target: self, action: "handlePan:")
            self.addGestureRecognizer(panGestureRecognizer)
        }
        
        
        //距顶部100
        //距父view左右边为0
        //高度固定为2
        if let b = btn {//保证btn不为nil,为nil则不执行
            self.addConstraint(NSLayoutConstraint(item: b, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: 100))
            self.addConstraint(NSLayoutConstraint(item: b, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Leading, multiplier: 1, constant: 0))
            self.addConstraint(NSLayoutConstraint(item: b, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Trailing, multiplier: 1, constant: 0))
            b.addConstraint(NSLayoutConstraint(item: b, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 2))
        }
        //距顶部300
        //距父view左右边为0
        //高度固定为2
        if let b = btn2 {
            self.addConstraint(NSLayoutConstraint(item: b, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: 300))
            self.addConstraint(NSLayoutConstraint(item: b, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Leading, multiplier: 1, constant: 0))
            self.addConstraint(NSLayoutConstraint(item: b, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Trailing, multiplier: 1, constant: 0))
            b.addConstraint(NSLayoutConstraint(item: b, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 2))
        }
        
        
        super.updateConstraints()
    }
}
