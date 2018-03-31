
import Foundation
import UIKit
import ARKit
import SceneKit

public class TextARViewController: ARViewController {
    
    public var name = "John Appleseed"
    public var location = "Cupertino, CA"
    
    override func insertElement(hitResult: ARHitTestResult) {
        insertText(hitResult: hitResult)
    }
    
    public func insertText(hitResult: ARHitTestResult) {
        let subScene = SCNScene(named: "Environment/Text.scn")!
        
        subScene.rootNode.position = SCNVector3(
            hitResult.worldTransform.columns.3.x,
            hitResult.worldTransform.columns.3.y,
            hitResult.worldTransform.columns.3.z
        )
        
        let apple = subScene.rootNode.childNode(withName: "apple", recursively: false)!
        let wwdc = subScene.rootNode.childNode(withName: "wwdc", recursively: false)!
        let juan = subScene.rootNode.childNode(withName: "juan", recursively: false)!
        let bogota = subScene.rootNode.childNode(withName: "bogota", recursively: false)!
        
        let juanText = juan.childNodes.first?.geometry as! SCNText
        juanText.string = name
        
        let bogotaText = bogota.childNodes.first?.geometry as! SCNText
        bogotaText.string = location
        
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
}
