//
//  mapViewController.swift
//  Heads Up
//
//  Created by Chris on 9/17/15.
//  Copyright (c) 2015 Gazellia. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import CoreLocation

class mapViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var myMap: MKMapView!
    var routeMap : MKRoute?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        myMap.showsUserLocation = true

        myMap.delegate = self
        self.getDirections()

    }
    
    func getDirections() {
            
            let request = MKDirectionsRequest()
            
            var point1 = MKPointAnnotation()
            var point2 = MKPointAnnotation()
            
            var dest_lat = Double(locationMgr.dest_lat);
            var dest_lng = Double(locationMgr.dest_lng);
            
            point1.coordinate = CLLocationCoordinate2DMake(locationMgr.user_lat, locationMgr.user_lng)
            point1.title = "Your location"
            myMap.addAnnotation(point1)
            
            point2.coordinate = CLLocationCoordinate2DMake(dest_lat, dest_lng)
            point2.title = "Destination"
            myMap.addAnnotation(point2)
            myMap.centerCoordinate = point2.coordinate
            
            let markTaipei = MKPlacemark(coordinate: CLLocationCoordinate2DMake(locationMgr.user_lat, locationMgr.user_lng), addressDictionary: nil)
            let markChungli = MKPlacemark(coordinate: CLLocationCoordinate2DMake(dest_lat, dest_lng), addressDictionary: nil)
        
            let destination = MKMapItem(placemark: markTaipei)
        
            request.setSource(MKMapItem(placemark: markTaipei))
            request.setDestination(MKMapItem(placemark: markChungli))
            request.requestsAlternateRoutes = false
            
            let directions = MKDirections(request: request)
            
            directions.calculateDirectionsWithCompletionHandler({(response:
                MKDirectionsResponse!, error: NSError!) in
                
                if error != nil {
                    println("Error getting directions")
                } else {
                    self.showRoute(response)
                }
                
            })
        }
    
    func showRoute(response: MKDirectionsResponse) {
        
        for route in response.routes as! [MKRoute] {
            
            myMap.addOverlay(route.polyline,
                level: MKOverlayLevel.AboveRoads)
            
            for step in route.steps {
                if let instructions = (step.instructions ?? "") as String?{
                    println(instructions);
                }
            }
        }
        let userLocation = myMap.userLocation
//        let region = MKCoordinateRegionMakeWithDistance(
//            userLocation.location.coordinate, 2000, 2000)
//        
//        myMap.setRegion(region, animated: true)
    }
    
    func mapView(mapView: MKMapView!, rendererForOverlay
        overlay: MKOverlay!) -> MKOverlayRenderer! {
            let renderer = MKPolylineRenderer(overlay: overlay)
            
            renderer.strokeColor = UIColor.blueColor()
            renderer.lineWidth = 5.0
            return renderer
    }
    

//    func mapView(mapView: MKMapView!, annotationView view: MKAnnotationView!,
//        calloutAccessoryControlTapped control: UIControl!) {
//            let location = view.annotation as! Artwork
//            let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
//            location.mapItem().openInMapsWithLaunchOptions(launchOptions)
//    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
