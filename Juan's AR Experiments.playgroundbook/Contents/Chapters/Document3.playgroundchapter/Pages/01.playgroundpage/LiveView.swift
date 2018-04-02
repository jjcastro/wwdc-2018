//
//  LiveView.swift
//
//  Copyright © 2016,2017 Apple Inc. All rights reserved.
//

import PlaygroundSupport
import UIKit

extension BlocksARViewController: PlaygroundLiveViewMessageHandler {
    public func receive(_ message: PlaygroundValue) {
        guard case let .array(values) = message else { return }
        guard case let .floatingPoint(width) = values[0] else { return }
        guard case let .floatingPoint(height) = values[1] else { return }
        guard case let .floatingPoint(depth) = values[2] else { return }

        setSizes(width: Float(width), height: Float(height), depth: Float(depth))
    }
}



let page = PlaygroundPage.current
let liveViewController = BlocksARViewController()
page.liveView = liveViewController

