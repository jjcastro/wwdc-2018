//: A UIKit based Playground to present an ARSKScene so you can play with ARKit in a playground

import UIKit
import ARKit
import PlaygroundSupport
import SpriteKit

class Plane: SCNNode {
    
    var planeGeometry: SCNPlane!
//    var anchor: ARPlaneAnchor!
    
    class func initWithThing(planeAnchor: ARPlaneAnchor) -> Plane {
        
        let plane = Plane()
        
        plane.geometry = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
        plane.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "grid.png")!
        
        let x = CGFloat(planeAnchor.center.x)
        let y = CGFloat(planeAnchor.center.y)
        let z = CGFloat(planeAnchor.center.z)
        plane.position = SCNVector3(x,y,z)
        plane.eulerAngles.x = -.pi / 2
        
        plane.setTextureScale()
        
        return plane
    }
    
    func update(planeAnchor: ARPlaneAnchor) {
        var plane = self.geometry as! SCNPlane
        
        let width = CGFloat(planeAnchor.extent.x)
        let height = CGFloat(planeAnchor.extent.z)
        plane.width = width
        plane.height = height
        
        let x = CGFloat(planeAnchor.center.x)
        let y = CGFloat(planeAnchor.center.y)
        let z = CGFloat(planeAnchor.center.z)
        self.position = SCNVector3(x, y, z)
        
        self.setTextureScale()
    }
    
    func setTextureScale() {
        var geometry = self.geometry as! SCNPlane
        let width = geometry.width
        let height = geometry.height
        
        let material = self.geometry?.firstMaterial
        material?.diffuse.contentsTransform = SCNMatrix4MakeScale(Float(width), Float(height), Float(1))
        material?.diffuse.wrapS = .repeat
        material?.diffuse.wrapT = .repeat
    }
}

//: This is our Scene, which doesn't do a heck of a lot.
public class Scene: SKScene {
    
    public override func didMove(to view: SKView) {
        // Setup your scene here
    }
    
    public override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
    
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let sceneView = self.view as? ARSKView else {
            return
        }
        
        print("huh")
        
        if let touchLocation = touches.first?.location(in: sceneView) {
            if let hit = sceneView.hitTest(touchLocation, types: .estimatedHorizontalPlane).first {
                sceneView.session.add(anchor: ARAnchor(transform: hit.worldTransform))
            }
        }
    }
}


class QIARViewController : UIViewController, ARSCNViewDelegate, ARSessionDelegate {
    var sceneView: ARSCNView!
    var infoLabel = UILabel()
    var node: SCNNode!
    
    var planes = [UUID: Plane]()
    
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
        let scene = SCNScene() //(named: "omg.scn")!
        sceneView.scene = scene

        let config = ARWorldTrackingConfiguration()
        config.planeDetection = .horizontal
        
        sceneView.session.delegate = self
        
        self.view = sceneView
        sceneView.session.run(config)
        
        let plane = SCNPlane(width: 0.2, height: 0.2)
        node = SCNNode(geometry: plane)
        sceneView.scene.rootNode.addChildNode(node)

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.handleTap))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func handleTap(gestureRecognize: UITapGestureRecognizer) {
        guard let currentFrame = sceneView.session.currentFrame else {
            return
        }
        
        let sphere = SCNSphere(radius: 0.05)
        
        let sphereNode = SCNNode(geometry: sphere)
        sphereNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: SCNPhysicsShape(geometry: sphere, options:nil))
        sceneView.scene.rootNode.addChildNode(sphereNode)
        
        var text = "\(currentFrame.camera.transform.columns.0.x) \(currentFrame.camera.transform.columns.1.x) \(currentFrame.camera.transform.columns.2.x) \(currentFrame.camera.transform.columns.3.x)"
        text += "\n\(currentFrame.camera.transform.columns.0.y) \(currentFrame.camera.transform.columns.1.y) \(currentFrame.camera.transform.columns.2.y) \(currentFrame.camera.transform.columns.3.y)"
        text += "\n\(currentFrame.camera.transform.columns.0.z) \(currentFrame.camera.transform.columns.1.z) \(currentFrame.camera.transform.columns.2.z) \(currentFrame.camera.transform.columns.3.z)"
        
        infoLabel.text = text
        
        let vector = SCNVector3(currentFrame.camera.transform.columns.3.x,
                                currentFrame.camera.transform.columns.3.y,
                                currentFrame.camera.transform.columns.3.z)
        
        var translation = matrix_identity_float4x4
        translation.columns.3.z = -0.3
        sphereNode.simdTransform = matrix_multiply(currentFrame.camera.transform, translation)
        sphereNode.runAction(SCNAction.move(by: vector, duration: TimeInterval(1)))
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

        let plane = Plane.initWithThing(planeAnchor: anchor as! ARPlaneAnchor)
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












