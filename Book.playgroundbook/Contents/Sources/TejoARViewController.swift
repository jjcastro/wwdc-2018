
import Foundation
import UIKit
import ARKit
import SceneKit

public class TejoARViewController: ARViewController {
    
    var insertedCancha = false
    var startLocation: CGPoint = CGPoint()
    
    override func setupGestures() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.handleTap))
        sceneView.addGestureRecognizer(tapGesture)
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.handlePanGesture))
        sceneView.addGestureRecognizer(panGesture)
    }
    
    override public func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
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
            print("yes")
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
    
    override func insertAtPoint(tapPoint: CGPoint) {
        if !insertedCancha {
            if let hit = sceneView.hitTest(tapPoint, types: .existingPlaneUsingExtent).first {
                insertTejo(hitResult: hit)
                insertedCancha = true
            }
        }
    }
    
    func newBola() -> SCNNode {
        let bola = SCNSphere(radius: 0.03)
        let bolaNode = SCNNode(geometry: bola)
        
        bolaNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: SCNPhysicsShape(geometry: bola, options: nil))
        bolaNode.physicsBody?.contactTestBitMask = CollisionCategory.mecha.rawValue
        bolaNode.physicsBody?.categoryBitMask = CollisionCategory.bola.rawValue
        bolaNode.physicsBody?.collisionBitMask = CollisionCategory.everything.rawValue
        
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
        
        // setUpCollisions
        let tube = sceneView.scene.rootNode.childNode(withName: "tube-top", recursively: true)!
        let particles = tube.childNode(withName: "particles", recursively: true)!
        particles.isHidden = true
        tube.physicsBody?.contactTestBitMask = CollisionCategory.bola.rawValue
        tube.physicsBody?.categoryBitMask = CollisionCategory.mecha.rawValue
        tube.physicsBody?.collisionBitMask = CollisionCategory.everything.rawValue
    }
}
