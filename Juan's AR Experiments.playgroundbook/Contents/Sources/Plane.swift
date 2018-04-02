import UIKit
import ARKit

class Plane: SCNNode {
    
    static let planeHeight = 0.1
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
        plane.physicsBody?.collisionBitMask = 0xFFFFFFFF
        
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
        let geometry = self.geometry as! SCNBox
        let width = geometry.width
        let height = geometry.length
        
        let material = self.geometry?.materials[4]
        material?.diffuse.contentsTransform = SCNMatrix4MakeScale(Float(width), Float(height), Float(1))
        material?.diffuse.wrapS = .repeat
        material?.diffuse.wrapT = .repeat
    }
}
