//
//  MonsterAnnotation.swift
//  alohaMonsterMap
//
//  Created by 林尚恩 on 2016/1/21.
//  Copyright © 2016年 Shangen. All rights reserved.
//

import UIKit
import MapKit

class MonsterAnnotation: NSObject,MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title:String?
    var subtitle: String?
    init(monsterCoordinate:CLLocationCoordinate2D,monsterName:String,monsterLevel:String) {
        coordinate=monsterCoordinate
        title=monsterName
        subtitle=monsterLevel
    }
    class func createViewAnnotationForMapView(mapView mapView:MKMapView, annotation:MKAnnotation, identifier:String)->MKAnnotationView{
        var returnAnnotationView=mapView.dequeueReusableAnnotationViewWithIdentifier(identifier)
        
        if(returnAnnotationView == nil){
            returnAnnotationView=MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            returnAnnotationView?.canShowCallout=true
            returnAnnotationView?.image=UIImage(named: "MonsterMark")
            
            let monsterCalloutButton=UIButton(type:UIButtonType.DetailDisclosure)
            //            monsterCalloutButton.addTarget(self, action: "monsterCalloutButtonAction:" , forControlEvents: UIControlEvents.TouchUpInside)
            returnAnnotationView!.rightCalloutAccessoryView=monsterCalloutButton
            
        }
        return returnAnnotationView!
    }
}

