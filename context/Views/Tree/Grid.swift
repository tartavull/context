import SwiftUI

struct GridBackgroundView: NSViewRepresentable {
    let zoomScale: CGFloat
    let panOffset: CGSize
    
    func makeNSView(context: Context) -> PerformantGridView {
        let gridView = PerformantGridView()
        gridView.updateGrid(zoomScale: zoomScale, panOffset: panOffset)
        return gridView
    }
    
    func updateNSView(_ nsView: PerformantGridView, context: Context) {
        nsView.updateGrid(zoomScale: zoomScale, panOffset: panOffset)
    }
}

class PerformantGridView: NSView {
    private let baseGridSpacing: CGFloat = 60
    private let dotSize: CGFloat = 1.5
    private let minSpacing: CGFloat = 30
    private let maxSpacing: CGFloat = 120
    
    private var currentLevel: Int = 0
    private var zoomScale: CGFloat = 1.0
    private var panOffset: CGSize = .zero
    private var gridLayer: CALayer?
    
    // Cache to prevent unnecessary redraws
    private var lastBounds: CGRect = .zero
    private var lastZoomScale: CGFloat = 1.0
    private var lastPanOffset: CGSize = .zero
    private var lastLevel: Int = 0
    
    // Debouncing for resize events
    private var resizeTimer: Timer?
    private var pendingResize: Bool = false
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setupLayer()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLayer()
    }
    
    deinit {
        resizeTimer?.invalidate()
        resizeTimer = nil
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
        
        // Disable implicit animations during layout
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        // Only update grid layer frame, don't redraw content unless necessary
        gridLayer?.frame = bounds
        
        CATransaction.commit()
        
        // Check if we actually need to update the grid content
        if shouldUpdateGridContent() {
            // If only bounds changed (window resize), use faster debounce
            if bounds != lastBounds && 
               zoomScale == lastZoomScale && 
               panOffset == lastPanOffset && 
               currentLevel == lastLevel {
                debouncedUpdateGridContent()
            } else {
                // Immediate update for zoom/pan changes
                updateGridContent()
                updateCache()
            }
        }
    }
    
    private func debouncedUpdateGridContent() {
        pendingResize = true
        resizeTimer?.invalidate()
        resizeTimer = Timer.scheduledTimer(withTimeInterval: 0.016, repeats: false) { [weak self] _ in
            guard let self = self, self.pendingResize else { return }
            self.pendingResize = false
            
            // Disable animations during resize updates
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            self.updateGridContent()
            self.updateCache()
            CATransaction.commit()
        }
    }
    
    private func shouldUpdateGridContent() -> Bool {
        // Check if any relevant properties have changed
        return bounds != lastBounds ||
               zoomScale != lastZoomScale ||
               panOffset != lastPanOffset ||
               currentLevel != lastLevel
    }
    
    private func updateCache() {
        lastBounds = bounds
        lastZoomScale = zoomScale
        lastPanOffset = panOffset
        lastLevel = currentLevel
    }
    
    func updateGrid(zoomScale: CGFloat, panOffset: CGSize) {
        self.zoomScale = zoomScale
        self.panOffset = panOffset
        let optimalLevel = determineOptimalGridLevel()
        
        if optimalLevel != currentLevel {
            currentLevel = optimalLevel
            animateGridTransition()
        } else if shouldUpdateGridContent() {
            updateGridContent()
            updateCache()
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
        CATransaction.setAnimationDuration(0.15) // Slightly faster transition
        gridLayer?.opacity = 0.0
        CATransaction.setCompletionBlock {
            // Update content and fade back in
            self.updateGridContent()
            self.updateCache()
            CATransaction.begin()
            CATransaction.setAnimationDuration(0.15)
            self.gridLayer?.opacity = 1.0
            CATransaction.commit()
        }
        CATransaction.commit()
    }
    
    private func updateGridContent() {
        guard let gridLayer = gridLayer else { return }
        
        let size = bounds.size
        
        // If bounds are empty, don't draw anything
        guard size.width > 0 && size.height > 0 else {
            return
        }
        
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
        let dotColor = NSColor.white.withAlphaComponent(0.5 * opacity).cgColor
        context.setFillColor(dotColor)
        
        // Calculate grid range with pan offset and zoom center adjustment
        let extraDots = 3
        
        // Only apply zoom center adjustment when actually zoomed (not at 1.0 scale)
        let adjustedOffsetX: CGFloat
        let adjustedOffsetY: CGFloat
        
        if abs(zoomScale - 1.0) > 0.001 {
            // Calculate zoom center (center of the view)
            let centerX = size.width / 2
            let centerY = size.height / 2
            
            // Adjust offset to account for zoom center
            let zoomCenterAdjustmentX = centerX * (1 - zoomScale)
            let zoomCenterAdjustmentY = centerY * (1 - zoomScale)
            
            adjustedOffsetX = panOffset.width + zoomCenterAdjustmentX
            adjustedOffsetY = -panOffset.height + zoomCenterAdjustmentY
        } else {
            // At normal zoom, use simple offset without center adjustments
            adjustedOffsetX = panOffset.width
            adjustedOffsetY = -panOffset.height
        }
        
        let offsetX = adjustedOffsetX.truncatingRemainder(dividingBy: scaledSpacing)
        let offsetY = adjustedOffsetY.truncatingRemainder(dividingBy: scaledSpacing)
        
        let minX = -scaledSpacing * CGFloat(extraDots) - offsetX
        let maxX = size.width + scaledSpacing * CGFloat(extraDots) - offsetX
        let minY = -scaledSpacing * CGFloat(extraDots) - offsetY
        let maxY = size.height + scaledSpacing * CGFloat(extraDots) - offsetY
        
        let startCol = Int(floor(minX / scaledSpacing))
        let endCol = Int(ceil(maxX / scaledSpacing))
        let startRow = Int(floor(minY / scaledSpacing))
        let endRow = Int(ceil(maxY / scaledSpacing))
        
        // Draw dots efficiently
        for col in startCol...endCol {
            for row in startRow...endRow {
                let x = CGFloat(col) * scaledSpacing + offsetX
                let y = CGFloat(row) * scaledSpacing + offsetY
                
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