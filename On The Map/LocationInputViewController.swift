//
//  LocationInputViewController.swift
//  On The Map
//
//  Created by Chris Garvey on 1/11/16.
//  Copyright © 2016 Chris Garvey. All rights reserved.
//

import UIKit
import MapKit

class LocationInputViewController: UIViewController, UITextFieldDelegate {
    
    // MARK: - Properties
    
    @IBOutlet weak var userLocationInput: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    var annotation: MKAnnotation!
    var localSearchRequest: MKLocalSearchRequest!
    var localSearch: MKLocalSearch!
    var localSearchResponse: MKLocalSearchResponse!
    var error: NSError!
    var pointAnnotation: MKPointAnnotation!
    
    
    // MARK: - Life Cycle
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
     
        // citation: http://stackoverflow.com/questions/30545663/transparent-uinavigationbar-in-swift
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.translucent = true
        self.navigationController?.view.backgroundColor = UIColor.clearColor()
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()

        userLocationInput.delegate = self
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(LocationInputViewController.tap(_:)))
        view.addGestureRecognizer(tapGesture)
    }
    
    
    // MARK: - Actions
    
    @IBAction func cancel(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func findOnTheMapTouchUpInside(sender: AnyObject) {
        submitLocation()
    }
    
    
    // MARK: - Helper Methods
    
    func submitLocation () {
        if userLocationInput.text == "" || userLocationInput.text == "Enter Your Location Here" {
            self.presentViewController(alert("Must Enter a Location."), animated: true, completion: nil)
        } else {
            activityIndicator.startAnimating()
            view.alpha = 0.5
            
            // citation: http://sweettutos.com/2015/04/24/swift-mapkit-tutorial-series-how-to-search-a-place-address-or-poi-in-the-map/
            localSearchRequest = MKLocalSearchRequest()
            localSearchRequest.naturalLanguageQuery = userLocationInput.text
            localSearch = MKLocalSearch(request: localSearchRequest)
            localSearch.startWithCompletionHandler { (localSearchResponse, error) -> Void in
                
                if localSearchResponse == nil {
                    performUIUpdatesOnMain {
                        self.activityIndicator.stopAnimating()
                        self.presentViewController(alert("Could Not Geocode the String."), animated: true, completion: { self.view.alpha = 1.0 })
                    }
                    return
                }
                
                self.pointAnnotation = MKPointAnnotation()
                self.pointAnnotation.title = self.userLocationInput.text
                self.pointAnnotation.coordinate = CLLocationCoordinate2D(latitude: localSearchResponse!.boundingRegion.center.latitude, longitude: localSearchResponse!.boundingRegion.center.longitude)
                
                self.activityIndicator.stopAnimating()
                self.view.alpha = 1.0
                // segue to the link input controller
                self.performSegueWithIdentifier("searchLocation", sender: self)
            }
        }
    }
    
    /* Dismiss keyboard if user touches outside the textfield */
    func tap(gesture: UITapGestureRecognizer) {
        userLocationInput.resignFirstResponder()
        if userLocationInput.text == "" {
            performUIUpdatesOnMain {
                self.userLocationInput.text = "Enter Your Location Here"
            }
        }
    }
    
    
    // MARK: - Text Field Delegate Methods
    
    func textFieldDidBeginEditing(textField: UITextField) {
        if textField.text == "Enter Your Location Here" {
            textField.text = ""
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        submitLocation()
        return true
    }
    

    // MARK: - Segue Method
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let controller = segue.destinationViewController as! LinkInputViewController
        controller.pointAnnotation = self.pointAnnotation
        controller.mapString = self.pointAnnotation.title
    }
    
}
