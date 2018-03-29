//: Playground - noun: a place where people can play

import UIKit
import ARKit
import PlaygroundSupport
//
//  Scene.swift
//  TestWithSpriteKit
//
//  Created by Juan José Castro on 3/24/18.
//  Copyright © 2018 Juan José Castro. All rights reserved.
//

import SpriteKit

class Scene: SKScene {
    
    override func didMove(to view: SKView) {
        // Setup your scene here
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("yes")
        guard let sceneView = self.view as? ARSKView else {
            return
        }
        
        // Create anchor using the camera's current position
        //        if let currentFrame = sceneView.session.currentFrame {
        //
        //            // Create a transform with a translation of 0.2 meters in front of the camera
        //            var translation = matrix_identity_float4x4
        //            translation.columns.3.z = -0.2
        //            let transform = simd_mul(currentFrame.camera.transform, translation)
        //
        //            // Add a new anchor to the session
        //            let anchor = ARAnchor(transform: transform)
        //            sceneView.session.add(anchor: anchor)
        //        }
        if let touchLocation = touches.first?.location(in: sceneView) {
            if let hit = sceneView.hitTest(touchLocation, types: .featurePoint).first {
                sceneView.session.add(anchor: ARAnchor(transform: hit.worldTransform))
            }
        }
    }
}

class ViewController: UIViewController, ARSKViewDelegate {
    
    var sceneView: ARSKView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
//
//        view.addSubview(sceneView)
        sceneView.translatesAutoresizingMaskIntoConstraints = false

////        sceneView.frame = view.frame
//
//        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and node count
        sceneView.showsFPS = true
        sceneView.showsNodeCount = true
        
        // Load the SKScene from 'Scene.sks'
        if let scene = Scene(fileNamed: "Scene") {
            sceneView.presentScene(scene)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
    // MARK: - ARSKViewDelegate
    
    func view(_ view: ARSKView, nodeFor anchor: ARAnchor) -> SKNode? {
        // Create and configure a node for the anchor added to the view's session.
        let labelNode = SKLabelNode(text: "👾")
        labelNode.horizontalAlignmentMode = .center
        labelNode.verticalAlignmentMode = .center
        return labelNode;
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
}


let storyboard = UIStoryboard(name: "Main", bundle: nil)
let vc = storyboard.instantiateViewController(withIdentifier: "viewController")
//self.navigationController!.pushViewController(vc, animated: true)

PlaygroundPage.current.liveView = vc
PlaygroundPage.current.needsIndefiniteExecution = true

