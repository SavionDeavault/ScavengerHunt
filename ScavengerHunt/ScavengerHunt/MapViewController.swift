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
    
    var locationManager = CLLocationManager()
    var currentLocation: CLLocation! = nil
    
    var defaults = UserDefaults.standard

    
    @IBOutlet weak var inventoryButton: UIButton!
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet var mapView: MKMapView!
    @IBOutlet weak var stepsLabel: UILabel!
    @IBOutlet weak var hiddenLabel: UILabel!
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
       super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (CLLocationManager.authorizationStatus() != .authorizedWhenInUse || CLLocationManager.authorizationStatus() !=  .authorizedAlways){
            print("Couldn't get user location!")
            if((UIDevice.current.systemVersion as NSString).floatValue >= 8){
                locationManager.requestWhenInUseAuthorization()
            }
        }
        
        if currentLocation == nil{
            currentLocation = locationManager.location
        }
         
        if (CLLocationManager.locationServicesEnabled()){
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestAlwaysAuthorization()
            locationManager.startUpdatingLocation()
        }else{
            print("Location services are not enabled")
            exit(0)
        }

        //Zoom to user location
        if let userLocation = locationManager.location?.coordinate {
            let viewRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: userLocation.latitude, longitude: userLocation.longitude), latitudinalMeters: currentLocation.distance(from: currentLocation), longitudinalMeters: currentLocation.distance(from: currentLocation))
            mapView.setRegion(viewRegion, animated: true)
            mapView.showsUserLocation = true
            let mapCamera = MKMapCamera()
            mapCamera.centerCoordinate = locationManager.location!.coordinate
            mapCamera.pitch = 45
            mapCamera.altitude = 500
            mapCamera.heading = 45
            mapView.camera = mapCamera
            mapView.mapType = .hybridFlyover
            mapView.showsCompass = false
        }
        generateRandomCircle()
        startUpdating()
        hiddenLabel.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    
    @IBAction func showSettings(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let settingsViewController = storyboard.instantiateViewController(withIdentifier: "SettingsViewController") as? UITableViewController else {
            return
        }
        
        let barButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissSettings))
        settingsViewController.navigationItem.rightBarButtonItem = barButtonItem
        settingsViewController.title = "Setting"
        
        let navigationController = UINavigationController(rootViewController: settingsViewController)
        navigationController.modalPresentationStyle = .popover
        navigationController.popoverPresentationController?.delegate = self as? UIPopoverPresentationControllerDelegate
        navigationController.preferredContentSize = CGSize(width: mapView.bounds.size.width - 20, height: mapView.bounds.size.height - 100)
        self.present(navigationController, animated: true, completion: nil)
        
        navigationController.popoverPresentationController?.sourceView = settingsButton
        navigationController.popoverPresentationController?.sourceRect = settingsButton.bounds
    }
    
    @objc func dismissSettings(){
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func relocateButton(_ sender: UIButton) {
        let viewRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: currentLocation.coordinate.latitude, longitude: currentLocation.coordinate.longitude), latitudinalMeters: currentLocation.distance(from: currentLocation), longitudinalMeters: currentLocation.distance(from: currentLocation))
        mapView.setRegion(viewRegion, animated: true)
        mapView.showsUserLocation = true
        let mapCamera = MKMapCamera()
        mapCamera.centerCoordinate = locationManager.location!.coordinate
        mapCamera.pitch = 45
        mapCamera.altitude = 500
        mapCamera.heading = 45
        mapView.camera = mapCamera
        mapView.mapType = .hybridFlyover
        mapView.showsCompass = false
    }
    
    @IBAction func showCamera(_ sender: UIButton) {
        if !isInsideCircle(){
            hiddenLabel.isHidden = false
            hiddenLabel.text = "Cannot open camera until you enter a circle!"
            DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
                self.hiddenLabel.text = ""
                self.hiddenLabel.isHidden = true
            }
        }else{
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let showViewController = storyBoard.instantiateViewController(withIdentifier: "ARSceneViewController") as UIViewController
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.window?.rootViewController = showViewController
        }
    }
    
    @IBAction func showInventory(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let inventoryViewController = storyboard.instantiateViewController(withIdentifier: "TableViewController") as? UITableViewController else {
            return
        }
        
        let barButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissSettings))
        inventoryViewController.navigationItem.rightBarButtonItem = barButtonItem
        inventoryViewController.title = "Inventory"
        
        let navigationController = UINavigationController(rootViewController: inventoryViewController)
        navigationController.modalPresentationStyle = .popover
        navigationController.popoverPresentationController?.delegate = self as? UIPopoverPresentationControllerDelegate
        navigationController.preferredContentSize = CGSize(width: mapView.bounds.size.width - 20, height: mapView.bounds.size.height - 100)
        self.present(navigationController, animated: true, completion: nil)
        
        navigationController.popoverPresentationController?.sourceView = inventoryButton
        navigationController.popoverPresentationController?.sourceRect = inventoryButton.bounds
       
        /*  let tableView = TableViewController(nibName: nil, bundle: nil)
        tableView.title = "Inventory"

        let navigationController = UINavigationController(rootViewController: tableView)

        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = navigationController
        window.makeKeyAndVisible()*/
    }
    
    func randomCoordinate() -> Double {
        return (Double(arc4random_uniform(200)) - 100) / 50000.0
    }
    
    func generateRandomCircle() {
        if PropertyManager.instance.hasCirclesBeenGenerated == false{
            DispatchQueue.main.async{
                for n in 0...PropertyManager.instance.maxCircles{
                    let latitude = self.currentLocation.coordinate.latitude + self.randomCoordinate()
                    let longitude = self.currentLocation.coordinate.longitude + self.randomCoordinate()
                    
                    let randomCoord = CLLocationCoordinate2DMake(latitude, longitude)
                    if CLLocationCoordinate2DIsValid(randomCoord) && self.currentLocation.distance(from: CLLocation(latitude: randomCoord.latitude, longitude: randomCoord.longitude)) <= 1609{
                        self.addRadiusCircle(location: CLLocation(latitude: randomCoord.latitude, longitude: randomCoord.longitude), radius: 25, arrayIndex: n)
                        PropertyManager.instance.circlesGenerated += 1
                        if PropertyManager.instance.circlesGenerated == PropertyManager.instance.maxCircles{
                            PropertyManager.instance.hasCirclesBeenGenerated = true
                        }
                    }else{
                        if PropertyManager.instance.circlesGenerated != PropertyManager.instance.maxCircles {
                            self.generateRandomCircle()
                        }
                    }
                }
            }
        }else{
            for n in 0...PropertyManager.instance.maxCircles{
                let location = PropertyManager.instance.circlesArray[n]
                self.mapView.delegate = self
                let circle = MKCircle(center: CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude), radius: CLLocationDistance(25))
                self.mapView.addOverlay(circle)
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKCircle {
            let circle = MKCircleRenderer(overlay: overlay)
            circle.strokeColor = UIColor.purple
            circle.fillColor = UIColor.purple
            circle.lineWidth = 5
            return circle
        } else {
            return MKPolylineRenderer()
        }
    }
    
    func addRadiusCircle(location: CLLocation, radius: Int, arrayIndex: Int) {
        self.mapView.delegate = self
        let circle = MKCircle(center: CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude), radius: CLLocationDistance(radius))
        self.mapView.addOverlay(circle)
        PropertyManager.instance.circleRadius = radius
        let circleLocation = CLLocation(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        PropertyManager.instance.circlesArray.append(circleLocation)
    }
    
    func isInsideCircle() -> Bool {
        if PropertyManager.instance.timeUntilCircleCheck <= 0{
            for n in 0...PropertyManager.instance.maxCircles{
                if self.currentLocation.distance(from: PropertyManager.instance.circlesArray[n]) <= 25{
                    print("Inside circle #\(n)")
                    return true
                }else{
                    return false
                    // print("Outside circle")
                }
            }
        }else{
            print("Time until circle check!\(PropertyManager.instance.timeUntilCircleCheck)")
            PropertyManager.instance.timeUntilCircleCheck -= 1
        }
        return false
    }
    
    private func startTrackingActivityType() {
      activityManager.startActivityUpdates(to: OperationQueue.main) {
        [weak self] (activity: CMMotionActivity?) in guard let activity = activity else { return }
          DispatchQueue.main.async {
              if activity.walking {
                  PropertyManager.instance.activityType = "Walking"
              } else if activity.stationary {
                  PropertyManager.instance.activityType = "Stationary"
              } else if activity.running {
                  PropertyManager.instance.activityType = "Running"
              } else if activity.automotive {
                  PropertyManager.instance.activityType = "Automotive"
              }
          }
      }
    }
    
    private func startCountingSteps() {
      pedometer.startUpdates(from: Date()) {
          [weak self] pedometerData, error in
          guard let pedometerData = pedometerData, error == nil else { return }

          DispatchQueue.main.async {
              PropertyManager.instance.stepsCount = pedometerData.numberOfSteps.stringValue
            self?.stepsLabel.text = "Steps: \(PropertyManager.instance.stepsCount ?? "0")"
              if let stepsData = self!.defaults.string(forKey: "steps"){
                print(stepsData)
                self!.defaults.set("steps", forKey: (stepsData + PropertyManager.instance.stepsCount!))
              }else{
                self!.defaults.set("steps", forKey: PropertyManager.instance.stepsCount!)
              }
          }
      }
    }
    
    private func startUpdating() {
      if CMMotionActivityManager.isActivityAvailable() {
          startTrackingActivityType()
      }

      if CMPedometer.isStepCountingAvailable() {
          startCountingSteps()
      }
    }
    
}
