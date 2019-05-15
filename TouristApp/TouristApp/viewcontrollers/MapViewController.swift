//
//  ViewController.swift
//  TouristApp
//
//  Created by Hazem on 5/9/19.
//  Copyright © 2019 Hazem. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController , MKMapViewDelegate{

    private let dataController = DataController.shared
    var locationAnnotations = [MKPointAnnotation]()
    
    
    @IBOutlet weak var travellerMap: MKMapView!
    
    fileprivate func configureMapTouchGesture() {
        let longPressRecogniser = UILongPressGestureRecognizer(target: self, action: #selector(MapViewController.handleLongPress(_:)))
        longPressRecogniser.minimumPressDuration = 1.0
        travellerMap.addGestureRecognizer(longPressRecogniser)
    }
    
    /**
     Handle user press on the map to add a pin on the required location
     **/
    @objc func handleLongPress(_ gestureRecognizer : UIGestureRecognizer){
        if gestureRecognizer.state != .began { return }
        
        let touchPoint = gestureRecognizer.location(in: travellerMap)
        let touchMapCoordinate = travellerMap?.convert(touchPoint, toCoordinateFrom: travellerMap)
    
        let annotation = MKPointAnnotation()
        annotation.coordinate = touchMapCoordinate!
        travellerMap.addAnnotation(annotation)
        // Save the selected locations into local storage
        // first initialize object
        let selectedPin = Pin(context:dataController.viewContext)
        selectedPin.long = annotation.coordinate.longitude
        selectedPin.lat = annotation.coordinate.latitude
        // save after setting the object up
        try? dataController.viewContext.save()
        // TODO start download photos related to pin
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        travellerMap.delegate = self
       
        configureMapTouchGesture()
        prepareData()
    }
    
    
    
    private func prepareData(){
        // load data from local storage if any and associate it with the location annotation dictionary
        let fetchReq : NSFetchRequest<Pin> = Pin.fetchRequest()
        if let pinsResult = try? dataController.viewContext.fetch(fetchReq){
            for pin in pinsResult {
                let annot = MKPointAnnotation()
                let lat = CLLocationDegrees(pin.lat)
                let long = CLLocationDegrees(pin.long)
                
                let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
                annot.coordinate = coordinate
                travellerMap.addAnnotation(annot)
            }
        }
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
       
        // navigate to the next screen with photo albums
        self.performSegue(withIdentifier: "toCollection", sender: view)
    }
 
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // prepare the cotroller before navigate to it
        if segue.identifier == "toCollection" {
            let view = sender as! MKAnnotationView
            let photoAlbum = segue.destination as! PhotoAlbumViewController
            let selectedPin = Pin(context:dataController.viewContext)
            selectedPin.long = view.annotation?.coordinate.longitude ?? 0.0
            selectedPin.lat = view.annotation?.coordinate.latitude ?? 0.0
            photoAlbum.pinLocation = selectedPin
        }
    }
}

