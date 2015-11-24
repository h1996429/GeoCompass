//
//  Ruler.swift
//  GeoCompass
//
//  Created by 何嘉 on 15/11/21.
//  Copyright © 2015年 何嘉. All rights reserved.
//

import Foundation
import UIKit

class RulerController: UIViewController {
    
    @IBAction func back(sender: UIButton) {
        dismissViewControllerAnimated(true, completion: {})
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}