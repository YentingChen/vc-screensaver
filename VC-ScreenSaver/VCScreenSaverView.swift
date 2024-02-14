import ScreenSaver

class VCScreenSaverView: ScreenSaverView {
    
    let colorSet: [NSColor] = [.red, .brown, .blue, .purple, .gray, .clear]

    var imageView = NSImageView()

    lazy var deltaX: CGFloat = 10
    lazy var deltaY: CGFloat = deltaX
    
    lazy var logoWidth = bounds.height / 7

    override init?(frame: NSRect, isPreview: Bool) {
        super.init(frame: frame, isPreview: isPreview)
        logoConfiguration()
        
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func animateOneFrame() {
        super.animateOneFrame()
        
        var newFrame = imageView.frame
        newFrame.origin.y += deltaY
        newFrame.origin.x += deltaX

        
        let maxY = bounds.height - newFrame.height
        let maxX = bounds.width - newFrame.width

        if newFrame.origin.y < 0 || newFrame.origin.y > maxY {
            deltaY *= -1
            updateLogo()
        }
        
        if newFrame.origin.x < 0 || newFrame.origin.x > maxX {
            deltaX *= -1
            updateLogo()
        }
        
        imageView.frame = newFrame
        
    }
    
    private func updateLogo() {
        imageView.image = Bundle(for: type(of: self)).image(forResource: "logo-square")
        let changingColour = colorSet[Int.random(in: 0..<colorSet.count)]
        if changingColour != NSColor.clear {
            imageView.image = imageView.image!.tintImage(with: changingColour)!
        }
        imageView.image = imageView.image!.resizedMaintainingAspectRatio(width: logoWidth, height: logoWidth)
    }
    
    private func logoConfiguration() {
        self.imageView = NSImageView()
        let image = Bundle(for: type(of: self)).image(forResource: "logo-square")
        imageView.image = image
        imageView.frame = NSRect(x: CGFloat.random(in: 0..<bounds.width - logoWidth), y: CGFloat.random(in: 0..<bounds.height - logoWidth), width: logoWidth, height: logoWidth)
        imageView.image = imageView.image!.resizedMaintainingAspectRatio(width: logoWidth, height: logoWidth)
        addSubview(imageView)
    }
}

extension NSImage {
    func resizedMaintainingAspectRatio(width: CGFloat, height: CGFloat) -> NSImage {
            let ratioX = width / size.width
            let ratioY = height / size.height
            let ratio = ratioX < ratioY ? ratioX : ratioY
            let newHeight = size.height * ratio
            let newWidth = size.width * ratio
            let newSize = NSSize(width: newWidth, height: newHeight)
            let image = NSImage(size: newSize)
            image.lockFocus()
            let context = NSGraphicsContext.current
            context!.imageInterpolation = .high
            draw(in: NSRect(origin: .zero, size: newSize), from: NSZeroRect, operation: .copy, fraction: 1)
            image.unlockFocus()
            return image
        }
    
    func tintImage(with color: NSColor) -> NSImage? {
            let ciImage = CIImage(data: self.tiffRepresentation!)
            
            // Apply a color filter using Core Image
            let colorFilter = CIFilter(name: "CIFalseColor")!
            colorFilter.setValue(ciImage, forKey: "inputImage")
            colorFilter.setValue(CIColor(color: color), forKey: "inputColor0")
            
            if let outputImage = colorFilter.outputImage {
                let rep = NSCIImageRep(ciImage: outputImage)
                let tintedNSImage = NSImage(size: rep.size)
                tintedNSImage.addRepresentation(rep)
                return tintedNSImage
            }

            return nil
        }
    }

