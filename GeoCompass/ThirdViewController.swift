//
//  ThirdViewController.swift
//  GeoCompass
//
//  Created by 何嘉 on 15/9/10.
//  Copyright (c) 2015年 何嘉. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import CoreData
import QuartzCore


enum MapType: Int {
    case Standard = 0
    case Hybrid
}

class ThirdViewController: UIViewController,MKMapViewDelegate,CLLocationManagerDelegate,UITabBarControllerDelegate,NSFetchedResultsControllerDelegate {
    //显示当前
    @IBOutlet weak var adr: UILabel!
    
    @IBOutlet weak var high: UILabel!
    @IBOutlet weak var lon: UILabel!
    @IBOutlet weak var lat: UILabel!
    lazy var requestauthorization = false ;
    //测量距离
    var nowAnnotationView = MKAnnotationView()
    var numberStart = 1
    var annotationArrary: [MKAnnotation] = []
    @IBOutlet weak var rangingTip: UILabel!
    
    var measureDistanceSymbol:Int = 0
    var measureDistance:Bool = false
    var startON = false
    var endON = false
    var startCoordinate = CLLocation()
    func dropPin(gestureRecognizer: UIGestureRecognizer) {
      if UIGestureRecognizerState.Began == gestureRecognizer.state {
        let tapPoint: CGPoint = gestureRecognizer.locationInView(mapView)
        let touchMapCoordinate: CLLocationCoordinate2D = mapView.convertPoint(tapPoint, toCoordinateFromView: mapView)
        
            //initialize our Pin with our coordinates and the context from AppDelegate
            if measureDistance {
                var subTitle: String? {
                    var R = transloc(touchMapCoordinate.latitude as Double);
                    let lat = "\(R.b)" + "°" + "\(R.c)" + "'" + (R.d).format(".2")
                    R = transloc(touchMapCoordinate.longitude as Double);
                    let lon = "\(R.b)" + "°" + "\(R.c)" + "'" + (R.d).format(".2")
                    return (lat+"\""+","+lon+"\"")
                }

            if measureDistanceSymbol == 0 {
                let pin = Pin(coordinate: touchMapCoordinate, title: "起始",subtitle:subTitle!,type: AttractionType(rawValue: measureDistanceSymbol)!)
                startCoordinate = CLLocation(latitude: touchMapCoordinate.latitude, longitude: touchMapCoordinate.longitude)
                measureDistanceSymbol = measureDistanceSymbol + 1
                mapView.addAnnotation(pin)
                mapView.selectAnnotation(pin, animated: true)
                startON = true
            }
            else if measureDistanceSymbol == 1 {
                let distance = startCoordinate.distanceFromLocation(CLLocation(latitude: touchMapCoordinate.latitude, longitude: touchMapCoordinate.longitude))
                let pin = Pin(coordinate: touchMapCoordinate, title: "距离"+String(format: "%.2f",round(distance*100)/100)+"m",subtitle:subTitle!, type: AttractionType(rawValue: measureDistanceSymbol)!)
                measureDistance = false
                mapView.addAnnotation(pin)
                mapView.selectAnnotation(pin, animated: true)
                endON = true
                rangingTip.hidden = true
            }

            //add the pin to the map
            }
        }
    }
    
    
    //产状部分
    var sharedContext: NSManagedObjectContext!
    var surfacedata:SurfaceData?
    var linedata:LineData?
    var nowdata = "surfacedata"

    //航迹部分    
    var locationManager: CLLocationManager!
    
    let walkStore: WalkStore = WalkStore.sharedInstance
    let cdControl = NewsCoreDataController()
    
    var isTracking: Bool = false
    var isCompass: Bool = false
    var trackButton:UIBarButtonItem{
        return UIBarButtonItem(title:"航迹", style:.Plain, target: self, action: "trackAction:")
    }
    var toolButton:UIBarButtonItem{
        return UIBarButtonItem(title:"工具箱", style:.Plain, target: self, action: "toolAction:")
    }
    

    func trackAction(exportBarButton:UIBarButtonItem){
        let alert = UIAlertController(title: "航迹",
            message: "航迹将会自动保存",
            preferredStyle: UIAlertControllerStyle.Alert)
        let alertStop = UIAlertController(title: "航迹",
            message: "航迹将会自动保存",
            preferredStyle: UIAlertControllerStyle.Alert)
        
        let recordAction = UIAlertAction(title: "开始记录航迹",
            style: UIAlertActionStyle.Default)
            { (action: UIAlertAction!) -> Void in
                    if self.isTracking {
                        self.locationManager.stopUpdatingLocation()
                    } else {
                        self.locationManager.startUpdatingLocation()
                        self.walkStore.startWalk()
                    }
                    self.isTracking = !self.isTracking
                    self.updateDisplay()
                    self.locationManager.startUpdatingLocation()
        }
        
        let stopRecordAction = UIAlertAction(title: "停止记录航迹",
            style: UIAlertActionStyle.Default)
            { (action: UIAlertAction!) -> Void in
                    if self.isTracking {
                        self.locationManager.stopUpdatingLocation()
                    } else {
                        self.locationManager.startUpdatingLocation()
                        self.walkStore.startWalk()
                    }
                    self.isTracking = !self.isTracking
                    self.updateDisplay()
                    self.locationManager.startUpdatingLocation()
        }
        
        let historyAction1 = UIAlertAction(title: "历史航迹",
            style: UIAlertActionStyle.Default)
            { (action) in
                self.performSegueWithIdentifier("MapToTrack", sender: self)
                
        }
        let historyAction2 = UIAlertAction(title: "历史航迹",
            style: UIAlertActionStyle.Default)
            { (action) in
                self.performSegueWithIdentifier("MapToTrack", sender: self)

        }
        
        let deleteAction1 = UIAlertAction(title: "清除屏幕上的航迹",
            style: UIAlertActionStyle.Default)
            { (action: UIAlertAction!) -> Void in
                self.mapView.removeOverlays(self.mapView.overlays)
                self.walkStore.stopWalk()
        }
        let deleteAction2 = UIAlertAction(title: "清除屏幕上的航迹",
            style: UIAlertActionStyle.Default)
            { (action: UIAlertAction!) -> Void in
                self.mapView.removeOverlays(self.mapView.overlays)
                self.walkStore.stopWalk()
        }
        let cancelAction = UIAlertAction(title: "取消",
            style: UIAlertActionStyle.Destructive,
            handler: nil)
        
        
        alert.addAction(recordAction)
        alert.addAction(historyAction1)
        alert.addAction(deleteAction1)
        alert.addAction(cancelAction)
        
        alertStop.addAction(stopRecordAction)
        alertStop.addAction(historyAction2)
        alertStop.addAction(deleteAction2)
        alertStop.addAction(cancelAction)
        
        if !isTracking {
            self.presentViewController(alert,
            animated: true, completion: nil)}
        else if isTracking {
            self.presentViewController(alertStop,
                animated: true, completion: nil)
        }

    }
    
    func toolAction(exportBarButton:UIBarButtonItem){
        let actionSheet = UIAlertController(title: "工具箱", message: "", preferredStyle: UIAlertControllerStyle.ActionSheet)
        let cancelAction = UIAlertAction(title: "取消", style: UIAlertActionStyle.Cancel, handler: nil)
        let mapRulerAction = UIAlertAction(title: "屏幕米尺(±0.01cm)", style: UIAlertActionStyle.Default){
            (action: UIAlertAction!) -> Void in
            self.performSegueWithIdentifier("ruler", sender: self)
        }
        let rulerAction = UIAlertAction(title: "测量地图上两点间的距离", style: UIAlertActionStyle.Default){
            (action: UIAlertAction!) -> Void in
            self.measureDistance = true
            self.rangingTip.hidden = false
            self.measureDistanceSymbol = 0
            self.numberStart = 1
        }
        actionSheet.addAction(mapRulerAction)
        actionSheet.addAction(rulerAction)
        actionSheet.addAction(cancelAction)
        self.presentViewController(actionSheet, animated: true, completion: {})

    }
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    @IBAction func indexChanged(sender: UISegmentedControl) {
        let mapType = MapType(rawValue: self.segmentedControl.selectedSegmentIndex)
        switch (mapType!) {
        case .Standard:
            self.mapView.mapType = MKMapType.Standard
        case .Hybrid:
            self.mapView.mapType = MKMapType.Hybrid}
    }
    
    @IBAction func walkPressed(sender: UIButton) {
        sender.selected = !sender.selected
        if !isCompass {mapView.userTrackingMode = MKUserTrackingMode.FollowWithHeading}
        else {
            mapView.userTrackingMode = MKUserTrackingMode.None
            mapView.setCenterCoordinate(CoordsTransform.transformMarsToGpsCoordsWithCLLocationCoordinate2D(mapView.centerCoordinate), animated: true)
            
            let region = MKCoordinateRegionMakeWithDistance(CoordsTransform.transformMarsToGpsCoordsWithCLLocationCoordinate2D(mapView.centerCoordinate),4.5*pow(3, 10),4.5*pow(3, 10))
            mapView.setRegion(region, animated: true)}
        isCompass = !isCompass
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.navigationItem.leftBarButtonItem = self.trackButton
        self.navigationItem.rightBarButtonItem = self.toolButton
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.activityType = .Fitness
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        locationManager.requestAlwaysAuthorization()
        mapView.showsUserLocation = true
        if(self.requestauthorization==false){
            if self.locationManager.respondsToSelector("requestAlwaysAuthorization") {
                print("requestAlwaysAuthorization")
                self.locationManager.requestWhenInUseAuthorization ()
                self.requestauthorization=true
            }}
        locationManager.startUpdatingLocation();
        
        //显示产状部分
        sharedContext = cdControl.cdh.managedObjectContext
        
        self.adr.text = "网络连接中断，无法获取此地名称。"
        self.lat.text = "设备接收卫星数量不足"
        self.lon.text = "或GPS信号接收异常"
        adr.textColor = UIColor(red: 203/255, green: 80/255, blue: 43/255, alpha: 1)
        lat.textColor = UIColor(red: 203/255, green: 80/255, blue: 43/255, alpha: 1)
        lon.textColor = UIColor(red: 203/255, green: 80/255, blue: 43/255, alpha: 1)
        high.textColor = UIColor(red: 203/255, green: 80/255, blue: 43/255, alpha: 1)
        
        //测距部分
        let Press = UILongPressGestureRecognizer(target: self, action: "dropPin:")
        Press.minimumPressDuration = 0.5
        mapView.addGestureRecognizer(Press)
        rangingTip.hidden = true

    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        mapView.delegate = self
        mapView.rotateEnabled = false
        
        mapView.removeAnnotations(mapView.annotations)
        mapView.addAnnotations(fetchSurfacePins())
        mapView.addAnnotations(fetchLinePins())
        
        mapView.removeOverlays(mapView.overlays)
        mapView.addOverlay(polyLine())
    }
    

    func updateDisplay() {
        if let walk = walkStore.currentWalk {
            if let region = self.mapRegion(walk) {
                mapView.setRegion(region, animated: true)
            }
        }
        mapView.removeOverlays(mapView.overlays)
        mapView.addOverlay(polyLine())
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
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location:CLLocation = locations[locations.count-1]
        let thelocations:NSArray = locations as NSArray
        let curlocation:CLLocation = thelocations.objectAtIndex(0) as! CLLocation
        let geocoder:CLGeocoder = CLGeocoder()
        //let placemarks:NSArray?
        //let error:NSError
        geocoder.reverseGeocodeLocation(curlocation, completionHandler:{(placemarks,error) in
            if error != nil {
                self.adr.text = "网络连接中断，无法获取此地名称。";}
            if (error == nil && placemarks!.count >= 0){
                let placemark:CLPlacemark = (placemarks! as NSArray).objectAtIndex(0) as! CLPlacemark
                self.adr.text = placemark.name!;}
        })
        if (location.horizontalAccuracy > 0) {
            let latNow = CoordsTransform.transformMarsToGpsCoordsWithCLLocationCoordinate2D(location.coordinate).latitude;
            let lonNow = CoordsTransform.transformMarsToGpsCoordsWithCLLocationCoordinate2D(location.coordinate).longitude;
            let highNow = location.altitude;

                var R = transloc(latNow);
                self.lat.text = "纬度:"+"\(R.b)" + "°" + "\(R.c)" + "'" + (R.d).format(".5") + "\"";
                R = transloc(lonNow);
                self.lon.text = "经度:"+"\(R.b)" + "°" + "\(R.c)" + "'" + (R.d).format(".5") + "\"";
                self.high.text = "高程:"+(highNow).format(".2")+"m";
        }
        
        if let walk = walkStore.currentWalk {
            for location in locations {
                if let newLocation:CLLocation = location as CLLocation {
                    if newLocation.horizontalAccuracy > 0 {
                        // Only set the location on and region on the first try
                        // This may change in the future
                        if mapView.userLocationVisible {
                            mapView.userTrackingMode = MKUserTrackingMode.None
                            mapView.setCenterCoordinate(CoordsTransform.transformMarsToGpsCoordsWithCLLocationCoordinate2D(mapView.userLocation.coordinate), animated: true)
                            
                            let region = MKCoordinateRegionMakeWithDistance(CoordsTransform.transformMarsToGpsCoordsWithCLLocationCoordinate2D(mapView.userLocation.coordinate),4*pow(3, 10),4*pow(3, 10))
                            mapView.setRegion(region, animated: true)
                        }
                        let locations = walk.locations as Array<CLLocation>
                        if let oldLocation = locations.last as CLLocation? {
                            let delta: Double = newLocation.distanceFromLocation(oldLocation)
                            walk.addDistance(delta)
                        }
                        
                        walk.addNewLocation(newLocation)
                    }
                }
            }
            updateDisplay()
        }
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        self.lat.text = "设备接收卫星数量不足"
        self.lon.text = "或GPS信号接收异常"
    }
    
    func polyLine() -> MKPolyline {
        if let walk = walkStore.currentWalk {
            var coordinates = walk.locations.map({ (location: CLLocation) ->
                CLLocationCoordinate2D in
                return location.coordinate
            })
            return MKPolyline(coordinates: &coordinates, count: walk.locations.count)
        }
        return MKPolyline()
    }
    

    
    // This feels like it could definitely live somewhere else
    // I am not sure yet where this function lives
    func mapRegion(walk: Walk) -> MKCoordinateRegion? {
        if let startLocation = walk.locations.first {
            var minLatitude = startLocation.coordinate.latitude
            var maxLatitude = startLocation.coordinate.latitude
            
            var minLongitude = startLocation.coordinate.longitude
            var maxLongitude = startLocation.coordinate.longitude
            
            for location in walk.locations {
                if location.coordinate.latitude < minLatitude {
                    minLatitude = location.coordinate.latitude
                }
                if location.coordinate.latitude > maxLatitude {
                    maxLatitude = location.coordinate.latitude
                }
                
                if location.coordinate.longitude < minLongitude {
                    minLongitude = location.coordinate.longitude
                }
                if location.coordinate.latitude > maxLongitude {
                    maxLongitude = location.coordinate.longitude
                }
            }
            
            let center = CLLocationCoordinate2D(latitude: (minLatitude + maxLatitude)/2.0,
                longitude: (minLongitude + maxLongitude)/2.0)
            
            // 10% padding need more padding vertically because of the toolbar
            let span = MKCoordinateSpan(latitudeDelta: (maxLatitude - minLatitude)*1.3,
                longitudeDelta: (maxLongitude - minLongitude)*1.1)
            
            return MKCoordinateRegion(center: center, span: span)
        }
        return nil
    }
    
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKPolyline {
            let renderer = MKPolylineRenderer(polyline: polyLine())
            renderer.strokeColor = UIColor(red: 11/255.0, green: 128/255.0, blue: 224/255.0, alpha: 0.75)
            renderer.lineWidth = 6
            return renderer }

        return MKOverlayRenderer(overlay: overlay)
    }
    
    func cancelPin(button:UIButton){
        if nowAnnotationView.tag == 1 && measureDistanceSymbol == 1 && startON {
            if !endON {
            measureDistanceSymbol = 0
            measureDistance = false
            mapView.removeAnnotation(annotationArrary.last!)
            annotationArrary.removeLast()
            rangingTip.hidden = true
            startON = false
            }
            else if endON {
                let alert = UIAlertController(title: "警告",
                    message: "请先删除终点标记",
                    preferredStyle: UIAlertControllerStyle.Alert)
                let cancelAction = UIAlertAction(title: "确定",
                    style: UIAlertActionStyle.Default,
                    handler: nil)
                alert.addAction(cancelAction)
                self.presentViewController(alert,
                    animated: true, completion: nil)
            }
        }
        else if nowAnnotationView.tag > 1 && startON && endON {
            measureDistanceSymbol = 1
            measureDistance = true
            mapView.removeAnnotation(annotationArrary.last!)
            annotationArrary.removeLast()
            rangingTip.hidden = false
            endON = false
        }
    }
    
    func mapView(mapView: MKMapView, didAddAnnotationViews views: [MKAnnotationView]) {
        for view in views {
            if view.annotation is Pin {
                view.tag = numberStart
                annotationArrary.append(view.annotation!)
                numberStart = numberStart + 1
            }
        }
    }
    
    //显示产状部分
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView){
        if view.annotation is Pin {
            view.enabled = true
            view.canShowCallout = true
            nowAnnotationView = view

            let crossButton = UIButton(type: .DetailDisclosure)
            crossButton.setImage(UIImage(named: "叉.png"), forState:.Normal)
            view.rightCalloutAccessoryView = crossButton
            crossButton.addTarget(self,action:Selector("cancelPin:"),forControlEvents:.TouchUpInside)
        }
        if view.annotation is SurfaceData {

                
                // 3
                view.enabled = true
                view.canShowCallout = true

                
                view.tintColor = UIColor(white: 0.0, alpha: 0.5)
                
                // 4 Implement target-action pattern manually
                let rightButton = UIButton(type: .DetailDisclosure)
                
                rightButton.addTarget(self, action: Selector("MapToDetail:"), forControlEvents: .TouchUpInside)
                
                view.rightCalloutAccessoryView = rightButton
            
                surfacedata = view.annotation as? SurfaceData
                nowdata = "surfacedata"
            
                var image:UIImage
                var imageView:UIImageView
                if (view.annotation as! SurfaceData).photoExsist {
                    if (view.annotation as! SurfaceData).photoPath == "defaultPhoto2.png" {
                    image =  UIImage(named:"defaultPhoto2.png")!
                    imageView = UIImageView(image:image)
                    imageView.frame = CGRectMake(7, 7, 45, 45)
                    imageView.contentMode = UIViewContentMode.Redraw
                    
                    }
                    else {
                    image =  UIImage(contentsOfFile:(view.annotation as! SurfaceData).photoPath)!
                    imageView = UIImageView(image:image)
                    imageView.frame = CGRectMake(7, 7, 45, 45)
                    imageView.contentMode = UIViewContentMode.Redraw
                    }
                    view.leftCalloutAccessoryView = imageView
                }
                else {
                    image =  UIImage(named:"defaultPhoto2.png")!
                    imageView = UIImageView(image:image)
                    imageView.frame = CGRectMake(7, 7, 45, 45)
                    imageView.contentMode = UIViewContentMode.Redraw
                }
            
                view.leftCalloutAccessoryView = imageView

            
            
 
            
            // 5
            let button = view.rightCalloutAccessoryView as! UIButton
            if let index = [SurfaceData]().indexOf(view.annotation as! SurfaceData) {
                button.tag = index
            }
            
        }
        else if view.annotation is LineData {

                
                // 3
                view.enabled = true
                view.canShowCallout = true

                
                view.tintColor = UIColor(white: 0.0, alpha: 0.5)
                
                // 4 Implement target-action pattern manually
                let rightButton = UIButton(type: .DetailDisclosure)
                
                rightButton.addTarget(self, action: Selector("MapToDetail:"), forControlEvents: .TouchUpInside)
                
                view.rightCalloutAccessoryView = rightButton
            
                linedata = view.annotation as? LineData
                nowdata = "linedata"
            
                var image:UIImage
                var imageView:UIImageView
                if (view.annotation as! LineData).photoExsist {
                if (view.annotation as! LineData).photoPath == "defaultPhoto2.png" {
                        image =  UIImage(named:"defaultPhoto2.png")!
                        imageView = UIImageView(image:image)
                        imageView.frame = CGRectMake(7, 7, 45, 45)
                        imageView.contentMode = UIViewContentMode.Redraw
                    
                    }
                    else {
                        image =  UIImage(contentsOfFile:(view.annotation as! LineData).photoPath)!
                        imageView = UIImageView(image:image)
                        imageView.frame = CGRectMake(7, 7, 45, 45)
                        imageView.contentMode = UIViewContentMode.Redraw
                    }
                }
                else {
                    image =  UIImage(named:"defaultPhoto2.png")!
                    imageView = UIImageView(image:image)
                    imageView.frame = CGRectMake(7, 7, 45, 45)
                    imageView.contentMode = UIViewContentMode.Redraw                }
            
                view.leftCalloutAccessoryView = imageView

            
            
            // 5
            let button = view.rightCalloutAccessoryView as! UIButton
            if let index = [LineData]().indexOf(view.annotation as! LineData) {
                button.tag = index
            }
            
        }

    }
    
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is Pin {
            let identifier = "Pin"+"\(measureDistanceSymbol)"
            var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier) as MKAnnotationView!
            annotationView = PinView(annotation: annotation, reuseIdentifier: identifier)
            annotationView.enabled = true
            annotationView.canShowCallout = true
            let crossButton = UIButton(type: .DetailDisclosure)
            //crossButton.setImage(UIImage(named: "叉"), forState:.Normal)
            annotationView.rightCalloutAccessoryView = crossButton
            crossButton.addTarget(self,action:Selector("cancelPin:"),forControlEvents:.TouchUpInside)

            return annotationView
        }
        if annotation is SurfaceData {
            let identifier = "\((annotation as! SurfaceData).id)"
            var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier) as MKAnnotationView!

                annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                annotationView.enabled = true
                annotationView.canShowCallout = true
                for view in annotationView.subviews {view.removeFromSuperview()}
            
                let img = UIImage(named: "面状40")
                let imageView = UIImageView(image: img)
                let dipdir = (annotation as! SurfaceData).dipdirS as Double
                let dip = (annotation as! SurfaceData).dipS as Double
                
                annotationView.addSubview(imageView)
                var avFrame:CGRect = annotationView.frame
                avFrame.size = CGSizeMake(img!.size.width,
                    img!.size.height)
                imageView.frame = avFrame
                imageView.transform = CGAffineTransformMakeRotation(CGFloat((dipdir+M_PI/2)*M_PI/180))
            
                annotationView.image = UIImage(named: "structure")

                let text = UILabel()
                text.text = String(format: "%.0f", round(dip))
                text.textColor = UIColor(colorLiteralRed: 254/255, green: 195/255, blue: 0, alpha: 1)
                text.textAlignment = NSTextAlignment.Right
                text.font = UIFont.systemFontOfSize(10)
                annotationView.addSubview(text)
            
                var textFrame:CGRect = annotationView.frame
                textFrame.size = CGSizeMake(20,
                11)
                text.textAlignment = NSTextAlignment.Center
                let XFloat = Float(imageView.bounds.origin.x)
                let YFloat = Float(imageView.bounds.origin.y)
                let textFrameTransX = CGFloat(XFloat*(cosf(Float(dipdir+M_PI/2)))-YFloat*(sinf(Float(dipdir+M_PI/2))))
                let textFrameTransY = CGFloat(XFloat*(sinf(Float(dipdir+M_PI/2)))+YFloat*(cosf(Float(dipdir+M_PI/2))))
            if (dipdir+M_PI/2) <= 90 {
                textFrame.origin.x = textFrameTransX+23
                textFrame.origin.y = textFrameTransY+10
                //text.textAlignment = NSTextAlignment.Left
            }
            else if (dipdir+M_PI/2) > 90 && (dipdir+M_PI/2) <= 180{
                //Y = annotationView.frame.origin.y+annotationView.frame.size.height
                textFrame.origin.x = textFrameTransX+25
                textFrame.origin.y = textFrameTransY+11
                // text.textAlignment = NSTextAlignment.Left
            }
            else if (dipdir+M_PI/2) > 180 && (dipdir+M_PI/2) <= 270{
                //X = imageView.frame.origin.x-imageView.frame.size.width
                
                textFrame.origin.x = textFrameTransX+10
                textFrame.origin.y = textFrameTransY+11
                //text.textAlignment = NSTextAlignment.Right
            }
            else if (dipdir+M_PI/2) > 270 {
                //X = imageView.frame.origin.x-imageView.frame.size.width
                //Y = imageView.frame.origin.y-imageView.frame.size.height/2+3
                textFrame.origin.x = textFrameTransX+13
                textFrame.origin.y = textFrameTransY+11
                //text.textAlignment = NSTextAlignment.Right
            }
            text.frame = textFrame




        

            return annotationView
        }
        if annotation is LineData {
            let identifier = "\((annotation as! LineData).id)"
            var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier) as MKAnnotationView!
            //if annotationView == nil {
                annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                annotationView.enabled = true
                annotationView.canShowCallout = true
                for view in annotationView.subviews {view.removeFromSuperview()}

                
                let img = UIImage(named: "线状40")
                let imageView = UIImageView(image: img)
                let plusyn = (annotation as! LineData).plusynS as Double
                let pluang = (annotation as! LineData).pluangS as Double
                
                annotationView.addSubview(imageView)
                var avFrame:CGRect = annotationView.frame
                avFrame.size = CGSizeMake(img!.size.width,
                    img!.size.height)
                imageView.frame = avFrame

                
                imageView.transform = CGAffineTransformMakeRotation(CGFloat((plusyn+M_PI/2)*M_PI/180))

                annotationView.image = UIImage(named: "structure")
                
                let text = UILabel()
                text.text = String(format: "%.0f", round(pluang))
                text.textColor = UIColor(colorLiteralRed: 254/255, green: 195/255, blue: 0, alpha: 1)
                text.font = UIFont.systemFontOfSize(10)
                annotationView.addSubview(text)
                var textFrame:CGRect = annotationView.frame
                textFrame.size = CGSizeMake(20,
                    11)
                
                text.textAlignment = NSTextAlignment.Center
                let XFloat = Float(imageView.bounds.origin.x+imageView.bounds.width/2)
                let YFloat = Float(imageView.bounds.origin.y)
                let textFrameTransX = CGFloat(XFloat*(cosf(Float(plusyn+M_PI/2)))-YFloat*(sinf(Float(plusyn+M_PI/2))))
                let textFrameTransY = CGFloat(XFloat*(sinf(Float(plusyn+M_PI/2)))+YFloat*(cosf(Float(plusyn+M_PI/2))))
                //textFrame.origin.x = textFrameTransX*1.2
                //textFrame.origin.y = textFrameTransY*1.2


                /*var X = annotationView.frame.origin.x+annotationView.frame.size.width/2
                var Y = annotationView.frame.origin.y+annotationView.frame.size.height/2*/
                if (plusyn+M_PI/2) <= 90 {
                    textFrame.origin.x = textFrameTransX+13
                    textFrame.origin.y = textFrameTransY+11
                    //text.textAlignment = NSTextAlignment.Left
                }
                else if (plusyn+M_PI/2) > 90 && (plusyn+M_PI/2) <= 180{
                    //Y = annotationView.frame.origin.y+annotationView.frame.size.height
                    textFrame.origin.x = textFrameTransX+13
                    textFrame.origin.y = textFrameTransY+11
                   // text.textAlignment = NSTextAlignment.Left
                }
                else if (plusyn+M_PI/2) > 180 && (plusyn+M_PI/2) <= 270{
                    //X = imageView.frame.origin.x-imageView.frame.size.width
                
                    textFrame.origin.x = textFrameTransX-13
                    textFrame.origin.y = textFrameTransY+11
                    //text.textAlignment = NSTextAlignment.Right
                }
                else if (plusyn+M_PI/2) > 270 {
                    //X = imageView.frame.origin.x-imageView.frame.size.width
                    //Y = imageView.frame.origin.y-imageView.frame.size.height/2+3
                    textFrame.origin.x = textFrameTransX-13
                    textFrame.origin.y = textFrameTransY+11
                    //text.textAlignment = NSTextAlignment.Right
                }
                text.frame = textFrame
            /*} else {
                annotationView.annotation = annotation
                
            }*/
            


            
            return annotationView
            
        }
        return nil
    }
    
    func rotateImageView(image:UIView, angle:Double) -> UIImage {
        let scale:CGFloat = UIScreen.mainScreen().scale
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(image.frame.size.width,
            image.frame.size.height), false, scale)
        
        let context:CGContextRef = UIGraphicsGetCurrentContext()!
        image.layer.renderInContext(context)
        
        
        let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
    
    func rotateImage(image:UIImage, angle:Double) -> UIImage {
        
        let s = CGSize(width: image.size.width, height: image.size.height);
        UIGraphicsBeginImageContext(s);
        let ctx:CGContextRef = UIGraphicsGetCurrentContext()!;
        CGContextTranslateCTM(ctx, 0,image.size.height);
        CGContextScaleCTM(ctx, 1.0, -1.0);
        
        CGContextRotateCTM(ctx, CGFloat(angle*M_PI/180));
        CGContextDrawImage(ctx,CGRectMake(0,0,image.size.width, image.size.height),image.CGImage);
        let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return newImage;
    }
    
    func fetchSurfacePins() -> [SurfaceData] {
        
        let error: NSErrorPointer = nil
        // Create the Fetch Request
        let fetchRequest = NSFetchRequest(entityName: "SurfaceData")
        // Execute the Fetch Request
        let results: [AnyObject]?
        do {
            results = try sharedContext.executeFetchRequest(fetchRequest)
        } catch let error1 as NSError {
            error.memory = error1
            results = nil
        }
        // Check for Errors
        if error != nil {
            print("Error in fectchAllActors(): \(error)")
        }
        // Return the results, cast to an array of Pin objects
        return results as! [SurfaceData]
    }
    
    func fetchLinePins() -> [LineData] {
        
        let error: NSErrorPointer = nil
        // Create the Fetch Request
        let fetchRequest = NSFetchRequest(entityName: "LineData")
        // Execute the Fetch Request
        let results: [AnyObject]?
        do {
            results = try sharedContext.executeFetchRequest(fetchRequest)
        } catch let error1 as NSError {
            error.memory = error1
            results = nil
        }
        // Check for Errors
        if error != nil {
            print("Error in fectchAllActors(): \(error)")
        }
        // Return the results, cast to an array of Pin objects
        return results as! [LineData]
    }
    
    func MapToDetail(sender: UIButton) {
        performSegueWithIdentifier("MapToDetail", sender: sender)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        //明细查询页面
        if (segue.identifier == "MapToDetail") {
            //将所选择的当前数据赋值给所打开页面的控制器
            let secondViewDetailController = segue.destinationViewController as! SecondViewDetailController
            if nowdata == "surfacedata" {
                secondViewDetailController.surfacedata = surfacedata
                secondViewDetailController.nowData = "surfacedata"}
            else if nowdata == "linedata" {
                secondViewDetailController.linedata = linedata
                secondViewDetailController.nowData = "linedata"}
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
