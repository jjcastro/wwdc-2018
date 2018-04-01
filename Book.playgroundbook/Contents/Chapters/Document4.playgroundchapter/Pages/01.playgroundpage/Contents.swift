/*:
 **Goal:**Make a house out of building blocks!
 
 ## Hit testing
 
 Another great utility [ARKit](glossary://arkit) provides is hit testing. Hit testing assists in taking our screen’s 2D coordinates turning them into real world 3D coordinates, by intersecting features in the scene. 🗺
 
 This allows us to place objects directly onto the scene by way of user interaction (i.e. tapping on the screen) because each screen location can correspond to a real world location.
 
 - Note:
 There’s many ways in which we can do hit testing. In this example, were using `.existingPlaneUsingExtent`, meaning we’re intersecting the detected surfaces on the scene.
 
 — — —
 
 In this chapter, we’ll be playing a building blocks game in AR, taking advantage of the wonders of hit testing. The blocks are even made from Apple’s *signature white glossy plastic*!
 
 **Try this:**
 
 Change the width and height of your block using
 */
//#-hidden-code
import PlaygroundSupport
import UIKit

let page = PlaygroundPage.current
let proxy = page.liveView as? PlaygroundRemoteLiveViewProxy

func setWWDCAttendee(name: String, location: String) {
    let array = [PlaygroundValue.string(name), PlaygroundValue.string(location)]
    proxy?.send(PlaygroundValue.array(array))
}

//#-end-hidden-code
// Set attendee name tag
setWWDCAttendee(
    name: /*#-editable-code*/"Juan Castro Varón"/*#-end-editable-code*/,
    location: /*#-editable-code*/"Bogotá, Co"/*#-end-editable-code*/
)

// Tap on "▶️ Run my code" to try it out!
