
import Foundation
import UIKit
import ARKit
import SceneKit

public class BlocksARViewController: ARViewController {
    override func setupLights() {
        self.sceneView.autoenablesDefaultLighting = false
        self.sceneView.automaticallyUpdatesLighting = false
        
        let image = UIImage(named: "Environment/spherical-old.jpg")!
        self.sceneView.scene.lightingEnvironment.contents = image
    }
    
    override public func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        guard let estimate = self.sceneView.session.currentFrame?.lightEstimate else {
            return
        }
        
        let intensity = estimate.ambientIntensity / 1000.0
        self.sceneView.scene.lightingEnvironment.intensity = intensity
    }
    
    override func setupScene() {
        sceneView = ARSCNView(frame:CGRect(x: 0.0, y: 0.0, width: 500.0, height: 600.0))
        sceneView.delegate = self
        sceneView.antialiasingMode = .multisampling4X
        
        // Set the scene
        let scene = SCNScene()
        sceneView.scene = scene
        
        sceneView.scene.physicsWorld.contactDelegate = self
        self.view = sceneView
    }
}
