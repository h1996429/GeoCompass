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
import CoreData

// MARK: == Data.plist Keys ==
let surfaceKey = "surfaceid"
let lineKey = "lineid"
// MARK: -


extension Double {
    func format(f: String) -> String {
        return NSString(format: "%\(f)f", self) as String
    }
}


class FirstViewController: UIViewController ,CLLocationManagerDelegate{
    

    
    lazy var strike = 0.0 , dipdir = 0.0 , dip = 0.0;
    lazy var pitch = 0.0 , plusyn = 0.0 , pluang = 0.0; //pitch、plunging syncline and plunge angle
    lazy var strikeFS = 0.0 , dipdirFS = 0.0 , dipFS = 0.0;
    lazy var pitchFS = 0.0 , plusynFS = 0.0 , pluangFS = 0.0;
    
    lazy var lat = 0.0 , lon = 0.0 , hight = 0.0 , locError = 0.0 , hightError = 0.0 , magError = 0.0 ;
    lazy var latFS = 0.0 , lonFS = 0.0 , hightFS = 0.0 , locErrorFS = 0.0 , hightErrorFS = 0.0 , magErrorFS = 0.0 ;


    lazy var northV = Vector3(0,0,0);
    

    
    lazy var adr = "网络未连接，无地址";
    lazy var adrFS = "网络未连接，无地址";

    
    lazy var index = 0;
    lazy var needSave = 0;
    lazy var requestauthorization = false ;
    
    
    
    let manager = CMMotionManager();
    let locationManager:CLLocationManager = CLLocationManager();
    
    
    let cdControl = NewsCoreDataController();
    
    var surfaceidID: AnyObject = 0
    var lineidID: AnyObject = 0


    
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

    @IBAction func saveData(sender: AnyObject) {
        if segmentedControl.selectedSegmentIndex != 2 {
            var alertView = UIAlertView(title: "提示！", message: "请先按下保持“保持数据”再点击“保存数据”", delegate: self, cancelButtonTitle: "确定")
            alertView.show()
        }
            
        else if segmentedControl.selectedSegmentIndex == 2 {
            var time:NSDate = NSDate();
            loadData();
            switch needSave{
            case 0:
                var surfacedata:SurfaceData = cdControl.insertForEntityWithName("SurfaceData") as! SurfaceData;
                surfaceidID=(surfaceidID as! Double)+1;
                surfacedata.id=surfaceidID as! NSNumber;
                surfacedata.timeS=time;
                surfacedata.strikeS=strikeFS;
                surfacedata.dipdirS=dipdirFS;
                surfacedata.dipS=dipFS;
                surfacedata.latS=latFS;
                surfacedata.lonS=lonFS;
                surfacedata.hightS=hightFS;
                surfacedata.locErrorS=locErrorFS;
                surfacedata.hightErrorS=hightErrorFS;
                surfacedata.magErrorS=magErrorFS;
                surfacedata.adrS=adrFS;

                cdControl.save();
            
                saveData();
                
            case 1:
                var linedata:LineData = cdControl.insertForEntityWithName("LineData") as! LineData;
                lineidID=(lineidID as! Double)+1;
                linedata.id=surfaceidID as! NSNumber;
                linedata.timeS=time;
                linedata.strikeS=strikeFS;
                linedata.pitchS=pitchFS;
                linedata.plusynS=plusynFS;
                linedata.pluangS=pluangFS;
                linedata.latS=latFS;
                linedata.lonS=lonFS;
                linedata.hightS=hightFS;
                linedata.locErrorS=locErrorFS;
                linedata.hightErrorS=hightErrorFS;
                linedata.magErrorS=magErrorFS;
                linedata.adrS=adrFS;

                cdControl.save();
                saveData();

            default:
                break;
            }
            
            
        }
        
 
    }
    
    
    @IBAction func indexchange(sender: UISegmentedControl) {
        switch segmentedControl.selectedSegmentIndex
        {
        case 0:
            index = 0;
            needSave = 0;
        case 1:
            index = 1;
            needSave = 1;
        case 2:
            index = 2;
        default:
            break; 
        }
    }
    
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!){

        var location:CLLocation = locations[locations.count-1] as! CLLocation
        
        let thelocations:NSArray = locations as NSArray
        let curlocation:CLLocation = thelocations.objectAtIndex(0) as! CLLocation
        var geocoder:CLGeocoder = CLGeocoder()
        var placemarks:NSArray?
        var error:NSError?
        geocoder.reverseGeocodeLocation(curlocation, completionHandler:{(placemarks,error) in
            print(placemarks.count)
            if error != nil {
                self.adr = "网络连接中断，无法获取此地名称。";
            }
            if (error == nil && placemarks.count >= 0){
                var placemark:CLPlacemark = (placemarks as NSArray).objectAtIndex(0) as! CLPlacemark
                self.adr = "\(placemark.name)";

            }
        })
        
        if (location.horizontalAccuracy > 0) {
            self.locationManager.stopUpdatingLocation();
            self.lat = location.coordinate.latitude;
            self.lon = location.coordinate.longitude;
            self.hight = location.altitude;
            self.locError = location.horizontalAccuracy;
            self.hightError = location.verticalAccuracy;
            
            
            var R = transloc(self.lat);
            self.labelLat.text = "\(R.b)" + "°" + "\(R.c)" + "'" + (R.d).format(".4") + "\"";
            R = transloc(self.lon);
            self.labelLon.text = "\(R.b)" + "°" + "\(R.c)" + "'" + (R.d).format(".4") + "\"";
            self.labelH.text = (self.hight).format(".2")+"m";
            self.labelLonE.text = "±"+(self.locError).format(".1")+"m";
            self.labelLatE.text = "±"+(self.locError).format(".1")+"m";
            self.labelHE.text = "±"+(self.hightError).format(".1")+"m";
            self.labelAdr.text = adr;

            
        }
    }//get lat、lon and hight。
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        println(error)
        self.labelLat.text = "设备接收卫星数量不足"
        self.labelLon.text = "或GPS信号接收异常"
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
                        self!.strikeFS = self!.strike;
                        self!.dipdirFS = self!.dipdir;
                        self!.dipFS = self!.dip;
                        self!.pitchFS = self!.pitch;
                        self!.plusynFS = self!.plusyn;
                        self!.pluangFS = self!.pluang;
                        self!.latFS = self!.lat;
                        self!.lonFS = self!.lon;
                        self!.hightFS = self!.hight;
                        self!.locErrorFS = self!.locError;
                        self!.hightErrorFS = self!.hightError;
                        self!.magErrorFS = self!.magError;
                        self!.adrFS = self!.adr;

                    default:
                        break; 
                    }

                    
 
                }
            }

        }
        
    }
    
    func loadData() {
        // getting path to Data.plist
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true) as NSArray
        let documentsDirectory = paths[0] as! String
        let path = documentsDirectory.stringByAppendingPathComponent("Data.plist")
        let fileManager = NSFileManager.defaultManager()
        //check if file exists
        if(!fileManager.fileExistsAtPath(path)) {
            // If it doesn't, copy it from the default file in the Bundle
            if let bundlePath = NSBundle.mainBundle().pathForResource("Data", ofType: "plist") {
                let resultDictionary = NSMutableDictionary(contentsOfFile: bundlePath)
                println("Bundle Data.plist file is --> \(resultDictionary?.description)")
                fileManager.copyItemAtPath(bundlePath, toPath: path, error: nil)
                println("copy")
            } else {
                println("Data.plist not found. Please, make sure it is part of the bundle.")
            }
        } else {
            println("Data.plist already exits at path.")
            // use this to delete file from documents directory
            //fileManager.removeItemAtPath(path, error: nil)
        }
        let resultDictionary = NSMutableDictionary(contentsOfFile: path)
        println("Loaded Data.plist file is --> \(resultDictionary?.description)")
        var myDict = NSDictionary(contentsOfFile: path)
        if let dict = myDict {
            //loading values
            surfaceidID = dict.objectForKey(surfaceKey)!
            lineidID = dict.objectForKey(lineKey)!
            //...
        } else {
            println("WARNING: Couldn't create dictionary from Data.plist! Default values will be used!")
        }
    }
    
    func saveData() {
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true) as NSArray
        let documentsDirectory = paths.objectAtIndex(0) as! NSString
        let path = documentsDirectory.stringByAppendingPathComponent("Data.plist")
        var dict: NSMutableDictionary = ["XInitializerItem": "DoNotEverChangeMe"]
        //saving values
        dict.setObject(surfaceidID, forKey: surfaceKey)
        dict.setObject(lineidID, forKey: lineKey)
        //...
        //writing to Data.plist
        dict.writeToFile(path, atomically: false)
        let resultDictionary = NSMutableDictionary(contentsOfFile: path)
        println("Saved Data.plist file is --> \(resultDictionary?.description)")
    }



    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.

            // Add code to preserve data stored in the views that might be
            // needed later.
            
            // Add code to clean up other strong references to the view in
            // the view hierarchy.
        
    }
    
}

