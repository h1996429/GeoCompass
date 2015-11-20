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



enum MapType: Int {
    case Standard = 0
    case Hybrid
}

class ThirdViewController: UIViewController,MKMapViewDelegate,CLLocationManagerDelegate,UITabBarControllerDelegate,NSFetchedResultsControllerDelegate {
    //产状部分
    var sharedContext: NSManagedObjectContext!

    
    //航迹部分
    var locationManager: CLLocationManager!
    
    let walkStore: WalkStore = WalkStore.sharedInstance
    let cdControl = NewsCoreDataController()
    var nowdata = "surfacedata"
    
    var isTracking: Bool = false
    var isCompass: Bool = false
    var trackButton:UIBarButtonItem{
        return UIBarButtonItem(title:"航迹", style:.Plain, target: self, action: "trackAction:")
    }
    var toolButton:UIBarButtonItem{
        return UIBarButtonItem(title:"工具", style:.Plain, target: self, action: "toolAction:")
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
        }
        
        let historyAction1 = UIAlertAction(title: "历史航迹",
            style: UIAlertActionStyle.Default)
            { (action) in
                
        }
        let historyAction2 = UIAlertAction(title: "历史航迹",
            style: UIAlertActionStyle.Default)
            { (action) in
                
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
        self.mapView.delegate = self
        
        //显示产状部分
        sharedContext = cdControl.cdh.managedObjectContext
        mapView.addAnnotations(fetchSurfacePins())
        mapView.addAnnotations(fetchLinePins())

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
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let walk = walkStore.currentWalk {
            for location in locations {
                if let newLocation:CLLocation = location as CLLocation {
                    if newLocation.horizontalAccuracy > 0 {
                        // Only set the location on and region on the first try
                        // This may change in the future
                        if mapView.userLocationVisible {
                            mapView.userTrackingMode = MKUserTrackingMode.None
                            mapView.setCenterCoordinate(CoordsTransform.transformMarsToGpsCoordsWithCLLocationCoordinate2D(mapView.userLocation.coordinate), animated: true)
                            
                            let region = MKCoordinateRegionMakeWithDistance(CoordsTransform.transformMarsToGpsCoordsWithCLLocationCoordinate2D(mapView.userLocation.coordinate),4.5*pow(3, 10),4.5*pow(3, 10))
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
        print(error)
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
        return MKOverlayRenderer()
    }
    
    
    //显示产状部分
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        //cast pin
        func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
            //明细查询页面
            if (segue.identifier == "MapToDetail") {
                NSLog("Detail go")
                //将所选择的当前数据赋值给所打开页面的控制器
                let secondViewDetailController = segue.destinationViewController as! SecondViewDetailController
                if segmentedControl.selectedSegmentIndex == 0 {
                    let surfacedata = view.annotation as! SurfaceData
                    secondViewDetailController.surfacedata = surfacedata
                    secondViewDetailController.nowData = "surfacedata"}
                else if segmentedControl.selectedSegmentIndex == 1 {
                    let linedata = view.annotation as! LineData
                    secondViewDetailController.linedata = linedata
                    secondViewDetailController.nowData = "linedata"}
            }
        }
        self.performSegueWithIdentifier("MapToDetail", sender: self)
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
    

    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
