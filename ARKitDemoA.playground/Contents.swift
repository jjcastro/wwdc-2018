//: A UIKit based Playground to present an ARSKScene so you can play with ARKit in a playground

import UIKit
import ARKit
import PlaygroundSupport
import SpriteKit

extension SCNGeometry {
    class func lineFrom(vector vector1: SCNVector3, toVector vector2: SCNVector3) -> SCNGeometry {
        let indices: [Int32] = [0, 1]
        
        let source = SCNGeometrySource(vertices: [vector1, vector2])
        let element = SCNGeometryElement(indices: indices, primitiveType: .line)
        
        return SCNGeometry(sources: [source], elements: [element])
        
    }
}

extension SCNVector3 {
    func length() -> Float {
        return sqrtf(x*x + y*y + z*z)
    }
}

class PaddingLabel: UILabel {
    
    var topInset: CGFloat = 10.0
    var bottomInset: CGFloat = 10.0
    var leftInset: CGFloat = 15.0
    var rightInset: CGFloat = 15.0
    
    override func drawText(in rect: CGRect) {
        let insets = UIEdgeInsets.init(top: topInset, left: leftInset, bottom: bottomInset, right: rightInset)
        super.drawText(in: UIEdgeInsetsInsetRect(rect, insets))
    }
    
    override var intrinsicContentSize: CGSize {
        var intrinsicSuperViewContentSize = super.intrinsicContentSize
        intrinsicSuperViewContentSize.height += topInset + bottomInset
        intrinsicSuperViewContentSize.width += leftInset + rightInset
        return intrinsicSuperViewContentSize
    }
}

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
    case bottom = 0b00001
    case cube   = 0b00010
    case plane  = 0b00100
    
    // Tejo
    case bola =  0b01000
    case mecha = 0b10000
    
    case everything = 0b11110
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
        let img = UIImage(named: "dots-icon.png")!
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
    var infoLabel = PaddingLabel()
    
    var planes = [UUID: Plane]()
    var addedNodes = [SCNNode]()
    
    let trees = ["Fir_Tree", "Lil_Tree", "Palm_Tree"]
    var treeCounter = 0
    
    override func loadView() {
        
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
        infoLabel.text = "Move around to detect the scene 🔍"
        
        infoLabel.backgroundColor = UIColor(white: 1.0, alpha: 0.5)
        infoLabel.textAlignment = .center
        infoLabel.layer.masksToBounds = true
        infoLabel.layer.zPosition = 2
        infoLabel.layer.cornerRadius = 5.0
        infoLabel.translatesAutoresizingMaskIntoConstraints = false
        infoLabel.numberOfLines = 2
        
        // Set the view's delegate
        
        sceneView.addSubview(infoLabel)
        sceneView.addConstraint(NSLayoutConstraint(item: infoLabel, attribute: .bottom, relatedBy: .equal, toItem: sceneView, attribute: .bottom, multiplier: 1, constant: -100))
        sceneView.addConstraint(NSLayoutConstraint(item: infoLabel, attribute: .centerX, relatedBy: .equal, toItem: sceneView, attribute: .centerX, multiplier: 1, constant: 0))
    }
    
    func setupScene() {
        sceneView = ARSCNView(frame:CGRect(x: 0.0, y: 0.0, width: 500.0, height: 600.0))
        sceneView.delegate = self
        
        sceneView.delegate = self
        sceneView.antialiasingMode = .multisampling4X
        
        // Set the scene
        let scene = SCNScene(named: "lights.scn")!
        sceneView.scene = scene
        
        sceneView.scene.physicsWorld.contactDelegate = self
        self.view = sceneView
    }
    
    func setupLights() {
//        self.sceneView.autoenablesDefaultLighting = false
//        self.sceneView.automaticallyUpdatesLighting = false
        
        let image = UIImage(named: "Environment/spherical-old.jpg")!
        self.sceneView.scene.lightingEnvironment.contents = image
        
    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        guard let estimate = self.sceneView.session.currentFrame?.lightEstimate else {
            return
        }
        
//        let intensity = estimate.ambientIntensity / 1000.0
//        self.sceneView.scene.lightingEnvironment.intensity = intensity
    }
    
    func setupGestures() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.handleTap))
        sceneView.addGestureRecognizer(tapGesture)
        
        let holdGesture = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongPress))
        holdGesture.minimumPressDuration = 0.5
        sceneView.addGestureRecognizer(holdGesture)
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.handlePanGesture))
        sceneView.addGestureRecognizer(panGesture)
    }
    
    
    @objc func handleTap(recognizer: UITapGestureRecognizer) {
        let tapPoint = recognizer.location(in: sceneView)
        insertAtPoint(tapPoint: tapPoint)
    }
    
    var startLocation: CGPoint = CGPoint()
    
    @objc func handlePanGesture(recognizer: UIPanGestureRecognizer) {
        if recognizer.state == .began {
            startLocation = recognizer.location(in: self.view)
        }
        else if recognizer.state == .ended {
            let stopLocation = recognizer.location(in: self.view)
            let dx = stopLocation.x - startLocation.x
            let dy = stopLocation.y - startLocation.y
            let distance = sqrt(dx*dx + dy*dy)
            
            if dy < 1 && distance > 80 {
                throwBall(distance: Float(distance))
            }
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
    
    func fadeNodes() {
        for node in addedNodes {
            node.runAction(SCNAction.fadeOut(duration: 0.5))
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
        bottomNode.physicsBody?.contactTestBitMask = CollisionCategory.everything.rawValue
        
        sceneView.scene.rootNode.addChildNode(bottomNode)
    }
    
    func insertGeometry(hitResult: ARHitTestResult) {
        let dimension = CGFloat(0.1)
        let cube = SCNBox(width: dimension, height: dimension, length: dimension, chamferRadius: 0.01)
        
        cube.materials = [SCNMaterial(name: "plastic")]
        let node = SCNNode(geometry: cube)
        
        node.physicsBody = SCNPhysicsBody(type: .dynamic, shape: SCNPhysicsShape(geometry: cube, options: nil))
        node.physicsBody?.mass = 2.0
        node.physicsBody?.categoryBitMask = CollisionCategory.bola.rawValue
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
    
    func insertText(hitResult: ARHitTestResult) {
        guard let currentFrame = sceneView.session.currentFrame else {
            return
        }
        
        let subScene = SCNScene(named: "Environment/Text.scn")!
        
        subScene.rootNode.position = SCNVector3(
            hitResult.worldTransform.columns.3.x,
            hitResult.worldTransform.columns.3.y,
            hitResult.worldTransform.columns.3.z
        )
        
        let mat = SCNMatrix4(currentFrame.camera.transform)
        let dir = SCNVector3(-1 * mat.m31, 0, -1 * mat.m33)
        
        let nodenew = SCNNode(geometry: SCNGeometry.lineFrom(vector: SCNVector3(0,0,0), toVector: dir))
        sceneView.scene.rootNode.addChildNode(nodenew)
        
        let dot = mat.m33
        let det = mat.m31
        
        let angle = atan2(det, dot)
        print(angle)
        subScene.rootNode.eulerAngles.y = angle
        
        
        
        let apple = subScene.rootNode.childNode(withName: "apple", recursively: false)!
        let wwdc = subScene.rootNode.childNode(withName: "wwdc", recursively: false)!
        let juan = subScene.rootNode.childNode(withName: "juan", recursively: false)!
        let bogota = subScene.rootNode.childNode(withName: "bogota", recursively: false)!
        
        
        
        var moveAction = SCNAction.move(by: SCNVector3(0.05, 0, 0), duration: 0.5)
        var opacityAction = SCNAction.fadeIn(duration: 0.5)
        var idle = SCNAction.wait(duration: 0.25)
        
        var combined = SCNAction.group([moveAction, opacityAction])
        combined.timingMode = .easeOut
        
        sceneView.scene.rootNode.addChildNode(subScene.rootNode)
        addedNodes.append(subScene.rootNode)
        
        apple.opacity = 0.0
        wwdc.opacity = 0.0
        juan.opacity = 0.0
        bogota.opacity = 0.0
        
        apple.runAction(combined)
        wwdc.runAction(SCNAction.sequence([idle, combined]))
        juan.runAction(SCNAction.sequence([idle, idle, combined]))
        bogota.runAction(SCNAction.sequence([idle, idle, idle, combined]))
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
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
    }
    
    public func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        print("called")
        let bitmask = contact.nodeA.physicsBody!.categoryBitMask | contact.nodeB.physicsBody!.categoryBitMask
        
        if bitmask == (CollisionCategory.bola.rawValue | CollisionCategory.bottom.rawValue) {
            if (contact.nodeA.physicsBody?.categoryBitMask == CollisionCategory.bola.rawValue) {
                contact.nodeA.removeFromParentNode()
            } else {
                contact.nodeB.removeFromParentNode()
            }
        }
        
        if bitmask == (CollisionCategory.bola.rawValue | CollisionCategory.mecha.rawValue) {
            infoLabel.text = "omg"
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
        
        DispatchQueue.main.async {
            self.infoLabel.text = "Planes have been detected! 📌\nTap on one to start ✨"
        }
        
        node.addChildNode(plane)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        planes.removeValue(forKey: anchor.identifier)
    }
    
    var insertedCancha = false
    
    func insertAtPoint(tapPoint: CGPoint) {
        if let hit = sceneView.hitTest(tapPoint, types: .existingPlaneUsingExtent).first {
            insertTejo(hitResult: hit)
            insertedCancha = true
        }
    }
    
    func newBola() -> SCNNode {
        let bola = SCNSphere(radius: 0.03)
        let bolaNode = SCNNode(geometry: bola)
        
        bolaNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: SCNPhysicsShape(geometry: bola, options: nil))
        bolaNode.physicsBody?.contactTestBitMask = CollisionCategory.mecha.rawValue
        bolaNode.physicsBody?.categoryBitMask = CollisionCategory.bola.rawValue
//        bolaNode.physicsBody?.collisionBitMask = CollisionCategory.everything.rawValue
        
        return bolaNode
    }
    
    func throwBall(distance: Float) {
        guard let currentFrame = sceneView.session.currentFrame else {
            return
        }
        
        let bolaNode = newBola()
        sceneView.scene.rootNode.addChildNode(bolaNode)
        
        var translation = matrix_identity_float4x4
        translation.columns.3.z = -0.5
        bolaNode.simdTransform = matrix_multiply(currentFrame.camera.transform, translation)
        
        let mat = SCNMatrix4(currentFrame.camera.transform)
        
        let force = SCNVector3(
            -1 * mat.m31 * (distance/100.0),
            mat.m31 + (distance/150.0),
            -1 * mat.m33 * (distance/100.0))
        
        bolaNode.physicsBody?.applyForce(force, asImpulse: true)
    }
    
    public func insertTejo(hitResult: ARHitTestResult) {
        self.fadeNodes()
        
        let subScene = SCNScene(named: "Environment/tejo.scn")!
        
        guard let currentFrame = sceneView.session.currentFrame else {
            return
        }
        
        subScene.rootNode.position = SCNVector3(
            hitResult.worldTransform.columns.3.x,
            hitResult.worldTransform.columns.3.y,
            hitResult.worldTransform.columns.3.z
        )
        
        let mat = SCNMatrix4(currentFrame.camera.transform)
        let dot = mat.m33
        let det = mat.m31
        let angle = atan2(det, dot)
        
        subScene.rootNode.scale = SCNVector3(0.01, 0.01, 0.01)
        
        // Animate the trees
        
        let finalRotation = angle
        let initialRotation = finalRotation - .pi / 2
        subScene.rootNode.eulerAngles.y = initialRotation
        
        let animationDuration: Double = 0.5
        let scale = SCNAction.scale(to: CGFloat(1.0), duration: animationDuration)
        let rotate = SCNAction.rotateTo(x: 0, y: CGFloat(finalRotation), z: 0, duration:  animationDuration)
        
        subScene.rootNode.runAction(SCNAction.group([scale,rotate]))
        sceneView.scene.rootNode.addChildNode(subScene.rootNode)
        
        let tube = sceneView.scene.rootNode.childNode(withName: "tube-top", recursively: true)!
        let particles = tube.childNode(withName: "particles", recursively: true)!
        
        particles.isHidden = true
        
        let body = SCNPhysicsBody(type: .kinematic, shape: nil)
        body.contactTestBitMask = CollisionCategory.bola.rawValue
        body.categoryBitMask = CollisionCategory.mecha.rawValue
        
        tube.physicsBody = body
    }
}

//: We set our custom code above as our live view so that we can see all our hard work
PlaygroundPage.current.liveView = QIARViewController()
PlaygroundPage.current.needsIndefiniteExecution = true












