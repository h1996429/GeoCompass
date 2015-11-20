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


enum MapType: Int {
    case Standard = 0
    case Hybrid
}

class ThirdViewController: UIViewController,MKMapViewDelegate,CLLocationManagerDelegate,UITabBarControllerDelegate {
    
    var locationManager: CLLocationManager!
    
    let walkStore: WalkStore = WalkStore.sharedInstance
    
    var isTracking: Bool = false
    var isCompass: Bool = false
    var trackButton:UIBarButtonItem{
        return UIBarButtonItem(title:"航迹", style:.Plain, target: self, action: "trackAction:")
    }
    var toolButton:UIBarButtonItem{
        return UIBarButtonItem(title:"工具", style:.Plain, target: self, action: "toolAction:")
    }
    func trackAction(exportBarButton:UIBarButtonItem){
        if isTracking {
            locationManager.stopUpdatingLocation()
        } else {
            locationManager.startUpdatingLocation()
            walkStore.startWalk()
        }
        
        isTracking = !isTracking
        updateDisplay()

    }
    func toolAction(exportBarButton:UIBarButtonItem){
    }
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    @IBAction func indexChanged(sender: UISegmentedControl) {
        let mapType = MapType(rawValue: segmentedControl.selectedSegmentIndex)
        switch (mapType!) {
        case .Standard:
            mapView.mapType = MKMapType.Standard
        case .Hybrid:
            mapView.mapType = MKMapType.Hybrid}
    }
    
    @IBAction func walkPressed(sender: UIButton) {
        sender.selected = !sender.selected
        if !isCompass {mapView.userTrackingMode = MKUserTrackingMode.FollowWithHeading}
        else {mapView.userTrackingMode = MKUserTrackingMode.None}
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
                        if walk.locations.count <= 0 {
                            mapView.setCenterCoordinate(CoordsTransform.transformMarsToGpsCoordsWithCLLocationCoordinate2D(newLocation.coordinate), animated: true)
                            
                            let region = MKCoordinateRegionMakeWithDistance(CoordsTransform.transformMarsToGpsCoordsWithCLLocationCoordinate2D(newLocation.coordinate), 1000, 1000)
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
        if let polyLine = overlay as? MKPolyline {
            let renderer = MKPolylineRenderer(polyline: polyLine)
            renderer.strokeColor = UIColor(hue:0.88, saturation:0.46, brightness:0.73, alpha:0.75)
            renderer.lineWidth = 6
            return renderer }
        else{return MKOverlayRenderer()}
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
