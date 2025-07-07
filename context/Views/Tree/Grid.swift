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
        guard size.width > 0 && size.height > 0 else { return }

        let levelMultiplier = pow(2.0, Double(currentLevel))
        let gridSpacing = baseGridSpacing * CGFloat(levelMultiplier)
        let scaledSpacing = gridSpacing * zoomScale

        let opacity = calculateFadeOpacity(scaledSpacing: scaledSpacing)
        guard opacity > 0.05 else {
            gridLayer.contents = nil
            return
        }

        guard let context = createDrawingContext(size: size) else { return }
        setupDrawingContext(context, size: size, opacity: opacity)
        
        let gridParams = calculateGridParameters(size: size, scaledSpacing: scaledSpacing)
        drawGridDots(context: context, params: gridParams, size: size)
        
        if let cgImage = context.makeImage() {
            gridLayer.contents = cgImage
        }
    }

    private func createDrawingContext(size: CGSize) -> CGContext? {
        let scale = NSScreen.main?.backingScaleFactor ?? 2.0
        let pixelSize = CGSize(width: size.width * scale, height: size.height * scale)

        return CGContext(
            data: nil,
            width: Int(pixelSize.width),
            height: Int(pixelSize.height),
            bitsPerComponent: 8,
            bytesPerRow: 0,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        )
    }

    private func setupDrawingContext(_ context: CGContext, size: CGSize, opacity: Double) {
        let scale = NSScreen.main?.backingScaleFactor ?? 2.0
        context.scaleBy(x: scale, y: scale)
        context.clear(CGRect(origin: .zero, size: size))
        
        let dotColor = NSColor.white.withAlphaComponent(0.5 * opacity).cgColor
        context.setFillColor(dotColor)
    }

    private func calculateGridParameters(size: CGSize, scaledSpacing: CGFloat) -> GridDrawingParams {
        let extraDots = 3
        
        let (adjustedOffsetX, adjustedOffsetY) = calculateAdjustedOffsets(size: size)
        
        let offsetX = adjustedOffsetX.truncatingRemainder(dividingBy: scaledSpacing)
        let offsetY = adjustedOffsetY.truncatingRemainder(dividingBy: scaledSpacing)

        let minX = -scaledSpacing * CGFloat(extraDots) - offsetX
        let maxX = size.width + scaledSpacing * CGFloat(extraDots) - offsetX
        let minY = -scaledSpacing * CGFloat(extraDots) - offsetY
        let maxY = size.height + scaledSpacing * CGFloat(extraDots) - offsetY

        return GridDrawingParams(
            scaledSpacing: scaledSpacing,
            offsetX: offsetX,
            offsetY: offsetY,
            startCol: Int(floor(minX / scaledSpacing)),
            endCol: Int(ceil(maxX / scaledSpacing)),
            startRow: Int(floor(minY / scaledSpacing)),
            endRow: Int(ceil(maxY / scaledSpacing))
        )
    }

    private func calculateAdjustedOffsets(size: CGSize) -> (CGFloat, CGFloat) {
        if abs(zoomScale - 1.0) > 0.001 {
            let centerX = size.width / 2
            let centerY = size.height / 2
            let zoomCenterAdjustmentX = centerX * (1 - zoomScale)
            let zoomCenterAdjustmentY = centerY * (1 - zoomScale)
            
            return (
                panOffset.width + zoomCenterAdjustmentX,
                -panOffset.height + zoomCenterAdjustmentY
            )
        } else {
            return (panOffset.width, -panOffset.height)
        }
    }

    private func drawGridDots(context: CGContext, params: GridDrawingParams, size: CGSize) {
        for col in params.startCol...params.endCol {
            for row in params.startRow...params.endRow {
                let x = CGFloat(col) * params.scaledSpacing + params.offsetX
                let y = CGFloat(row) * params.scaledSpacing + params.offsetY

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
    }

    private struct GridDrawingParams {
        let scaledSpacing: CGFloat
        let offsetX: CGFloat
        let offsetY: CGFloat
        let startCol: Int
        let endCol: Int
        let startRow: Int
        let endRow: Int
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
