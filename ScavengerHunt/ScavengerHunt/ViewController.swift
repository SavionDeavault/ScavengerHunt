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

class ViewController: UIViewController, ARSKViewDelegate, CLLocationManagerDelegate {
    
    private let activityManager = CMMotionActivityManager()
    private let pedometer = CMPedometer()
    
    let activityTypeLabel = SKLabelNode(text: "Status")
    let stepsCountLabel = SKLabelNode(text: "Steps")
    let locationManager = CLLocationManager()
    
    @IBOutlet var sceneView: ARSKView!
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
       super.init(coder: aDecoder)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Set the view's delegate
        sceneView.delegate = self
        let scene = Scene(size: sceneView.bounds.size)
        scene.scaleMode = .resizeFill
        sceneView.presentScene(scene)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Run the view's session
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        //configuration.planeDetection = .horizontal
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
    func randomInt(min: Int, max: Int) -> Int {
        return min + Int(arc4random_uniform(UInt32(max - min + 1)))
    }
    
    private func startTrackingActivityType() {
      activityManager.startActivityUpdates(to: OperationQueue.main) {
          [weak self] (activity: CMMotionActivity?) in

          guard let activity = activity else { return }
          DispatchQueue.main.async {
              if activity.walking {
                  self?.activityTypeLabel.text = "Walking"
              } else if activity.stationary {
                  self?.activityTypeLabel.text = "Stationary"
              } else if activity.running {
                  self?.activityTypeLabel.text = "Running"
              } else if activity.automotive {
                  self?.activityTypeLabel.text = "Automotive"
              }
          }
      }
    }
    
    private func startCountingSteps() {
      pedometer.startUpdates(from: Date()) {
          [weak self] pedometerData, error in
          guard let pedometerData = pedometerData, error == nil else { return }

          DispatchQueue.main.async {
              self?.stepsCountLabel.text = pedometerData.numberOfSteps.stringValue
          }
      }
    }
    
    func startUpdating() {
      if CMMotionActivityManager.isActivityAvailable() {
          startTrackingActivityType()
        print(self.stepsCountLabel.text!)
        print(self.activityTypeLabel.text!)
      }

      if CMPedometer.isStepCountingAvailable() {
          startCountingSteps()
      }
    }
    
    // MARK: - ARSKViewDelegate
    
    func view(_ view: ARSKView, nodeFor anchor: ARAnchor) -> SKNode? {
        let id = randomInt(min: 1, max: 1)
        
        let node = SKSpriteNode(imageNamed: "image\(id)")
        node.name = "image"
        
        return node
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}
