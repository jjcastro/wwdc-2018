import UIKit
import PlaygroundSupport

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


class CollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    var n: Int
    var size: Int
    var images: [UIImage]
    var position: Int
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(size: Int, images: [UIImage]) {
        self.size = size
        self.images = []
        var preshuffle = images
        
        for _ in 0..<preshuffle.count {
            let rand = Int(arc4random_uniform(UInt32(preshuffle.count)))
            self.images.append(preshuffle[rand])
            preshuffle.remove(at: rand)
        }
        
        self.currentHole = Int(arc4random_uniform(UInt32(self.images.count)))
        self.images[self.currentHole] = UIImage(color: .black, size: self.images[0].size)!
        
        n = Int(sqrt(Double(images.count)))
        
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        super.init(collectionViewLayout: layout)
    }
    
    @objc func handleSwipe(gesture: UIGestureRecognizer) {
        
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
//        collectionView?.center = CGPoint(x: UIScreen.main.bounds.width / CGFloat(2), y:200)
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
        cell.backgroundColor = .green
        
//        print(indexPath.section)
        
        cell.layer.borderWidth = 1
        cell.layer.borderColor = UIColor.white.cgColor
        
        let image = self.images[indexPath.item]
        
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: cell.frame.width, height: cell.frame.height))
        imageView.contentMode = .scaleAspectFill
        imageView.image = image
        
        cell.contentView.addSubview(imageView)
        
        return cell
    }
}

if let img = UIImage(named: "london.jpg") {
    let cropped =  img.getCenterSquare()
    let new = cropped.breakIntoParts(val: 4)
    
    let thing = CollectionViewController(size: 300, images: new)
    
    thing.collectionView?.layer.borderWidth = 2
    thing.collectionView?.layer.borderColor = UIColor.white.cgColor
    
    PlaygroundPage.current.liveView = thing
    PlaygroundPage.current.needsIndefiniteExecution = true
    
}


