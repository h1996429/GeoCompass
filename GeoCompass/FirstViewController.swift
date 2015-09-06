//
//  FirstViewController.swift
//  GeoCompass
//
//  Created by 何嘉 on 15/9/3.
//  Copyright (c) 2015年 何嘉. All rights reserved.
//

import UIKit
import CoreMotion
import CoreLocation


extension Double {
    func format(f: String) -> String {
        return NSString(format: "%\(f)f", self) as String
    }
}


class FirstViewController: UIViewController ,CLLocationManagerDelegate{
    lazy var strike = 0.0 , dipdir = 0.0 , dip = 0.0;
    lazy var pitch = 0.0 , plusyn = 0.0 , pluang = 0.0; //pitch、plunging syncline and plunge angle
    lazy var lat = 0.0 , lon = 0.0 , hight = 0.0 , locError = 0.0 , hightError = 0.0 , magError = 0.0;
    
    lazy var index = 0;
    lazy var requestauthorization = false ;
    
    lazy var Sstrike = 0.0 , Sdipdir = 0.0 , Sdip = 0.0;
    lazy var Spitch = 0.0 , Splusyn = 0.0 , Spluang = 0.0;
    lazy var Slat = 0.0 , Slon = 0.0 , Shight = 0.0 , SlocError = 0.0 , ShightError = 0.0 , SmagError = 0.0;// data for saving
    
    let manager = CMMotionManager();
    let locationManager:CLLocationManager = CLLocationManager();
    
    @IBOutlet weak var arrow: UIImageView!
    
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var label1: UILabel!
    @IBOutlet weak var labelA: UILabel!
    @IBOutlet weak var label2: UILabel!
    @IBOutlet weak var labelB: UILabel!
    @IBOutlet weak var label3: UILabel!
    @IBOutlet weak var labelC: UILabel!
    @IBOutlet weak var label4: UILabel!
    @IBOutlet weak var labelD: UILabel!
    
    @IBOutlet weak var labelLat: UILabel!
    @IBOutlet weak var labelLon: UILabel!
    @IBOutlet weak var labelH: UILabel!
    @IBOutlet weak var labelLatE: UILabel!
    @IBOutlet weak var labelLonE: UILabel!
    @IBOutlet weak var labelHE: UILabel!
    @IBOutlet weak var labelAdr: UILabel!
    @IBOutlet weak var labelDec: UILabel!
 
    @IBOutlet weak var labelDecText: UILabel!
    
    
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
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!){
        
        var location:CLLocation = locations[locations.count-1] as! CLLocation
        
        if (location.horizontalAccuracy > 0) {
            self.locationManager.stopUpdatingLocation();
            self.lat = location.coordinate.latitude;
            self.lon = location.coordinate.longitude;
            self.hight = location.altitude;
            self.locError = location.horizontalAccuracy;
            self.hightError = location.verticalAccuracy;
            
            
            self.labelLat.text = "\(transloc(lat).b)" + "°" + "\(transloc(lat).c)" + "'" + (transloc(lat).d).format(".4") + "\"";
            self.labelLon.text = "\(transloc(lon).b)" + "°" + "\(transloc(lon).c)" + "'" + (transloc(lon).d).format(".4") + "\"";
            self.labelH.text = "\(self.hight)";
            self.labelLonE.text = "±"+(self.locError).format(".1")+"m";
            self.labelLatE.text = "±"+(self.locError).format(".1")+"m";
            self.labelHE.text = "±"+(self.hightError).format(".1")+"m";

            
        }
    }//get lat、lon and hight。
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        println(error)
        self.labelLat.text = "卫星信号不足或GPS异常"
        self.labelLon.text = "卫星信号不足或GPS异常"
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateHeading newHeading: CLHeading!) {
        self.magError = (self.locationManager.heading.magneticHeading - self.locationManager.heading.trueHeading) ?? 0;
        
        self.labelDec.text = (self.magError).format(".2")+"°"+"(数据来源：World Magnetic Model ";
        self.labelDecText.text = "(2014-2019),美国国家海洋和大气管理局(NOAA))";
    }

    
    func transloc(a:Double)->(b:Int,c:Int,d:Double){
    var b = 0,c = 0,d = 0.0,last1 = 0.0,last2 = 0.0;
    last1 = a-Double(Int(a));
    b = Int(a);
    last2 = (last1*60)-Double(Int(last1*60));
    c = Int(last1*60);
    d = last2*60;
    return (b,c,d);
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
                
                self!.locationManager.delegate = self;
                self!.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
                if(self!.requestauthorization==false){
                if self!.locationManager.respondsToSelector("requestWhenInUseAuthorization") {
                    println("requestWhenInUseAuthorization")
                    self!.locationManager.requestWhenInUseAuthorization ()
                    self!.requestauthorization=true
                    }}
                self!.locationManager.startUpdatingLocation();
                self!.locationManager.startUpdatingHeading();
                
                data.attitude.multiplyByInverseOfAttitude(self!.manager.deviceMotion.attitude)
                
                var gravityX = self!.manager.deviceMotion.gravity.x;
                var gravityY = self!.manager.deviceMotion.gravity.y;
                var gravityZ = self!.manager.deviceMotion.gravity.z;
                var dipangle = (atan2(gravityZ,sqrt(gravityX*gravityX+gravityY*gravityY)))/M_PI*180.0;
                
                var angle = -atan2(gravityY, gravityX) + M_PI/2;
                
                switch self!.index
                {
                case 0:

                    if(self!.dipdir < 0){
                        self!.dipdir += 2*M_PI;}
                    self!.strike = self!.dipdir*(180/M_PI) - 90.0;
                    if(self!.strike < 0){self!.strike += 360;}
                    if(dipangle < 0){self!.dip = 90+dipangle;}
                    else{self!.dip = 90-dipangle;}
                    
                    
                    
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
                        self!.label1.text = "走向";
                        self!.labelA.text = (self!.strike).format(".2")+"°";
                        self!.label2.text = "倾向";
                        self!.labelB.text = (self!.dipdir).format(".2")+"°";
                        self!.label3.text = "倾角";
                        self!.labelC.text = (self!.dip).format(".2")+"°";
                        self!.label4.text = "";
                        self!.labelD.text = "";
                        self!.arrow.transform=CGAffineTransformMakeRotation(CGFloat(angle));




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

