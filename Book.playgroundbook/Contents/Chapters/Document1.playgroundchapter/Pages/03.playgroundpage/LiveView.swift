//
//  LiveView.swift
//
//  Copyright © 2016,2017 Apple Inc. All rights reserved.
//

import PlaygroundSupport
import UIKit

let page = PlaygroundPage.current
let liveViewController: LiveViewController = LiveViewController.makeFromStoryboard()
page.liveView = liveViewController
