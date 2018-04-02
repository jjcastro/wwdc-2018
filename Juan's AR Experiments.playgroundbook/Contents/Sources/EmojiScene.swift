
import UIKit
import ARKit
import PlaygroundSupport
import SpriteKit

public class EmojiScene: SKScene {
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
        
        if let touchLocation = touches.first?.location(in: sceneView) {
            if let hit = sceneView.hitTest(touchLocation, types: .featurePoint).first {
                sceneView.session.add(anchor: ARAnchor(transform: hit.worldTransform))
            }
        }
    }

}
