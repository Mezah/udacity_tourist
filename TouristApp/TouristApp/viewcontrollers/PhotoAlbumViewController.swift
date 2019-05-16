//
//  PhotoAlbumViewController.swift
//  TouristApp
//
//  Created by Hazem on 5/11/19.
//  Copyright © 2019 Hazem. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class PhotoAlbumViewController: UIViewController,MKMapViewDelegate,UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var photoAlbumLocation: MKMapView!
    
    var long :Double!
    var lat :Double!
    
    var photosList = [Photo]() // array of images to be displayed
    private let dataController = DataController.shared
    
    @IBOutlet weak var albumCollectionView: UICollectionView!
    private let flickerDownload = FlickerDownload()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        albumCollectionView.delegate = self
        
        let mkPoint = MKPointAnnotation()
        mkPoint.coordinate.longitude = long
        mkPoint.coordinate.latitude = lat
        photoAlbumLocation.addAnnotation(mkPoint)
        let fetchReq : NSFetchRequest<Pin> = Pin.fetchRequest()
        let predicate = NSPredicate(format: "long == %@", String(long))
        fetchReq.predicate = predicate
        if let pinsResult = try? dataController.viewContext.fetch(fetchReq){
            for photo in pinsResult[0].photos as! Set<Photo> {
                photosList.append(photo)
            }
            albumCollectionView.reloadData()
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

    //MARK: Collection View delegates
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return photosList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionImage", for: indexPath) as! CustomCollectionViewCell
        let photo = photosList[(indexPath as NSIndexPath).row]
        cell.locationImage.image = UIImage(data:photo.imageContent!)!
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let photo = photosList[(indexPath as NSIndexPath).row]
        removeFromLocal(photo,(indexPath as NSIndexPath).row)
        albumCollectionView.deleteItems(at: [indexPath])
    }
    
    func removeFromLocal(_ photo:Photo,_ pos:Int) {
        dataController.viewContext.delete(photo)
        try? dataController.viewContext.save()
        photosList.remove(at: pos)
        
    }
}
