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
    lazy var lat = 0.0 , lon = 0.0 , hight = 0.0 , locError = 0.0 , hightError = 0.0 , magError = 0.0 ;
    lazy var northV = Vector3(0,0,0);
    
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
            self.labelH.text = (self.hight).format(".2")+"m";
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
        self.northV = Vector3(self.locationManager.heading.x,self.locationManager.heading.y,self.locationManager.heading.z);
        self.plusyn =  self.locationManager.heading.trueHeading;
        
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
                

                var dipV = Vector3(gravityX,gravityY,0);
                let n_downV = Vector3(gravityX,gravityY,gravityZ).normalized();
                var hplane_dipV   = dipV - n_downV * ( n_downV.dot(dipV  ) );
                var hplane_northV = self!.northV - n_downV * ( n_downV.dot(self!.northV) );
                hplane_dipV = Vector3(hplane_dipV.x,hplane_dipV.y,hplane_dipV.z).normalized();
                hplane_northV = Vector3(hplane_northV.x,hplane_northV.y,hplane_northV.z).normalized();
                var cp = Vector3(hplane_dipV.x,hplane_dipV.y,hplane_dipV.z).cross(hplane_northV);
                var dp = Vector3(hplane_dipV.x,hplane_dipV.y,hplane_dipV.z).dot(hplane_northV);
                var len = cp.length; // get length of vector
                cp = cp/len; // normalize
                var dipDirection = acos(dp/((hplane_dipV.length)*(hplane_northV.length))); // now we have the angle
                // now we want whether or not the cross product is in the same direction or the opposite of g, telling us the sign of the angle!
                dipDirection *= -(n_downV.dot(cp));
                if(dipDirection < 0){
                    dipDirection += 2*M_PI;}
                
                
            
                
                switch self!.index
                {
                case 0:
                    self!.dipdir = dipDirection*(180/M_PI)+self!.magError;
                    self!.strike = dipDirection*(180/M_PI)+self!.magError - 90.0;
                    if(self!.strike < 0){self!.strike += 360;}
                    if(dipangle < 0){self!.dip = 90+dipangle;}
                    else{self!.dip = 90-dipangle;}
                    
                    
                    
                case 1:
                    self!.strike = dipDirection*(180/M_PI)+self!.magError - 90.0;
                    if(self!.strike < 0){self!.strike += 360;}
                    
                    self!.pitch = (atan2(gravityY, gravityX))/M_PI*180.0;
                    if(self!.pitch < 0){self!.pitch = -self!.pitch};
                    if(self!.pitch > 90){self!.pitch = 180 - self!.pitch};
                    
                    //var plusynlevel = Vector3(0,gravityY,-gravityZ).normalized();
                    //var plusynbasic = (Vector3(0,gravityY,-gravityZ).normalized()).dot(self!.northV.normalized());
                    //self!.plusyn = acos(plusynbasic/((plusynlevel.length)*(self!.northV.length)))*(180/M_PI);
                    
                    var calpitch:Double = cos(self!.pitch/(180/M_PI));
                    var calplusyn:Double = (self!.plusyn - self!.strike)/(180/M_PI);
                    self!.pluang =  acos(calpitch/calplusyn)*(180/M_PI);
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
                        self!.labelA.text = (self!.strike).format(".2")+"°";
                        self!.label2.text = "侧俯角";
                        self!.labelB.text = (self!.pitch).format(".2")+"°";
                        self!.label3.text = "倾伏向";
                        self!.labelC.text = (self!.plusyn).format(".2")+"°";
                        self!.label4.text = "倾伏角";
                        self!.labelD.text = (self!.pluang).format(".2")+"°";
                        self!.arrow.transform=CGAffineTransformMakeRotation(CGFloat(angle));
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

