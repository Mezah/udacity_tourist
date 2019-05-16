//
//  FlickerDownload.swift
//  TouristApp
//
//  Created by Hazem on 5/15/19.
//  Copyright © 2019 Hazem. All rights reserved.
//

import Foundation
import UIKit

class FlickerDownload {
    private let dataController = DataController.shared
    // create session and request
    let session = URLSession.shared
    
    private func checkResults(_ data:Data?, _ response:URLResponse?, _ error:Error?,_ displayError:(String) -> Void ) {
        
       
    }
    private func displayImageFromFlickrBySearch(_ pin:Pin,_ methodParameters: [String: AnyObject],_ onSuccess: @escaping ()->Void,_ onError:@escaping ()->Void) {

       
        let request = URLRequest(url: flickrURLFromParameters(methodParameters))

        // create network request
        let task = session.dataTask(with: request) { (data, response, error) in

            // if an error occurs, print it and re-enable the UI
            func displayError(_ error: String) {
                print(error)
                performUIUpdatesOnMain {
                    // TODO : on Error perform some action
                    onError()
                }
            }

            /* GUARD: Was there an error? */
            guard (error == nil) else {
                displayError("There was an error with your request: \(error)")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                displayError("Your request returned a status code other than 2xx!")
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                displayError("No data was returned by the request!")
                return
            }
            // parse the data
            let parsedResult: [String:AnyObject]!
            do {
                parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:AnyObject]
            } catch {
                displayError("Could not parse the data as JSON: '\(data)'")
                return
            }
            
            /* GUARD: Did Flickr return an error (stat != ok)? */
            guard let stat = parsedResult[Constants.FlickrResponseKeys.Status] as? String, stat == Constants.FlickrResponseValues.OKStatus else {
                displayError("Flickr API returned an error. See error code and message in \(parsedResult)")
                return
            }
            /* GUARD: Is "photos" key in our result? */
            guard let photosDictionary = parsedResult[Constants.FlickrResponseKeys.Photos] as? [String:AnyObject] else {
                displayError("Cannot find keys '\(Constants.FlickrResponseKeys.Photos)' in \(parsedResult)")
                return
            }
            /* GUARD: Is "pages" key in the photosDictionary? */
            guard let totalPages = photosDictionary[Constants.FlickrResponseKeys.Pages] as? Int else {
                displayError("Cannot find key '\(Constants.FlickrResponseKeys.Pages)' in \(photosDictionary)")
                return
            }

            // pick a random page!
            let pageLimit = min(totalPages, 40)
            let randomPage = Int(arc4random_uniform(UInt32(pageLimit))) + 1
            self.displayImageFromFlickrBySearchWithPage(pin,methodParameters, withPageNumber: randomPage,onSuccess,onError)
        }

        // start the task!
        task.resume()
    }


    private func displayImageFromFlickrBySearchWithPage(_ pin:Pin,_ methodParameters: [String: AnyObject], withPageNumber: Int,_ onSuccess: @escaping ()->Void,_ onError:@escaping ()->Void) {

        // add the page to the method's parameters
        var methodParametersWithPageNumber = methodParameters
        methodParametersWithPageNumber[Constants.FlickrParameterKeys.Page] = String(withPageNumber) as AnyObject

        // create session and request
        let session = URLSession.shared
        let request = URLRequest(url: flickrURLFromParameters(methodParameters))

        // create network request
        let task = session.dataTask(with: request) { (data, response, error) in

            // if an error occurs, print it and re-enable the UI
            func displayError(_ error: String) {
                print(error)
                performUIUpdatesOnMain {
                   onError()
                }
            }

            /* GUARD: Was there an error? */
            guard (error == nil) else {
                displayError("There was an error with your request: \(error)")
                return
            }

            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                displayError("Your request returned a status code other than 2xx!")
                return
            }

            /* GUARD: Was there any data returned? */
            guard let data = data else {
                displayError("No data was returned by the request!")
                return
            }

            // parse the data
            let parsedResult: [String:AnyObject]!
            do {
                parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:AnyObject]
            } catch {
                displayError("Could not parse the data as JSON: '\(data)'")
                return
            }

            /* GUARD: Did Flickr return an error (stat != ok)? */
            guard let stat = parsedResult[Constants.FlickrResponseKeys.Status] as? String, stat == Constants.FlickrResponseValues.OKStatus else {
                displayError("Flickr API returned an error. See error code and message in \(parsedResult)")
                return
            }

            /* GUARD: Is the "photos" key in our result? */
            guard let photosDictionary = parsedResult[Constants.FlickrResponseKeys.Photos] as? [String:AnyObject] else {
                displayError("Cannot find key '\(Constants.FlickrResponseKeys.Photos)' in \(parsedResult)")
                return
            }

            /* GUARD: Is the "photo" key in photosDictionary? */
            guard let photosArray = photosDictionary[Constants.FlickrResponseKeys.Photo] as? [[String: AnyObject]] else {
                displayError("Cannot find key '\(Constants.FlickrResponseKeys.Photo)' in \(photosDictionary)")
                return
            }

            if photosArray.count == 0 {
                displayError("No Photos Found. Search Again.")
                return
            } else {

                
                var photosList = [UIImage]()
                for photo in photosArray{
                    let photoDic = photo as [String: AnyObject]
                    /* GUARD: Does our photo have a key for 'url_m'? */
                    if let imageUrlString = photoDic[Constants.FlickrResponseKeys.MediumURL] as? String {
                        let imageURL = URL(string: imageUrlString)
                        print("This is image Url \(imageURL)")
                        if let imageData = try? Data(contentsOf: imageURL!){
                            
                            var photo = Photo(context: self.dataController.viewContext)
                            photo.imageUrl = imageUrlString
                            photo.imageContent = imageData
                            pin.addToPhotos(photo)
//                            photosList.append(UIImage(data: imageData)!)
                        }
                    }

                }
    
                performUIUpdatesOnMain {
                    onSuccess()
                }
            }
        }

        // start the task!
        task.resume()
    }

    func loadImageByLatLon(_ pin:Pin, success onSuccess: @escaping ()->Void,failed onError:@escaping ()->Void){
        //            photoTitleLabel.text = "Searching..."
        //TODO : Show Some sort of loading
        let methodParameters = [
            Constants.FlickrParameterKeys.Method: Constants.FlickrParameterValues.SearchMethod,
            Constants.FlickrParameterKeys.APIKey: Constants.FlickrParameterValues.APIKey,
            Constants.FlickrParameterKeys.Longitude: String(pin.long),
            Constants.FlickrParameterKeys.Latitude:String(pin.lat),
            Constants.FlickrParameterKeys.PageLimit:"5",
            Constants.FlickrParameterKeys.SafeSearch: Constants.FlickrParameterValues.UseSafeSearch,
            Constants.FlickrParameterKeys.Extras: Constants.FlickrParameterValues.MediumURL,
            Constants.FlickrParameterKeys.Format: Constants.FlickrParameterValues.ResponseFormat,
            Constants.FlickrParameterKeys.NoJSONCallback: Constants.FlickrParameterValues.DisableJSONCallback
        ]
        displayImageFromFlickrBySearch(pin,methodParameters as [String:AnyObject],onSuccess,onError)
    }

}
