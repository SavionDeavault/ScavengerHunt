//
//  Scene.swift
//  ScavengerHunt
//
//

import SpriteKit
import ARKit

class Scene: SKScene {
        
    var creationTime : TimeInterval = 0
    var viewController: ViewController = ViewController(nibName: nil, bundle: nil)
    var nodeCount = 0
    
    override func didMove(to view: SKView) {
        
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        if currentTime > creationTime {
            createNode()
            creationTime = currentTime + TimeInterval(randomFloat(min: 3.0, max: 6.0))
            viewController.startUpdating()
        }
          let buttonTexture: SKTexture! = SKTexture(imageNamed: "button")
          let buttonTextureSelected: SKTexture! = SKTexture(imageNamed: "buttonSelected.png")
          let backBtn = SKSceneButton(defaultTexture: buttonTexture, selectedTexture:buttonTextureSelected, disabledTexture: buttonTexture)
        backBtn.setButtonAction(target: self, triggerEvent: .TouchUpInside, action: #selector(Scene.backBtnTap))
        backBtn.position = CGPoint(x: self.frame.midX + 150, y: self.frame.midY + 200)
        backBtn.zPosition = 1
        backBtn.name = "backBtn"
        self.addChild(backBtn)
    }
    
    func randomFloat(min: Float, max: Float) -> Float {
        return (Float(arc4random()) / 4294967295.0) * (max - min) + min
    }
    
    @objc func backBtnTap() {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let showViewController = storyBoard.instantiateViewController(withIdentifier: "MapViewController") as UIViewController
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        //show window
        appDelegate.window?.rootViewController = showViewController
    }
    
    func createNode(){
        guard (self.view as? ARSKView) != nil else {
            return
        }
        
        // Define 360º in radians
        let _360degrees = 2.0 * Float.pi
        
        // Create a rotation matrix in the X-axis
        let rotateX = simd_float4x4(SCNMatrix4MakeRotation(_360degrees * randomFloat(min: 0.0, max: 1.0), 1, 0, 0))
        
        // Create a rotation matrix in the Y-axis
        let rotateY = simd_float4x4(SCNMatrix4MakeRotation(_360degrees * randomFloat(min: 0.0, max: 1.0), 0, 1, 0))
        
        // Combine both rotation matrices
        let rotation = simd_mul(rotateX, rotateY)
        
        // Create a translation matrix in the Z-axis with a value between 1 and 2 meters
        var translation = matrix_identity_float4x4
        translation.columns.3.z = -1 - randomFloat(min: 0.0, max: 1.0)
        
        // Combine the rotation and translation matrices
        let transform = simd_mul(rotation, translation)
        
        // Create an anchor
        _ = ARAnchor(transform: transform)
        
        // Add the anchor
       // sceneView.session.add(anchor: anchor)
        
        // Increment the counter
        nodeCount += 1
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Get the first touch
        guard let touch = touches.first else {
            return
        }
        // Get the location in the AR scene
        let location = touch.location(in: self)
        
        // Get the nodes at that location
        let hit = nodes(at: location)
        
        // Get the first node (if any)
        if let node = hit.first {
            // Check if the node is a image (remember that labels are also a node)
            if node.name == "image" {
                let fadeOut = SKAction.fadeOut(withDuration: 0.5)
                let remove = SKAction.removeFromParent()
                
                // Group the fade out and sound actions
                let groupKillingActions = SKAction.group([fadeOut])
                // Create an action sequence
                let sequenceAction = SKAction.sequence([groupKillingActions, remove])
                
                // Excecute the actions
                node.run(sequenceAction)
                
                // Update the counter
                nodeCount -= 1
            }
            
        }
    }
}
