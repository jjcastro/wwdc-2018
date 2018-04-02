
import Foundation
import UIKit
import ARKit
import SceneKit

public class BlocksARViewController: ARViewController {
    var blockWidth: Float = 1.0
    var blockHeight: Float = 1.0
    var blockDepth: Float = 1.0
    
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
    
    override func insertGeometry(hitResult: ARHitTestResult) {
        let width = CGFloat(blockWidth * 0.15)
        let height = CGFloat(blockHeight * 0.15)
        let depth = CGFloat(blockDepth * 0.15)
        
        let cube = SCNBox(width: width, height: height, length: depth, chamferRadius: 0.008)
        
        cube.materials = [SCNMaterial(name: "plastic")]
        let node = SCNNode(geometry: cube)
        
        node.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
        node.physicsBody?.mass = 2.0
        node.physicsBody?.categoryBitMask = CollisionCategory.cube.rawValue
        node.physicsBody?.contactTestBitMask = 0
        node.physicsBody?.collisionBitMask = 0xFFFFFFFF
        
        let insertionYOffset = Float(0.5)
        node.position = SCNVector3(
            hitResult.worldTransform.columns.3.x,
            hitResult.worldTransform.columns.3.y + insertionYOffset,
            hitResult.worldTransform.columns.3.z
        )
        
        addedNodes.append(node)
        sceneView.scene.rootNode.addChildNode(node)
    }
    
    override func setupScene() {
        sceneView = ARSCNView(frame:CGRect(x: 0.0, y: 0.0, width: 500.0, height: 600.0))
        sceneView.delegate = self
        sceneView.antialiasingMode = .multisampling4X
        
        // Set the scene
        let scene = SCNScene()
        sceneView.scene = scene
//        sceneView.debugOptions = [.showPhysicsShapes]
        
        sceneView.scene.physicsWorld.contactDelegate = self
        self.view = sceneView
    }
    
    public func setSizes(width: Float, height: Float, depth: Float) {
        blockWidth = width
        blockHeight = height
        blockDepth = depth
    }
}
