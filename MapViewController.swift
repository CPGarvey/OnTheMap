//
//  MapViewController.swift
//  On The Map
//
//  Created by Chris Garvey on 1/4/16.
//  Copyright © 2016 Chris Garvey. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {
    
    // MARK: - Properties
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        ParseClient.sharedInstance().getStudentLocations() { (success, errorString) in
            if success == true {
                performUIUpdatesOnMain {
                    
                    /* Clear current annotations before adding new annotations */
                    /* Citation: http://stackoverflow.com/questions/32850094/how-do-i-remove-all-map-annotations-in-swift-2 */
                    let allAnnotations = self.mapView.annotations
                    self.mapView.removeAnnotations(allAnnotations)
                    
                    /* Add new annotations */
                    self.createMapAnnotations()
                }
            } else {
                performUIUpdatesOnMain {
                    self.presentViewController(alert(errorString!), animated: true, completion: nil)
                }
            }
        }
    }
    
    
    // MARK: - Map View Annotation Functions
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = UIColor.redColor()
            pinView!.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
        
            if let url = NSURL(string: (view.annotation?.subtitle!)!) {
                
                guard UIApplication.sharedApplication().openURL(url) else {
                    
                    /* Check if URL is invalid because http:// is missing */
                    if let url = NSURL(string: "http://" + (view.annotation?.subtitle!)!) {
                        
                        guard UIApplication.sharedApplication().openURL(url) else {
                            
                            self.presentViewController(alert("URL is invalid, please select another link."), animated: true, completion: nil)
                            
                            return
                        }
                        
                    } else {
                        
                        self.presentViewController(alert("URL is invalid, please select another link."), animated: true, completion: nil)
                    }
                    
                    return
                }
                
            } else {
                
                self.presentViewController(alert("URL is invalid, please select another link."), animated: true, completion: nil)
            }
        
        }
        
    }
    
    
    // MARK: - Helper Function
    
    func createMapAnnotations() {
        
        var annotations = [MKPointAnnotation]()
        
        for student in StudentData.students {
            
            let lat = CLLocationDegrees(student.latitude)
            let long = CLLocationDegrees(student.longitude)
            
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
            
            
            let first = student.firstName
            let last = student.lastName
            let mediaURL = student.mediaURL
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = "\(first) \(last)"
            annotation.subtitle = mediaURL

            annotations.append(annotation)
        }
        mapView.addAnnotations(annotations)
    }

}
