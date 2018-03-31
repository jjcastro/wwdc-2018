
import UIKit
import ARKit
import PlaygroundSupport
import SpriteKit

public class EmojiARViewController: UIViewController, ARSKViewDelegate {
    public var sceneView: ARSKView!
    public var infoLabel = PaddingLabel()
    public var emojiList = ["🚀", "👾", "🇨🇴", "🐥"]
    
    open override func loadView() {
        sceneView = ARSKView(frame:CGRect(x: 0.0, y: 0.0, width: 500.0, height: 600.0))
        // Set the view's delegate
        sceneView.delegate = self
        // Show statistics such as fps and node count
        sceneView.showsFPS = true
        sceneView.showsNodeCount = true
        
        setupInfoLabel()
        
        if let scene = EmojiScene(fileNamed: "Scene") {
            sceneView.presentScene(scene)
        }
        
        let config = ARWorldTrackingConfiguration()
        
        self.view = sceneView
        sceneView.session.run(config)
    }
    
    func setupInfoLabel() {
        infoLabel.text = "Move around to evaluate the scene 🔍\nTap to place emoji! 🐱"
        
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
    
    public func view(_ view: ARSKView, nodeFor anchor: ARAnchor) -> SKNode? {
        // Create and configure a node for the anchor added to the view's session.
        let randomIndex = Int(arc4random_uniform(UInt32(emojiList.count)))

        let labelNode = SKLabelNode(text: emojiList[randomIndex])
        labelNode.horizontalAlignmentMode = .center
        labelNode.verticalAlignmentMode = .center
        
        return labelNode;
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
}










