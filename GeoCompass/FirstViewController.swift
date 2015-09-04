//
//  FirstViewController.swift
//  GeoCompass
//
//  Created by 何嘉 on 15/9/3.
//  Copyright (c) 2015年 何嘉. All rights reserved.
//

import UIKit
import CoreMotion


extension Double {
    func format(f: String) -> String {
        return NSString(format: "%\(f)f", self) as String
    }
}


class FirstViewController: UIViewController {
    lazy var strike = 0.0 , dipdir = 0.0 , dip = 0.0;
    lazy var pitch = 0.0 , plusyn = 0.0 , pluang = 0.0; //pitch、plunging syncline and plunge angle
    lazy var index = 0;
    
    lazy var Sstrike = 0.0 , Sdipdir = 0.0 , Sdip = 0.0;
    lazy var Spitch = 0.0 , Splusyn = 0.0 , Spluang = 0.0;// data for saving
    
    let manager = CMMotionManager();
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var label1: UILabel!
    @IBOutlet weak var labelA: UILabel!
    @IBOutlet weak var label2: UILabel!
    @IBOutlet weak var labelB: UILabel!
    @IBOutlet weak var label3: UILabel!
    @IBOutlet weak var labelC: UILabel!
    @IBOutlet weak var label4: UILabel!
    @IBOutlet weak var labelD: UILabel!
    
    @IBAction func indexchange(sender: UISegmentedControl) {
        switch segmentedControl.selectedSegmentIndex
        {
        case 0:
            index = 0;
        case 1:
            index = 1;
        case 2:
            index = 2;
        default:
            break; 
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad();
        // Do any additional setup after loading the view, typically from a nib.

       if manager.gyroAvailable {
            manager.deviceMotionUpdateInterval = 0.1;
            let queue = NSOperationQueue();
            manager.startDeviceMotionUpdatesToQueue(queue) {
                [weak self] (data: CMDeviceMotion!, error: NSError!) in
                // motion processing here
                data.attitude.multiplyByInverseOfAttitude(self!.manager.deviceMotion.attitude)
                
                var gravityX = self!.manager.deviceMotion.gravity.x;
                var gravityY = self!.manager.deviceMotion.gravity.y;
                var gravityZ = self!.manager.deviceMotion.gravity.z;
                var dipangel = (atan2(gravityZ,sqrt(gravityX*gravityX+gravityY*gravityY)))/M_PI*180.0;
                
                switch self!.index
                {
                case 0:

                    if(self!.dipdir < 0){
                        self!.dipdir += 2*M_PI;}
                    self!.strike = self!.dipdir*(180/M_PI) - 90.0;
                    if(self!.strike < 0){self!.strike += 360;}
                    if(dipangel < 0){self!.dip = 90+dipangel;}
                    else{self!.dip = 90-dipangel;}
                    
                case 1:
                    self!.strike = self!.manager.deviceMotion.attitude.roll ?? 0 ;
                case 2:
                    break;
                default:
                    break;
                }

                
                NSOperationQueue.mainQueue().addOperationWithBlock {
                    // update UI here
                    switch self!.index
                    {
                    case 0:
                        self!.label1.text = "走向";                        self!.labelA.text = (self!.strike).format(".2")
                        self!.label2.text = "倾向";
                        self!.label3.text = "倾角";
                        self!.labelC.text = (self!.dip).format(".2")
                        self!.label4.text = "";
                        self!.labelD.text = "";


                    case 1:
                        self!.label1.text = "走向";
                        self!.label2.text = "侧俯角";
                        self!.label3.text = "倾伏向";
                        self!.label4.text = "倾伏角";
                    case 2:
                        break;
                    default:
                        break; 
                    }

                    
 
                }
            }

        }
        
    }
    

    


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

