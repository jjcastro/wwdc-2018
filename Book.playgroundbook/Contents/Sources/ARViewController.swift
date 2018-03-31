
import Foundation
import UIKit
import ARKit
import SceneKit

public class ARViewController: UIViewController, ARSCNViewDelegate, SCNPhysicsContactDelegate {
    public var sceneView: ARSCNView!
    public var infoLabel = PaddingLabel()
    
    var planes = [UUID: Plane]()
    var addedNodes = [SCNNode]()
    
    let trees = ["Fir_Tree", "Lil_Tree", "Palm_Tree"]
    var treeCounter = 0
    
    open override func loadView() {
        setupScene()
        setupLights()
        setupInfoLabel()
        addBottomPlane()
        setupGestures()
        
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = .horizontal
        config.isLightEstimationEnabled = true
        sceneView.session.run(config)
    }
    
    func setupInfoLabel() {
        infoLabel.text = "Move around to detect surfaces 🔍"
        
        infoLabel.backgroundColor = UIColor(white: 1.0, alpha: 0.5)
        infoLabel.textAlignment = .center
        infoLabel.layer.masksToBounds = true
        infoLabel.layer.zPosition = 2
        infoLabel.layer.cornerRadius = 5.0
        infoLabel.translatesAutoresizingMaskIntoConstraints = false
        infoLabel.numberOfLines = 2
        
        // Set the view's delegate
        
        sceneView.addSubview(infoLabel)
        sceneView.addConstraint(NSLayoutConstraint(item: infoLabel, attribute: .top, relatedBy: .equal, toItem: sceneView, attribute: .top, multiplier: 1, constant: 100))
        sceneView.addConstraint(NSLayoutConstraint(item: infoLabel, attribute: .centerX, relatedBy: .equal, toItem: sceneView, attribute: .centerX, multiplier: 1, constant: 0))
    }
    
    func setupScene() {
        sceneView = ARSCNView(frame:CGRect(x: 0.0, y: 0.0, width: 500.0, height: 600.0))
        sceneView.delegate = self
        
        sceneView.delegate = self
        // Show statistics such as fps and timing information
        //        sceneView.showsStatistics = true
        sceneView.autoenablesDefaultLighting = true
        sceneView.antialiasingMode = .multisampling4X
        
        // Set the scene
        let scene = SCNScene(named: "lights.scn")!
        sceneView.scene = scene
        
        sceneView.scene.physicsWorld.contactDelegate = self
        self.view = sceneView
    }
    
    func setupLights() {
        self.sceneView.autoenablesDefaultLighting = false
        self.sceneView.automaticallyUpdatesLighting = false
        
        //        let spotLight = SCNLight()
        //        spotLight.type = .spot
        //        spotLight.spotInnerAngle = 45
        //        spotLight.spotOuterAngle = 45
        //
        //        let ambientLight = SCNLight()
        //        ambientLight.type = .ambient
        //
        //        let spotNode = SCNNode()
        //        spotNode.light = spotLight
        //        spotNode.position = SCNVector3(0, -2, 0)
        //        spotNode.eulerAngles = SCNVector3(-1 * (Float.pi / 2), 0, 0)
        //
        //        let ambientNode = SCNNode()
        //        ambientNode.light = ambientLight
        //
        //        self.sceneView.scene.rootNode.addChildNode(spotNode)
        //        self.sceneView.scene.rootNode.addChildNode(ambientNode)
        
        //        let image = UIImage(named: "Environment/spherical-old.jpg")!
        //        self.sceneView.scene.lightingEnvironment.contents = image
        
    }
    
    public func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        guard let estimate = self.sceneView.session.currentFrame?.lightEstimate else {
            return
        }
        
        let ambientLight = self.sceneView.scene.rootNode.childNode(withName: "ambient", recursively: false)?.light!
        let spotLight = self.sceneView.scene.rootNode.childNode(withName: "spot", recursively: false)?.light!
        
        ambientLight?.temperature = estimate.ambientColorTemperature
        spotLight?.temperature = estimate.ambientColorTemperature
        
        ambientLight?.intensity = estimate.ambientIntensity
        spotLight?.intensity = estimate.ambientIntensity
    }
    
    func setupGestures() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.handleTap))
        sceneView.addGestureRecognizer(tapGesture)
        
        let holdGesture = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongPress))
        holdGesture.minimumPressDuration = 0.5
        sceneView.addGestureRecognizer(holdGesture)
    }
    
    
    @objc func handleTap(recognizer: UITapGestureRecognizer) {
        let tapPoint = recognizer.location(in: sceneView)
        if let hit = sceneView.hitTest(tapPoint, types: .existingPlaneUsingExtent).first {
            insertElement(hitResult: hit)
        }
    }
    
    @objc func handleLongPress(recognizer: UITapGestureRecognizer) {
        if recognizer.state != .began {
            return
        }
        
        let tapPoint = recognizer.location(in: sceneView)
        if let hit = sceneView.hitTest(tapPoint, types: .existingPlaneUsingExtent).first {
            DispatchQueue.global().async {
                self.explode(hitResult: hit)
            }
        }
    }
    
    func addBottomPlane() {
        let bottomPlane = SCNBox(width: 1000, height: 0.5, length: 1000, chamferRadius: 0)
        
        let bottomMaterial = SCNMaterial()
        bottomMaterial.diffuse.contents = UIColor(white: 1.0, alpha: 0.0)
        bottomMaterial.locksAmbientWithDiffuse = true
        bottomPlane.materials = [bottomMaterial]
        
        let bottomNode = SCNNode(geometry: bottomPlane)
        bottomNode.position = SCNVector3(0, -10, 0)
        bottomNode.physicsBody = SCNPhysicsBody(type: .kinematic, shape: nil)
        bottomNode.physicsBody?.categoryBitMask = CollisionCategory.bottom.rawValue
        bottomNode.physicsBody?.contactTestBitMask = CollisionCategory.cube.rawValue
        
        sceneView.scene.rootNode.addChildNode(bottomNode)
    }
    
    func insertElement(hitResult: ARHitTestResult) {
        insertGeometry(hitResult: hitResult)
    }
    
    func insertGeometry(hitResult: ARHitTestResult) {
        let dimension = CGFloat(0.1)
        let cube = SCNBox(width: dimension, height: dimension, length: dimension, chamferRadius: 0.01)
        
        cube.materials = [SCNMaterial(name: "plastic")]
        let node = SCNNode(geometry: cube)
        
        node.physicsBody = SCNPhysicsBody(type: .dynamic, shape: SCNPhysicsShape(geometry: cube, options: nil))
        node.physicsBody?.mass = 2.0
        node.physicsBody?.categoryBitMask = CollisionCategory.cube.rawValue
        node.physicsBody?.contactTestBitMask = 0
        
        let insertionYOffset = Float(0.5)
        node.position = SCNVector3(
            hitResult.worldTransform.columns.3.x,
            hitResult.worldTransform.columns.3.y + insertionYOffset,
            hitResult.worldTransform.columns.3.z
        )
        
        addedNodes.append(node)
        sceneView.scene.rootNode.addChildNode(node)
    }
    
    func insertTree(hitResult: ARHitTestResult) {
        let treeNum = treeCounter % trees.count
        let selectedTree = trees[treeNum]
        
        let subScene = SCNScene(named: "Environment/\(selectedTree).scn")!
        
        subScene.rootNode.position = SCNVector3(
            hitResult.worldTransform.columns.3.x,
            hitResult.worldTransform.columns.3.y,
            hitResult.worldTransform.columns.3.z
        )
        subScene.rootNode.scale = SCNVector3(0.01, 0.01, 0.01)
        
        let finalRotation = Float.pi * Float(arc4random_uniform(2))
        let initialRotation = finalRotation - .pi / 2
        subScene.rootNode.eulerAngles.y = initialRotation
        
        let finalScale = 0.5 + (Float(arc4random_uniform(1)) / 2)
        
        let animationDuration: Double = 0.5
        let scale = SCNAction.scale(to: CGFloat(finalScale), duration: animationDuration)
        let rotate = SCNAction.rotateTo(x: 0, y: CGFloat(finalRotation), z: 0, duration:  animationDuration)
        
        let combinedAction = SCNAction.group([scale, rotate])
        combinedAction.timingMode = .easeOut
        
        subScene.rootNode.runAction(combinedAction)
        
        sceneView.scene.rootNode.addChildNode(subScene.rootNode)
        addedNodes.append(subScene.rootNode)
        treeCounter += 1
    }
    
    public func fadeNodes() {
        for node in addedNodes {
            node.runAction(SCNAction.fadeOut(duration: 0.5))
        }
    }
    
    func explode(hitResult: ARHitTestResult) {
        print("exploded")
        let explosionYOffset = Float(0.1);
        
        let position = SCNVector3(
            hitResult.worldTransform.columns.3.x,
            hitResult.worldTransform.columns.3.y - explosionYOffset,
            hitResult.worldTransform.columns.3.z
        )
        
        for cubeNode in addedNodes {
            
            var distance = SCNVector3(
                cubeNode.worldPosition.x - position.x,
                cubeNode.worldPosition.y - position.y,
                cubeNode.worldPosition.z - position.z
            )
            
            let len = sqrtf(distance.x * distance.x + distance.y * distance.y + distance.z * distance.z)
            
            let maxDistance = Float(2);
            var scale = max(0, (maxDistance - len))
            
            scale = scale * scale * 2;
            
            distance.x = distance.x / len * scale;
            distance.y = distance.y / len * scale;
            distance.z = distance.z / len * scale;
            
            cubeNode.physicsBody?.applyForce(distance, at: SCNVector3(0.05, 0.05, 0.05), asImpulse: true)
        }
    }
    
    public func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
    }
    
    public func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
    }
    
    public func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
    }
    
    public func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        let bitmask = contact.nodeA.physicsBody!.categoryBitMask | contact.nodeB.physicsBody!.categoryBitMask
        
        if bitmask == (CollisionCategory.cube.rawValue | CollisionCategory.bottom.rawValue) {
            print(String(bitmask, radix: 2))
            //            print(contact.nodeB)
            if (contact.nodeA.physicsBody?.categoryBitMask == CollisionCategory.cube.rawValue) {
                contact.nodeA.removeFromParentNode()
            } else {
                contact.nodeB.removeFromParentNode()
            }
        }
    }
    
    public func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        print("ugh")
        if let plane = planes[anchor.identifier] {
            plane.update(planeAnchor: anchor as! ARPlaneAnchor)
        }
    }
    
    public func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if !anchor.isKind(of: ARPlaneAnchor.self) {
            return
        }
        
        let plane = Plane.initWithThing(planeAnchor: anchor as! ARPlaneAnchor, hidden: false)
        planes[anchor.identifier] = plane
        
        DispatchQueue.main.async {
            self.infoLabel.text = "Surfaces have been detected! 📌\nTap on a surface to start ✨"
        }
        
        node.addChildNode(plane)
    }
    
    public func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        planes.removeValue(forKey: anchor.identifier)
    }
}
