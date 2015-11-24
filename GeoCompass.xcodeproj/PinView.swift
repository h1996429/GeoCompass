//
//  PinView.swift
//  GeoCompass
//
//  Created by 何嘉 on 15/11/24.
//  Copyright © 2015年 何嘉. All rights reserved.
//

import UIKit
import MapKit

class PinView: MKAnnotationView {
    
    // Required for MKAnnotationView
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // Called when drawing the AttractionAnnotationView
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        let pin = self.annotation as! Pin
        switch (pin.type) {
        case .AttractionBegin:
            image = UIImage(named: "icon_nav_start")
        case .AttractionEnd:
            image = UIImage(named: "icon_nav_end")
        }
    }
}