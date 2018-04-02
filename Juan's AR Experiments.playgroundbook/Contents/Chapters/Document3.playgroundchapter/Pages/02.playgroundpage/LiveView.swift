//
//  LiveView.swift
//
//  Copyright © 2016,2017 Apple Inc. All rights reserved.
//

import PlaygroundSupport
import UIKit

extension TejoARViewController: PlaygroundLiveViewMessageHandler {
    public func receive(_ message: PlaygroundValue) {
        //        guard case let .array(values) = message else { return }
        //        guard case let .string(name) = values[0] else { return }
        //        guard case let .string(location) = values[1] else { return }
        //
        //        self.name = name
        //        self.location = location
        //
        //        DispatchQueue.main.async {
        //            self.fadeNodes()
        //        }
    }
}

let page = PlaygroundPage.current
let liveViewController = TejoARViewController()
page.liveView = liveViewController

