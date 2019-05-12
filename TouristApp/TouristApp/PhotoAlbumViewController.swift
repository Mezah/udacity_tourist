//
//  PhotoAlbumViewController.swift
//  TouristApp
//
//  Created by Hazem on 5/11/19.
//  Copyright © 2019 Hazem. All rights reserved.
//

import UIKit
import MapKit

class PhotoAlbumViewController: UIViewController,MKMapViewDelegate {

    @IBOutlet weak var photoAlbumLocation: MKMapView!
    
    var pinLocation:Pin!
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        let mkPoint = MKPointAnnotation()
        mkPoint.coordinate.longitude = pinLocation.long
        mkPoint.coordinate.latitude = pinLocation.lat
        photoAlbumLocation.addAnnotation(mkPoint)
        
    }
    
    // setup annotation view (pins) on map
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .red
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
