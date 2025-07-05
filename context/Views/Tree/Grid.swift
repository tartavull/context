import SwiftUI

struct GridBackgroundView: NSViewRepresentable {
    let zoomScale: CGFloat
    
    func makeNSView(context: Context) -> PerformantGridView {
        let gridView = PerformantGridView()
        return gridView
    }
    
    func updateNSView(_ nsView: PerformantGridView, context: Context) {
        nsView.updateGrid(zoomScale: zoomScale)
    }
}

class PerformantGridView: NSView {
    private let baseGridSpacing: CGFloat = 60
    private let dotSize: CGFloat = 1.5
    private let minSpacing: CGFloat = 30
    private let maxSpacing: CGFloat = 120
    
    private var currentLevel: Int = 0
    private var zoomScale: CGFloat = 1.0
    private var gridLayer: CALayer?
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setupLayer()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLayer()
    }
    
    private func setupLayer() {
        wantsLayer = true
        layer?.backgroundColor = NSColor.clear.cgColor
        
        // Create a dedicated layer for the grid
        gridLayer = CALayer()
        gridLayer?.contentsScale = NSScreen.main?.backingScaleFactor ?? 2.0
        layer?.addSublayer(gridLayer!)
    }
    
    override func layout() {
        super.layout()
        gridLayer?.frame = bounds
        updateGridContent()
    }
    
    func updateGrid(zoomScale: CGFloat) {
        self.zoomScale = zoomScale
        let optimalLevel = determineOptimalGridLevel()
        
        if optimalLevel != currentLevel {
            currentLevel = optimalLevel
            animateGridTransition()
        } else {
            updateGridContent()
        }
    }
    
    private func determineOptimalGridLevel() -> Int {
        let testLevels = [-2, -1, 0, 1, 2]
        
        for level in testLevels {
            let levelMultiplier = pow(2.0, Double(level))
            let gridSpacing = baseGridSpacing * CGFloat(levelMultiplier)
            let scaledSpacing = gridSpacing * zoomScale
            
            if scaledSpacing >= minSpacing && scaledSpacing <= maxSpacing {
                return level
            }
        }
        return 0
    }
    
    private func animateGridTransition() {
        // Fade out current grid
        CATransaction.begin()
        CATransaction.setAnimationDuration(0.2)
        gridLayer?.opacity = 0.0
        CATransaction.setCompletionBlock {
            // Update content and fade back in
            self.updateGridContent()
            CATransaction.begin()
            CATransaction.setAnimationDuration(0.2)
            self.gridLayer?.opacity = 1.0
            CATransaction.commit()
        }
        CATransaction.commit()
    }
    
    private func updateGridContent() {
        guard let gridLayer = gridLayer else { return }
        
        let size = bounds.size
        let levelMultiplier = pow(2.0, Double(currentLevel))
        let gridSpacing = baseGridSpacing * CGFloat(levelMultiplier)
        let scaledSpacing = gridSpacing * zoomScale
        
        let opacity = calculateFadeOpacity(scaledSpacing: scaledSpacing)
        guard opacity > 0.05 else {
            gridLayer.contents = nil
            return
        }
        
        // Create bitmap context for drawing
        let scale = NSScreen.main?.backingScaleFactor ?? 2.0
        let pixelSize = CGSize(width: size.width * scale, height: size.height * scale)
        
        guard let context = CGContext(
            data: nil,
            width: Int(pixelSize.width),
            height: Int(pixelSize.height),
            bitsPerComponent: 8,
            bytesPerRow: 0,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else { return }
        
        // Scale context for retina
        context.scaleBy(x: scale, y: scale)
        
        // Clear background
        context.clear(CGRect(origin: .zero, size: size))
        
        // Set dot color
        let dotColor = NSColor.white.withAlphaComponent(0.25 * opacity).cgColor
        context.setFillColor(dotColor)
        
        // Calculate grid range
        let extraDots = 3
        let minX = -scaledSpacing * CGFloat(extraDots)
        let maxX = size.width + scaledSpacing * CGFloat(extraDots)
        let minY = -scaledSpacing * CGFloat(extraDots)
        let maxY = size.height + scaledSpacing * CGFloat(extraDots)
        
        let startCol = Int(floor(minX / scaledSpacing))
        let endCol = Int(ceil(maxX / scaledSpacing))
        let startRow = Int(floor(minY / scaledSpacing))
        let endRow = Int(ceil(maxY / scaledSpacing))
        
        // Draw dots efficiently
        for col in startCol...endCol {
            for row in startRow...endRow {
                let x = CGFloat(col) * scaledSpacing
                let y = CGFloat(row) * scaledSpacing
                
                guard x >= -dotSize && x <= size.width + dotSize &&
                      y >= -dotSize && y <= size.height + dotSize else { continue }
                
                let dotRect = CGRect(
                    x: x - dotSize/2,
                    y: y - dotSize/2,
                    width: dotSize,
                    height: dotSize
                )
                context.fillEllipse(in: dotRect)
            }
        }
        
        // Create image and assign to layer
        if let cgImage = context.makeImage() {
            gridLayer.contents = cgImage
        }
    }
    
    private func calculateFadeOpacity(scaledSpacing: CGFloat) -> Double {
        let center = (minSpacing + maxSpacing) / 2
        let range = maxSpacing - minSpacing
        let distance = abs(scaledSpacing - center)
        let normalizedDistance = distance / (range / 2)
        
        if normalizedDistance > 1.0 {
            return max(0, 1.0 - (normalizedDistance - 1.0) * 2)
        }
        return 1.0
    }
} 