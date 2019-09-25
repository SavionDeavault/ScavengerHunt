//
//  ViewController.swift
//  ScavengerHunt
//
//  Created by Savion DeaVault on 9/9/19.
//  Copyright © 2019 Savion DeaVault. All rights reserved.
//

import UIKit
import SpriteKit
import ARKit
import CoreMotion
import MapKit

class MapViewController: UIViewController, ARSKViewDelegate, CLLocationManagerDelegate, MKMapViewDelegate {
    
    private let activityManager = CMMotionActivityManager()
    private let pedometer = CMPedometer()
    
    let activityTypeLabel = SKLabelNode(text: "Status")
    let stepsCountLabel = SKLabelNode(text: "Steps")
    
    var locationManager = CLLocationManager()
    
    @IBOutlet var mapView: MKMapView!
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
       super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest

        // Check for Location Services
        if (CLLocationManager.locationServicesEnabled()) {
            self.locationManager.requestAlwaysAuthorization()
            self.locationManager.requestWhenInUseAuthorization()
        }

        //Zoom to user location
        if let userLocation = locationManager.location?.coordinate {
            let viewRegion = MKCoordinateRegion(center: userLocation, latitudinalMeters: 200, longitudinalMeters: 200)
            self.mapView.setRegion(viewRegion, animated: false)
        }
        
        self.locationManager.startUpdatingLocation()
        
    }
    
    @IBAction func returnToHomeViewButton(_ sender: UIButton) {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let showViewController = storyBoard.instantiateViewController(withIdentifier: "MainViewController") as UIViewController
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        //show window
        appDelegate.window?.rootViewController = showViewController
    }
    
    @IBAction func relocateButton(_ sender: UIButton) {
       let noLocation = CLLocationCoordinate2D()
        let viewRegion = MKCoordinateRegion(center: noLocation, latitudinalMeters: 200, longitudinalMeters: 200)
        mapView.setRegion(viewRegion, animated: false)
        mapView.showsUserLocation = true
               print("Relocationg!")
    }
    
    func mapViewFunction(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: nil)
        annotationView.image = #imageLiteral(resourceName: "camera")
        
        
        var newFrame = annotationView.frame
        newFrame.size.width = 40
        newFrame.size.height = 40
        annotationView.frame = newFrame
        return annotationView
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
}
