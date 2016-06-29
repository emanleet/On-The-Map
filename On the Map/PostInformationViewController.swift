//
//  PostInformationViewController.swift
//  On the Map
//
//  Created by Emmanuoel Eldridge on 6/26/16.
//  Copyright © 2016 Emmanuoel Haroutunian. All rights reserved.
//

import UIKit
import MapKit

class PostInformationViewController: UIViewController, UIToolbarDelegate {
    
    @IBOutlet weak var topToolbar: UIToolbar!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var mapStringTextField: UITextField!
    @IBOutlet weak var searchMapStackView: UIStackView!
    @IBOutlet weak var urlTextField: UITextField!
    @IBOutlet weak var shareStackView: UIStackView!
    var annotationsArray = [MKPointAnnotation]()
    
    
    // Assign values to these properties and store into Parse Client
    var mapString: String?
    var mediaURL: String?
    var latitude: Float?
    var longitude: Float?
    
    
    @IBAction func searchMap() {
        activityIndicatorView.hidden = false
        activityIndicatorView.startAnimating()
        
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(mapStringTextField.text!) { (placemarks, error) in
            
            self.activityIndicatorView.stopAnimating()
            self.activityIndicatorView.hidden = true
            
            if let error = error {
                print("Error Code Is: \(error.code)")
                self.displayErrorAlert(error)
            } else if let placemarks = placemarks {
                self.mapView.removeAnnotations(self.annotationsArray)
                let annotation = MKPointAnnotation()
                annotation.coordinate = (placemarks[0].location?.coordinate)!
                
                self.mapString = self.mapStringTextField.text
                self.latitude = Float(annotation.coordinate.latitude)
                self.longitude = Float(annotation.coordinate.longitude)
                
                self.annotationsArray.append(annotation)
                self.mapView.addAnnotation(annotation)
                self.zoomToAnnotation(annotation)
                
                self.searchMapStackView.hidden = true
                self.shareStackView.hidden = false
            }
        }
    }
    
    @IBAction func submitStudentInfo(sender: AnyObject) {
        
        mediaURL = urlTextField.text
        
        UdacityClient.sharedInstance.getUserInfo() { (success, error) in
            if let error = error {
                print(error.localizedDescription)
            } else {
                if let uniqueKey = UdacityClient.sharedInstance.accountKey, firstName = UdacityClient.sharedInstance.userFirstName, lastName = UdacityClient.sharedInstance.userLastName, mapString = self.mapString, mediaURL = self.mediaURL, latitude = self.latitude, longitude = self.longitude {
                    
                    let studentInfo = StudentInformation(objectId: nil, uniqueKey: uniqueKey, firstName: firstName, lastName: lastName, mapString: mapString, mediaURL: mediaURL, latitude: latitude, longitude: longitude)
                    
                    ParseClient.sharedInstance.taskForPOSTMethod(ParseClient.Constants.Scheme, host: ParseClient.Constants.Host, path: ParseClient.Methods.StudentLocation, parameters: [String: AnyObject](), student: studentInfo) { (result, error) in
                        
                        if let error = error {
                            print(error.localizedDescription)
                        } else if result != nil {
                            print("SUCCESSFUL UPLOAD")
                        }
                    }

                }
            }
        }
    }
    
    
    
    @IBAction func cancelPostInformation() {
        dismissViewControllerAnimated(true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        shareStackView.hidden = true
        activityIndicatorView.hidden = true
        topToolbar.delegate = self
        positionForBar(topToolbar)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func zoomToAnnotation(annotation: MKPointAnnotation) {
        let latDelta: CLLocationDegrees = 0.05
        let longDelta: CLLocationDegrees = 0.05
        let span = MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: longDelta)
        let region = MKCoordinateRegion(center: annotation.coordinate, span: span)
        mapView.setRegion(region, animated: true)
    }
    
    func positionForBar(bar: UIBarPositioning) -> UIBarPosition {
        return .TopAttached
    }
    
}