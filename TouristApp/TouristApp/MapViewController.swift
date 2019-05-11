//
//  ViewController.swift
//  TouristApp
//
//  Created by Hazem on 5/9/19.
//  Copyright © 2019 Hazem. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController , MKMapViewDelegate{

    private let dataController = DataController.shared
    var locationAnnotations = [MKPointAnnotation]()
    
    @IBOutlet weak var travellerMap: MKMapView!
    
    fileprivate func configureMapTouchGesture() {
        let longPressRecogniser = UILongPressGestureRecognizer(target: self, action: #selector(MapViewController.handleLongPress(_:)))
        longPressRecogniser.minimumPressDuration = 1.0
        travellerMap.addGestureRecognizer(longPressRecogniser)
    }
    
    @objc func handleLongPress(_ gestureRecognizer : UIGestureRecognizer){
        if gestureRecognizer.state != .began { return }
        
        let touchPoint = gestureRecognizer.location(in: travellerMap)
        let touchMapCoordinate = travellerMap?.convert(touchPoint, toCoordinateFrom: travellerMap)
    
        let annotation = MKPointAnnotation()
        annotation.coordinate = touchMapCoordinate!
        travellerMap.addAnnotation(annotation)
        //TODO : Save the selected locations into local storage
        let selectedPin = Pin(context:dataController.viewContext)
        selectedPin.long = annotation.coordinate.longitude
        selectedPin.lat = annotation.coordinate.latitude
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        travellerMap.delegate = self
       
        configureMapTouchGesture()
        prepareData()
    }
    
    
    
    private func prepareData(){
        // TODO first load data from local storage if any and associate it with the location annotation dictionary
        
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

    // This delegate method is implemented to respond to taps. It should open the photo album related to this pin
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        // get an instance of photo album view controller
        let photoAlbum = self.storyboard?.instantiateViewController(withIdentifier: "PhotoAlbumViewController") as! PhotoAlbumViewController
        
        // navigate to the next screen with photo albums
        self.performSegue(withIdentifier: "toCollection", sender:self)
    }
    
}

