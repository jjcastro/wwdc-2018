//: A UIKit based Playground to present an ARSKScene so you can play with ARKit in a playground

import UIKit
import ARKit
import PlaygroundSupport
import SpriteKit

extension SCNMaterial {
    convenience init(name: String) {
        self.init()
        
        self.lightingModel = .physicallyBased
        self.diffuse.contents = UIImage(named: "Materials/\(name)/\(name)-albedo.png")
        self.roughness.contents = UIImage(named: "Materials/\(name)/\(name)-roughness.png")
        self.metalness.contents = UIImage(named: "Materials/\(name)/\(name)-metal.png")
        self.normal.contents = UIImage(named: "Materials/\(name)/\(name)-normal.png")
        
        self.diffuse.wrapS = .repeat
        self.diffuse.wrapT = .repeat
        self.roughness.wrapS = .repeat
        self.roughness.wrapT = .repeat
        self.metalness.wrapS = .repeat
        self.metalness.wrapT = .repeat
        self.normal.wrapS = .repeat
        self.normal.wrapT = .repeat
    }
}

enum CollisionCategory: Int {
    case bottom = 0b001
    case cube   = 0b010
    case plane  = 0b100
}

class Plane: SCNNode {
    
    static let planeHeight = 0.01
    var planeGeometry: SCNPlane!
    
    class func initWithThing(planeAnchor: ARPlaneAnchor, hidden: Bool) -> Plane {
        
        let plane = Plane()
        
        let width = CGFloat(planeAnchor.extent.x)
        let length = CGFloat(planeAnchor.extent.z)
        
        plane.geometry = SCNBox(width: width, height: CGFloat(Plane.planeHeight), length: length, chamferRadius: 0)
        
        let material = SCNMaterial()
        let img = UIImage(named: "dotgrid.png")!
        material.diffuse.contents = img
        material.locksAmbientWithDiffuse = true

        let transparentMat = SCNMaterial()
        transparentMat.diffuse.contents = UIColor(white: 1.0, alpha: 0.0)
        transparentMat.locksAmbientWithDiffuse = true

        if hidden {
            plane.geometry?.materials = [transparentMat, transparentMat, transparentMat, transparentMat, transparentMat, transparentMat]
        } else {
            plane.geometry?.materials = [transparentMat, transparentMat, transparentMat, transparentMat, material, transparentMat]
        }
        
        let x = CGFloat(planeAnchor.center.x)
        let y = CGFloat(planeAnchor.center.y) - CGFloat(Plane.planeHeight / 2)
        let z = CGFloat(planeAnchor.center.z)
        plane.position = SCNVector3(x,y,z)
//        plane.eulerAngles.x = -.pi / 2
        
        plane.physicsBody = SCNPhysicsBody(type: .kinematic, shape: SCNPhysicsShape(geometry: plane.geometry!, options: nil))
        plane.physicsBody?.categoryBitMask = CollisionCategory.plane.rawValue
        plane.physicsBody?.contactTestBitMask = 0
        
        plane.setTextureScale()
        
        return plane
    }
    
    func update(planeAnchor: ARPlaneAnchor) {
        let plane = self.geometry as! SCNBox
        
        let width = CGFloat(planeAnchor.extent.x)
        let length = CGFloat(planeAnchor.extent.z)
        plane.width = width
        plane.length = length
        
        let x = CGFloat(planeAnchor.center.x)
        let y = CGFloat(planeAnchor.center.y) - CGFloat(Plane.planeHeight / 2)
        let z = CGFloat(planeAnchor.center.z)
        self.position = SCNVector3(x, y, z)
        
        self.physicsBody = SCNPhysicsBody(type: .kinematic, shape: SCNPhysicsShape(geometry: self.geometry!, options: nil))
        
        self.setTextureScale()
    }
    
    func setTextureScale() {
        var geometry = self.geometry as! SCNBox
        let width = geometry.width
        let height = geometry.length

        let material = self.geometry?.materials[4]
        material?.diffuse.contentsTransform = SCNMatrix4MakeScale(Float(width), Float(height), Float(1))
        material?.diffuse.wrapS = .repeat
        material?.diffuse.wrapT = .repeat
    }
}

class QIARViewController : UIViewController, ARSCNViewDelegate, SCNPhysicsContactDelegate {
    var sceneView: ARSCNView!
    var infoLabel = UILabel()
    
    var planes = [UUID: Plane]()
    var boxes = [SCNNode]()
    
    override func loadView() {
        sceneView = ARSCNView(frame:CGRect(x: 0.0, y: 0.0, width: 500.0, height: 600.0))
        sceneView.delegate = self
        
        infoLabel.text = "hola"
        infoLabel.backgroundColor = .red
        infoLabel.layer.zPosition = 2
        infoLabel.translatesAutoresizingMaskIntoConstraints = false
        infoLabel.numberOfLines = 3
        
        // Set the view's delegate
        
        sceneView.addSubview(infoLabel)
        sceneView.addConstraint(NSLayoutConstraint(item: infoLabel, attribute: .bottom, relatedBy: .equal, toItem: sceneView, attribute: .bottom, multiplier: 1, constant: 0))
        sceneView.addConstraint(NSLayoutConstraint(item: infoLabel, attribute: .leading, relatedBy: .equal, toItem: sceneView, attribute: .leading, multiplier: 1, constant: 0))
        
        sceneView.delegate = self
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        sceneView.autoenablesDefaultLighting = true
        
        // Set the scene
        let scene = SCNScene() //(named: "omg.scn")!
        sceneView.scene = scene
        
        addBottomPlane()
        sceneView.scene.physicsWorld.contactDelegate = self

        let config = ARWorldTrackingConfiguration()
        config.planeDetection = .horizontal
        
        self.view = sceneView
        sceneView.session.run(config)

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.handleTap))
        sceneView.addGestureRecognizer(tapGesture)
        
        let holdGesture = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongPress))
        holdGesture.minimumPressDuration = 0.5
        sceneView.addGestureRecognizer(holdGesture)
    }
    
    
    @objc func handleTap(recognizer: UITapGestureRecognizer) {
        let tapPoint = recognizer.location(in: sceneView)
        if let hit = sceneView.hitTest(tapPoint, types: .existingPlaneUsingExtent).first {
            insertGeometry(hitResult: hit)
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
    
    func insertGeometry(hitResult: ARHitTestResult) {
        let dimension = CGFloat(0.1)
        let cube = SCNBox(width: dimension, height: dimension, length: dimension, chamferRadius: 0)
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

        boxes.append(node)
        sceneView.scene.rootNode.addChildNode(node)
    }
    
    func explode(hitResult: ARHitTestResult) {
        print("exploded")
        let explosionYOffset = Float(0.1);
        
        let position = SCNVector3(
            hitResult.worldTransform.columns.3.x,
            hitResult.worldTransform.columns.3.y - explosionYOffset,
            hitResult.worldTransform.columns.3.z
        )
        
        for cubeNode in boxes {
            
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
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
    }
    
//    func session(_ session: ARSession, didUpdate frame: ARFrame) {
//        if let hit = sceneView.hitTest(sceneView.center, types: .featurePoint).first {
////            sceneView.session.add(anchor: ARAnchor(transform: hit.worldTransform))
//
////            sceneView.scene.rootNode.addChildNode(planeNode)
//            node.simdTransform = hit.worldTransform
//        }
//        print("ugh")
//    }
    
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
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
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        print("ugh")
        if let plane = planes[anchor.identifier] {
            plane.update(planeAnchor: anchor as! ARPlaneAnchor)
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if !anchor.isKind(of: ARPlaneAnchor.self) {
            return
        }

        let plane = Plane.initWithThing(planeAnchor: anchor as! ARPlaneAnchor, hidden: false)
        planes[anchor.identifier] = plane
        //sceneView.scene.rootNode
        node.addChildNode(plane)

    }
    
    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        planes.removeValue(forKey: anchor.identifier)
    }
}

//: We set our custom code above as our live view so that we can see all our hard work
PlaygroundPage.current.liveView = QIARViewController()
PlaygroundPage.current.needsIndefiniteExecution = true












