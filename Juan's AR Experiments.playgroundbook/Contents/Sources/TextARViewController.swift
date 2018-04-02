
import Foundation
import UIKit
import ARKit
import SceneKit

public class TextARViewController: ARViewController {
    
    public var name = "John Appleseed"
    public var location = "Cupertino, CA"
    
    public var scale: Float = 1.0
    
    public var faceCamera = false
    
    override func insertElement(hitResult: ARHitTestResult) {
        insertText(hitResult: hitResult, faceCamera: faceCamera)
    }
    
    public func insertText(hitResult: ARHitTestResult, faceCamera: Bool) {
        self.fadeNodes()
        let subScene = SCNScene(named: "Environment/Text.scn")!
        
        guard let currentFrame = sceneView.session.currentFrame else {
            return
        }
        
        subScene.rootNode.position = SCNVector3(
            hitResult.worldTransform.columns.3.x,
            hitResult.worldTransform.columns.3.y,
            hitResult.worldTransform.columns.3.z
        )
        
        if faceCamera {
            let mat = SCNMatrix4(currentFrame.camera.transform)
            let dot = mat.m33
            let det = mat.m31
            
            let angle = atan2(det, dot)
            subScene.rootNode.eulerAngles.y = angle
        }
        
        subScene.rootNode.scale = SCNVector3(scale, scale, scale)
        
        let apple = subScene.rootNode.childNode(withName: "apple", recursively: false)!
        let wwdc = subScene.rootNode.childNode(withName: "wwdc", recursively: false)!
        let juan = subScene.rootNode.childNode(withName: "juan", recursively: false)!
        let bogota = subScene.rootNode.childNode(withName: "bogota", recursively: false)!
        
        let juanText = juan.childNodes.first?.geometry as! SCNText
        juanText.string = name
        
        let bogotaText = bogota.childNodes.first?.geometry as! SCNText
        bogotaText.string = location
        
        let moveAction = SCNAction.move(by: SCNVector3(0.05, 0, 0), duration: 0.5)
        let opacityAction = SCNAction.fadeIn(duration: 0.5)
        let idle = SCNAction.wait(duration: 0.25)
        
        let combined = SCNAction.group([moveAction, opacityAction])
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
    
    public func scaleNodes(to: Float) {
        scale = to
        for node in addedNodes {
            node.runAction(SCNAction.scale(to: CGFloat(to), duration: 0.5))
        }
    }
}
