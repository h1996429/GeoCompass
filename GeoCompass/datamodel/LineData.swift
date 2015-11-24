//
//  LineData.swift
//  
//
//  Created by 何嘉 on 15/11/1.
//
//

import Foundation
import CoreData
import MapKit


@objc(LineData)
class LineData: NSManagedObject,MKAnnotation {

    @NSManaged var adrS: String
    @NSManaged var hightErrorS: NSNumber
    @NSManaged var hightS: NSNumber
    @NSManaged var id: NSNumber
    @NSManaged var imageS: NSData
    @NSManaged var latS: NSNumber
    @NSManaged var locErrorS: NSNumber
    @NSManaged var lonS: NSNumber
    @NSManaged var magErrorS: NSNumber
    @NSManaged var pitchS: NSNumber
    @NSManaged var pluangS: NSNumber
    @NSManaged var plusynS: NSNumber
    @NSManaged var strikeS: NSNumber
    @NSManaged var timeS: NSDate
    @NSManaged var describeS: NSString

    
    //returning the coordinate so as to conform to MKAnnotation protocol
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latS as Double, longitude: lonS as Double)
    }
    
    var whoAmI = "linedata"

    
    //转60进制
    func transloc(a:Double)->(b:Int,c:Int,d:Double){
        var b = 0,c = 0,d = 0.0,last1 = 0.0,last2 = 0.0;
        last1 = a-Double(Int(a));
        b = Int(a);
        last2 = (last1*60)-Double(Int(last1*60));
        c = Int(last1*60);
        d = last2*60;
        return (b,c,d);
    }
    
    var title: String? {
        return "线构造\(plusynS)°∠\(pluangS)°"
    }
    
    var subtitle: String? {
        var R = transloc(latS as Double);
        let lat = "\(R.b)" + "°" + "\(R.c)" + "'" + (R.d).format(".2")
        R = transloc(lonS as Double);
        let lon = "\(R.b)" + "°" + "\(R.c)" + "'" + (R.d).format(".2")
        return (lat+"\""+","+lon+"\"")
    }
    
    var fileManager = NSFileManager.defaultManager()
    var dir:String? {return NSHomeDirectory()+"/Documents/"+"线状构造/"+adrS+"/纬度"+"\(latS as Double)"+"经度"+"\(lonS as Double)"+"/Photos/"}
    var dateFormatter = NSDateFormatter()
    
    var photoExsist:Bool {
        return fileManager.fileExistsAtPath(dir!)
    }
    var photoPath: String {
        if ((fileManager.subpathsAtPath(dir!)?.count)! == 0) {
            return "defaultPhoto2.png"
        }
        else {
            dateFormatter.dateFormat = "yyyy-MM-dd HH时mm分";
            return dir!+"\(dateFormatter.stringFromDate(timeS)) 0"
        }
    }

}


