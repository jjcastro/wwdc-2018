
import Foundation
import UIKit
import ARKit
import SceneKit

public class TejoARViewController: ARViewController {
    
    var insertedCancha = false
    var startLocation: CGPoint = CGPoint()
    var counter: Int = 0
    
    override func setupGestures() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.handleTapTejo))
        sceneView.addGestureRecognizer(tapGesture)
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.handlePanGesture))
        sceneView.addGestureRecognizer(panGesture)
    }
    
    override public func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        let bitmask = contact.nodeA.physicsBody!.categoryBitMask | contact.nodeB.physicsBody!.categoryBitMask

        if bitmask == (CollisionCategory.bola.rawValue | CollisionCategory.mecha.rawValue) {
            self.counter = self.counter + 1
            success()
        }
        
        if contact.nodeA.physicsBody!.categoryBitMask == CollisionCategory.bola.rawValue {
            fade(node: contact.nodeA)
        } else {
            fade(node: contact.nodeB)
        }
    }
    
    func success() {
        let particles = sceneView.scene.rootNode.childNode(withName: "particles", recursively: true)!
        particles.isHidden = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            particles.isHidden = true
        }
        DispatchQueue.main.async {
            self.infoLabel.text = "Score: \(self.counter)"
        }
    }
    
    func fade(node: SCNNode) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            node.runAction(SCNAction.fadeOut(duration: 0.5))
        }
    }
    
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
    
    @objc func handleTapTejo(recognizer: UITapGestureRecognizer) {
        let tapPoint = recognizer.location(in: sceneView)
        
        if !insertedCancha {
            if let hit = sceneView.hitTest(tapPoint, types: .existingPlaneUsingExtent).first {
                insertTejo(hitResult: hit)
                insertedCancha = true
                DispatchQueue.main.async {
                    self.infoLabel.text = "Your bocín has been placed, swipe up to throw a Tejo!"
                }
            }
        }
    }
    
    func newBola() -> SCNNode {
        let bola = SCNSphere(radius: 0.03)
        let bolaNode = SCNNode(geometry: bola)
        
        bolaNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: SCNPhysicsShape(geometry: bola, options: nil))
        bolaNode.physicsBody?.contactTestBitMask = CollisionCategory.everythingButBola.rawValue
        bolaNode.physicsBody?.categoryBitMask = CollisionCategory.bola.rawValue
        
        return bolaNode
    }
    
    func throwBall(distance: Float) {
        guard let currentFrame = sceneView.session.currentFrame else {
            return
        }
        
        let bolaNode = newBola()
        sceneView.scene.rootNode.addChildNode(bolaNode)
        
        var translation = matrix_identity_float4x4
        translation.columns.3.z = -0.4
        bolaNode.simdTransform = matrix_multiply(currentFrame.camera.transform, translation)
        
        let mat = SCNMatrix4(currentFrame.camera.transform)
        
        let force = SCNVector3(
            -1 * mat.m31 * (distance/100.0),
            mat.m31 + (distance/150.0),
            -1 * mat.m33 * (distance/100.0))
        
        bolaNode.physicsBody?.applyForce(force, asImpulse: true)
    }
    
    public func insertTejo(hitResult: ARHitTestResult) {
        guard let currentFrame = sceneView.session.currentFrame else {
            return
        }
        
        self.fadeNodes()
        let subScene = SCNScene(named: "Environment/Tejo.scn")!
        
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
