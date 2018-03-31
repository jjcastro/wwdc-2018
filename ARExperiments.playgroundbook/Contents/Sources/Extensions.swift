import UIKit

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
