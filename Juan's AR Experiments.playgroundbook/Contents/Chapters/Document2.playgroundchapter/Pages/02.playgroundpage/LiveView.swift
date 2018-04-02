//
//  LiveView.swift
//
//  Copyright © 2016,2017 Apple Inc. All rights reserved.
//

import PlaygroundSupport
import UIKit
import ARKit

extension TextARViewController: PlaygroundLiveViewMessageHandler {
    public func receive(_ message: PlaygroundValue) {
        guard case let .floatingPoint(value) = message else { return }
        
        DispatchQueue.main.async {
            self.scaleNodes(to: Float(value))
        }
    }
}

let page = PlaygroundPage.current
let liveViewController = TextARViewController()
liveViewController.faceCamera = true

liveViewController.name = "Juan Castro Varón"
liveViewController.location = "Bogotá, Co"

page.liveView = liveViewController


