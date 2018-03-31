//
//  LiveView.swift
//
//  Copyright © 2016,2017 Apple Inc. All rights reserved.
//

import PlaygroundSupport
import UIKit

extension EmojiARViewController: PlaygroundLiveViewMessageHandler {
    public func receive(_ message: PlaygroundValue) {
        guard case let .array(values) = message else { return }
        guard case let .string(name) = values[0] else { return }
        guard case let .string(location) = values[1] else { return }
        
        var array: [String] = []
        for val in values {
            guard case let .string(emoji) = val else { return }
            array.append(emoji)
        }
        
        DispatchQueue.main.async {
            self.emojiList = array
        }
    }
}

let page = PlaygroundPage.current
let liveViewController = EmojiARViewController()
page.liveView = liveViewController
