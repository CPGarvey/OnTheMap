//
//  LinkInputViewController.swift
//  On The Map
//
//  Created by Chris Garvey on 1/11/16.
//  Copyright © 2016 Chris Garvey. All rights reserved.
//

import UIKit
import MapKit

class LinkInputViewController: UIViewController, UITextFieldDelegate {
 
    // MARK: - Properties
    
    var pointAnnotation: MKPointAnnotation!
    var pinAnnotationView: MKPinAnnotationView!
    var mapString: String!
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var userLinkInput: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userLinkInput.delegate = self
        
        /* Hide the Back Button in the Navigation Bar */
        /* Citation: http://stackoverflow.com/questions/27373812/swift-how-to-hide-back-button-in-navigation-item */
        self.navigationItem.setHidesBackButton(true, animated:true)
        
        
        pinAnnotationView = MKPinAnnotationView(annotation: pointAnnotation, reuseIdentifier: nil)
        mapView.centerCoordinate = pointAnnotation.coordinate
        mapView.addAnnotation(pinAnnotationView.annotation!)
        
        
        let initialLocation = CLLocation(latitude: pointAnnotation.coordinate.latitude, longitude: pointAnnotation.coordinate.longitude)
        centerMapOnLocation(initialLocation)
        
        let geoCoder = CLGeocoder()
        geoCoder.reverseGeocodeLocation(initialLocation) { placeMarkArray, NSError in
            
            for placemark in placeMarkArray! {
                print(placemark.country)
            }
            
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(LinkInputViewController.tap(_:)))
        view.addGestureRecognizer(tapGesture)
        
    }
    
    
    // MARK: - Actions
    
    @IBAction func cancel(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func submitTouchUpInside(sender: UIButton) {
            submitLink()
    }
    
    
    // MARK: - Helper Functions
    
    func centerMapOnLocation(location: CLLocation) {
        // citation: http://www.raywenderlich.com/90971/introduction-mapkit-swift-tutorial
        let regionRadius: CLLocationDistance = 8000
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
            regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    func submitLink() {
        if userLinkInput.text!.isEmpty || userLinkInput.text! == "Enter a Link to Share Here" {
            performUIUpdatesOnMain {
                self.presentViewController(alert("Empty Link."), animated: true, completion: nil)
            }
        } else {
            startPosting()
        }
    }

    func startPosting() {
        activityIndicator.startAnimating()
        view.alpha = 0.5
        
        UserInformation.user.mapString = mapString
        UserInformation.user.mediaURL = userLinkInput.text
        UserInformation.user.userPointAnnotation = pointAnnotation
        
        ParseClient.sharedInstance().postStudentLocationAndLink() { (success, errorString) in
            if success {
                performUIUpdatesOnMain {
                    self.dismissViewControllerAnimated(true, completion: nil)
                }
            } else {
                performUIUpdatesOnMain {
                    self.activityIndicator.stopAnimating()
                    self.view.alpha = 1.0
                    self.presentViewController(alert(errorString!), animated: true, completion: nil)
                }
            }
        }
    }
    
    /* Dismiss keyboard if user touches outside the textfield */
    func tap(gesture: UITapGestureRecognizer) {
        userLinkInput.resignFirstResponder()
        if userLinkInput.text == "" {
            performUIUpdatesOnMain {
                self.userLinkInput.text = "Enter a Link to Share Here"
            }
        }
    }
    
    
    // MARK: - Text Field Delegate Methods
    
    func textFieldDidBeginEditing(textField: UITextField) {
        if textField.text == "Enter a Link to Share Here" {
            textField.text = ""
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        submitLink()
        return true
    }

}
