//
//  Pin.swift
//  GeoCompass
//
//  Created by 何嘉 on 15/11/24.
//  Copyright © 2015年 何嘉. All rights reserved.
//

import Foundation
import MapKit

enum AttractionType: Int {
    case AttractionBegin = 0
    case AttractionEnd

}

class Pin:NSObject,MKAnnotation {
    
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    var type: AttractionType

    
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
    
    init(coordinate: CLLocationCoordinate2D, title: String ,subtitle: String, type: AttractionType) {
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
        self.type = type
    }
}
