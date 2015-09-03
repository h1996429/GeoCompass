//
//  FirstViewController.swift
//  GeoCompass
//
//  Created by 何嘉 on 15/9/3.
//  Copyright (c) 2015年 何嘉. All rights reserved.
//

import UIKit
import CoreMotion

class FirstViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let manager = CMMotionManager()
        if manager.gyroAvailable {
            manager.deviceMotionUpdateInterval = 0.1
            let queue = NSOperationQueue()
            manager.startDeviceMotionUpdatesToQueue(queue) {
                [weak self] (data: CMDeviceMotion!, error: NSError!) in
                // motion processing here
                NSOperationQueue.mainQueue().addOperationWithBlock {
                    // update UI here
                }
            }

        }
    }
    


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

