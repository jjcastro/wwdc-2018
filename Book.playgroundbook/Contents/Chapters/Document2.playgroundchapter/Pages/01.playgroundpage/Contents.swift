//#-hidden-code
//
//  Contents.swift
//
//  Copyright © 2017 Apple Inc. All rights reserved.
//
//#-end-hidden-code
/*:
 
 # Let's take a trip
 
 
 Hi, I'm Juan! 🤓
 
 I'm 20 years old and I'm an aspiring developer and designer from [Bogotá](glossary://bogota).
 
 Lately I've been getting **really** into 3D graphics, specifically [WebGL](glossary://webgl). Today I'm excited to take you on a trip through [ARKit](glossary://arkit) and its capabilities, as seen through the lens of a low-level 3D graphics enthusiast.
 
 Along the way, we'll be writing in 3D, playing some Colombian games, and even creating our very own [jardincito](glossary://jardincito). But first, *let's start with the basics*.
 
 - - -
 
 ## Scene understanding & plane detection
 
 One of the main capabilities of Augmented Reality with [ARKit](glossary://arkit) is **scene understanding**. As it begins to understand your physical environment, your iPad is currently evaluating the scene over multiple frames to **detect surfaces** on which you can place 3D objects on (plane detection).
 
  * callout(Look out):
 The detected surfaces will be displayed covered with a dotted grid. Just like the official WWDC18 artwork!
 
 *In this example*, our goal is to display a nice WWDC 2018 "name tag" onto this surface. Tap on the detected surfaces to create a 3D name tag.
 
 Using the `setWWDCAttendee(name:_, location:_)` function, you can set the name and location for our would-be WWDC 2018 attendee. I took the liberty of filling it out with someone who would make a great candidate!
*/
//#-hidden-code
import PlaygroundSupport
import UIKit

let page = PlaygroundPage.current
page.needsIndefiniteExecution = true
let proxy = page.liveView as? PlaygroundRemoteLiveViewProxy

func setWWDCAttendee(name: String, location: String) {
    let array = [PlaygroundValue.string(name), PlaygroundValue.string(location)]
    proxy?.send(PlaygroundValue.array(array))
}

//#-code-completion(everything, hide)
//#-code-completion(identifier, show, enableCameraVision())
//#-end-hidden-code

//#-editable-code

setWWDCAttendee(name: "Juan Castro Varón", location: "Bogotá, CO")

//#-end-editable-code
