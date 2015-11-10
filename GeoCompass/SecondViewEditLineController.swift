//
//  SecondViewEditController.swift
//  GeoCompass
//
//  Created by 何嘉 on 15/11/4.
//  Copyright (c) 2015年 何嘉. All rights reserved.
//

import UIKit

class SecondViewEditLineController: UIViewController{
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var textField: UITextField!
    
    var dateFormatter = NSDateFormatter()
    var editedObject: LineData!
    var editedFieldKey: String!
    var editedFieldName: String!
    var editingDate: Bool!{
        get{
            //判断是否是日期字段
            let attributeClassName = self.editedObject.entity.attributesByName[self.editedFieldKey]?.attributeValueClassName
            if (attributeClassName! == "NSDate") {
                return true
            }
            else {
                return false
            }
        }
    }
    var editingNumber: Bool!{
        get{
            //判断是否是数字字段
            let attributeClassName = self.editedObject.entity.attributesByName[self.editedFieldKey]?.attributeValueClassName
            if (attributeClassName! == "NSNumber") {
                return true
            }
            else {
                return false
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //为标题赋值
        self.title = self.editedFieldName
        //如果选中日期，则显示日期控件
        if (self.editingDate == true) {
            self.textField.hidden = true
            self.datePicker.hidden = false
            
            var date = self.editedObject.valueForKey(self.editedFieldKey) as? NSDate
            if date == nil {
                date = NSDate()
            }
            self.datePicker.date = date!
        }
        else if(self.editingNumber == true) {
            self.textField.hidden = false
            self.datePicker.hidden = true
            self.textField.text = "\(self.editedObject.valueForKey(self.editedFieldKey) as! Double)"
            self.textField.placeholder = self.title//空的时候显示值
            self.textField.becomeFirstResponder()
        }
        else {
            self.textField.hidden = false
            self.datePicker.hidden = true
            self.textField.text = self.editedObject.valueForKey(self.editedFieldKey) as? String
            self.textField.placeholder = self.title//空的时候显示值
            self.textField.becomeFirstResponder()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //点击保存
    @IBAction func saveAction(sender: AnyObject) {
        // Set the action name for the undo operation.给撤回操作设置name
        NSLog("==saveAction==\(self.editedFieldName)")
        let undoManager = self.editedObject.managedObjectContext?.undoManager
        undoManager?.setActionName(self.editedFieldName)
        
        //更新该对象，然后抛出
        if self.editingDate! {
            self.editedObject.setValue(self.datePicker.date, forKey:self.editedFieldKey)
        }
        else if self.editingNumber! {
            self.editedObject.setValue((self.textField.text! as NSString).doubleValue, forKey:self.editedFieldKey)
        }
        else {
            self.editedObject.setValue(self.textField.text, forKey:self.editedFieldKey)
        }
        
        self.navigationController?.popViewControllerAnimated(true)
    }
}

