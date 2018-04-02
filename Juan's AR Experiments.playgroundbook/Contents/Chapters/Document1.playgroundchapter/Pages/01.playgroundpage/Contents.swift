/*:
 
 # Let's take a trip
 
 Hi, I'm Juan! 🤓
 
 I'm 20 years old and I'm an aspiring developer and designer from [Bogotá](glossary://bogota).
 
 Lately I've been getting **really** into 3D graphics, specifically [OpenGL](glossary://opengl). So today I'm excited to take you on a trip through [ARKit](glossary://arkit) and its capabilities, as seen through the lens of a low-level 3D graphics enthusiast.
 
 Along the way, we'll be writing [AR](glossary://ar) name tags ✍🏽, learning about ARKit and SceneKit, and playing some Colombian 🇨🇴 games. But first, *let's start with the basics*.
 
**Try this:**
 
 Use the `setEmoji` function to change the emoji, and tap "Run my code" to run! 👾
*/
//#-hidden-code
import PlaygroundSupport
import UIKit

let page = PlaygroundPage.current
let proxy = page.liveView as? PlaygroundRemoteLiveViewProxy

func setEmoji(array: [String]) {
    var messageArray: [PlaygroundValue] = []
    for emoji in array {
        messageArray.append(PlaygroundValue.string(emoji))
    }
    proxy?.send(PlaygroundValue.array(messageArray))
}

//#-end-hidden-code
// Set array of random emoji
setEmoji(array: /*#-editable-code*/["🚀", "👾", "🇨🇴"]/*#-end-editable-code*/)

// Tap on "▶️ Run my code" to try it out!
