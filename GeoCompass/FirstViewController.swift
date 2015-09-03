//
//  FirstViewController.swift
//  GeoCompass
//
//  Created by 何嘉 on 15/9/3.
//  Copyright (c) 2015年 何嘉. All rights reserved.
//

import UIKit
import CoreMotion

var strike = 0.00 , dip = 0.00 , dipdir = 0.00 , cefujiao = 0.00 , qingfujiao = 0.00 , qingfuxiang = 0.00;

class FirstViewController: UIViewController {
    
    let manager = CMMotionManager();
    
    override func viewDidLoad() {
        super.viewDidLoad();
        // Do any additional setup after loading the view, typically from a nib.

        if manager.gyroAvailable {
            manager.deviceMotionUpdateInterval = 0.1;
            let queue = NSOperationQueue();
            manager.startDeviceMotionUpdatesToQueue(queue) {
                [weak self] (data: CMDeviceMotion!, error: NSError!) in
                // motion processing here
                NSOperationQueue.mainQueue().addOperationWithBlock {
                    // update UI here
 
                }
            }

        }
        
    }
    
    func DataCal0(){
        
        
        
    }
    func DataCal1(){
        
        
    }
   
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    @IBAction func indexChange(sender: UISegmentedControl) {
        switch segmentedControl.selectedSegmentIndex
        {
        case 0:
            self.DataCal0();
        case 1:
            self.DataCal1();
        case 2:
            manager.stopDeviceMotionUpdates();
            
        default:
            break; 
        }
    }
    


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

