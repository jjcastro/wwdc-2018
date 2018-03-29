import UIKit
import PlaygroundSupport

// EXTENSIONS
// ------------------------

public extension UIImage {
    public func breakIntoParts(val: Int) -> [UIImage] {
        var array = [UIImage]()
        if let cgImage = cgImage {
            for x in 0...val-1 {
                for y in 0...val-1 {
                    let iOrigin = CGPoint(x: CGFloat(x * Int(size.width) / val), y: CGFloat(y * Int(size.height) / val))
                    let iSize = CGSize(width: Int(size.width) / val, height: Int(size.height) / val)
                    let imageN = cgImage.cropping(to: CGRect(origin: iOrigin, size: iSize))
                    array.append(UIImage(cgImage: imageN!))
                }
            }
        }
        return array
    }
    
    public func getCenterSquare() -> UIImage {
        var val = self
        if let cgImage = cgImage {
            if size.width > size.height {
                let side = size.height
                let offset = Int(size.width - side) / 2
                let imageN = cgImage.cropping(to: CGRect(origin: CGPoint(x: CGFloat(offset), y: 0), size: CGSize(width: side, height: side)))
                val = UIImage(cgImage: imageN!)
            } else if size.height > size.width {
                let side = size.width
                let offset = Int(size.height - side) / 2
                let imageN = cgImage.cropping(to: CGRect(origin: CGPoint(x: 0, y: CGFloat(offset)), size: CGSize(width: side, height: side)))
                val = UIImage(cgImage: imageN!)
            }
        }
        return val
    }
    
    public convenience init?(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        guard let cgImage = image?.cgImage else { return nil }
        self.init(cgImage: cgImage)
    }
}

// MAIN VIEW CONTROLLER
// ------------------------

class CollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    // Board factor (n=3 means a 3x3 board)
    var n: Int
    // Width and height of the board (in pixels)
    var size: Int
    // Board images
    var images: [UIImage]
    // Position for the "hole" on the board
    var position: Int
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(n: Int, size: Int, image: UIImage) {
        self.n = n
        self.size = size
        self.images = []
        
        let cropped =  image.getCenterSquare()
        var preshuffle = cropped.breakIntoParts(val: n)
        
        for _ in 0..<preshuffle.count {
            let rand = Int(arc4random_uniform(UInt32(preshuffle.count)))
            self.images.append(preshuffle[rand])
            preshuffle.remove(at: rand)
        }
        
        self.position = Int(arc4random_uniform(UInt32(self.images.count)))
        self.images[self.position] = UIImage(color: .black, size: self.images[0].size)!
        
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        super.init(collectionViewLayout: layout)
    }
    
    @objc func handleSwipe(gesture: UIGestureRecognizer) {
        var newPosition = self.position
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            switch swipeGesture.direction {
            case UISwipeGestureRecognizerDirection.right:
                if newPosition % n != 0 {
                    newPosition -= 1
                }
            case UISwipeGestureRecognizerDirection.down:
                if (newPosition - n) >= 0 {
                    newPosition -= n
                }
            case UISwipeGestureRecognizerDirection.left:
                if (newPosition + 1) % n != 0 {
                    newPosition += 1
                }
            case UISwipeGestureRecognizerDirection.up:
                if (newPosition + n) < images.count {
                    newPosition += n
                }
            default:
                break
            }
            self.collectionView?.performBatchUpdates({() -> Void in
                self.collectionView?.moveItem(at: IndexPath(item: newPosition, section: 0), to: IndexPath(item: self.position, section: 0))
                self.collectionView?.moveItem(at: IndexPath(item: self.position, section: 0), to: IndexPath(item: newPosition, section: 0))
            }, completion: nil)
            self.position = newPosition
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView?.backgroundColor = .black
        self.collectionView?.register(UICollectionViewCell.self,  forCellWithReuseIdentifier: "PlayCell")
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(self.handleSwipe))
        swipeRight.direction = .right
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(self.handleSwipe))
        swipeLeft.direction = .left
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(self.handleSwipe))
        swipeUp.direction = .up
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(self.handleSwipe))
        swipeDown.direction = .down
        
        self.view.addGestureRecognizer(swipeRight)
        self.view.addGestureRecognizer(swipeLeft)
        self.view.addGestureRecognizer(swipeUp)
        self.view.addGestureRecognizer(swipeDown)
    }

    override func viewDidLayoutSubviews() {
        let frame = CGRect(x: 10, y: 10, width: size, height: size)
        collectionView?.frame = frame
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let side: CGFloat =  CGFloat(size / n)
        return CGSize(width: side, height: side)
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PlayCell", for: indexPath)
        
        let image = self.images[indexPath.item]
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: cell.frame.width, height: cell.frame.height))
        imageView.contentMode = .scaleAspectFill
        imageView.image = image
        
        cell.layer.zPosition = (indexPath.item == position ? 0 : 1)
        cell.contentView.addSubview(imageView)
        
        return cell
    }
}

// MAIN
// ------------------------

let thing = CollectionViewController(n: 5, size: 300, image: UIImage(named: "london.jpg")!)

thing.collectionView?.layer.borderWidth = 2
thing.collectionView?.layer.borderColor = UIColor.white.cgColor

PlaygroundPage.current.liveView = thing
PlaygroundPage.current.needsIndefiniteExecution = true


