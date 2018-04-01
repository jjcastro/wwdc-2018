/*:
 **Goal:** Rotate and scale our name tag.
 
  You may have noticed that our name tag is always oriented in the same direction, regardless of where we are. This can be awkward, since in some cases we have to move the iPad to read the text. We would rather have the text always be facing us.
 
 How can we accomplish this? **With vector algebra!**.
 
 ## 3D space and vector algebra
 
 Objects are represented in the 3D world of [ARKit](glossary://arkit) in something called a **[vector](glossary://vector) space**. A vector can represent orientation, or location in space. Since all 3D coordinates can be represented in 3 numbers (`length`, `height` and `depth`), our vector will be a group of 3 elements: [`x`, `y`, `z`] respectively.
 
 - Note:
 [Vectors](glossary://vector) are used in all scientific and engineering fields, and any other field that uses computers (are there any that don't?)
 
 In this example, our goal is to take our device's orientation [vector](glossary://vector) and make it the same angle as our name tag's (but opposite, so it's facing **us**). To do this, we first have to find the angle at which our iPad is located, and apply a `rotation` to the text.
 
 ![Vector illustration](vector_img.jpg)
 
 Since the text is resting on a plane, we won't take it's height `y` into account. The way to do this, then, is take the inverse tangent (`atan2`) of the remaining two vector elements: `x` and `z`.
 
 ![Angle illustration](angle.jpg)
 
 `let angle = atan2(vector.x, vector.y)`\
 `nameTag.rotation.y = angle`
 
 **Try this:**
 
 Scaling is another algebra transformation we can apply on a vector space. Set the `scale` to somewhere between 0 and 1.0 and see how the size of the text changes accordingly.
 */
//#-hidden-code
import PlaygroundSupport
import UIKit

let page = PlaygroundPage.current
let proxy = page.liveView as? PlaygroundRemoteLiveViewProxy
func setScale(to: Double) {
    proxy?.send(PlaygroundValue.floatingPoint(to))
}

//#-end-hidden-code
// Set size
var scale = /*#-editable-code*/0.8/*#-end-editable-code*/
setScale(to: scale)

// Tap on "▶️ Run my code" to try it out!
