/*:
 **Goal:** Place a 3D name tag in the world.
 
 ## Scene understanding & plane detection
 
 One of the cool things of Augmented Reality with [ARKit](glossary://arkit) is **scene understanding**. As it begins to understand your physical environment, your iPad is currently evaluating the scene over multiple frames to **detect surfaces** on which you can place 3D objects on. 🚀
 
 * callout(Look out):
 The detected surfaces will be covered with a dotted grid in the camera view. Just like the official WWDC18 artwork! 📐
 
 In this example, our goal is to place a shiny WWDC 2018 "name tag" onto this surface. Tap on the detected surfaces to create a name tag.
 
 **Try this:**
 
 Using the `setWWDCAttendee(name:_, location:_)` function, set the name and location for our would-be WWDC 2018 attendee. I took the liberty of filling it out with someone who would make a great candidate! *(cough, cough)*
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
