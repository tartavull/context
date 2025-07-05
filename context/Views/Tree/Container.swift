import SwiftUI

struct ScrollContainer: NSViewRepresentable {
    let project: Project
    let appState: AppStateManager
    @Binding var zoomScale: CGFloat
    @Binding var panOffset: CGSize
    @Binding var basePanOffset: CGSize
    @Binding var lastMagnification: CGFloat
    
    func makeNSView(context: Context) -> ScrollContainerView {
        let view = ScrollContainerView()
        view.project = project
        view.appState = appState
        view.onZoomChange = { newZoom in
            zoomScale = newZoom
        }
        view.onPanChange = { newPan, newBasePan in
            panOffset = newPan
            basePanOffset = newBasePan
        }
        return view
    }
    
    func updateNSView(_ nsView: ScrollContainerView, context: Context) {
        nsView.project = project
        nsView.currentZoom = zoomScale
        nsView.currentPan = panOffset
        nsView.currentBasePan = basePanOffset
        nsView.needsDisplay = true
    }
}

class ScrollContainerView: NSView {
    var project: Project?
    var appState: AppStateManager?
    var onZoomChange: ((CGFloat) -> Void)?
    var onPanChange: ((CGSize, CGSize) -> Void)?
    
    var currentZoom: CGFloat = 1.0
    var currentPan: CGSize = .zero
    var currentBasePan: CGSize = .zero
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        wantsLayer = true
        layer?.backgroundColor = NSColor(red: 27/255, green: 27/255, blue: 27/255, alpha: 1.0).cgColor
        
        // Try to intercept scroll events at a higher level
        NSEvent.addLocalMonitorForEvents(matching: [.scrollWheel]) { event in
            if self.window?.firstResponder == self {
                self.scrollWheel(with: event)
                return nil  // Consume the event
            }
            return event  // Let it pass through
        }
        
        // Also intercept magnify events
        NSEvent.addLocalMonitorForEvents(matching: [.magnify]) { event in
            if self.window?.firstResponder == self {
                self.magnify(with: event)
                return nil  // Consume the event
            }
            return event  // Let it pass through
        }
    }
    
    override func scrollWheel(with event: NSEvent) {
        // Handle both scroll wheel and trackpad gestures
        var deltaX = event.scrollingDeltaX
        var deltaY = event.scrollingDeltaY
        
        // If we have precise scrolling (trackpad), use those values
        if event.hasPreciseScrollingDeltas {
            deltaX = event.scrollingDeltaX
            deltaY = event.scrollingDeltaY
        } else {
            deltaX = event.deltaX * 10
            deltaY = event.deltaY * 10
        }
        
        if event.modifierFlags.contains(.command) {
            // Command key + scroll for zooming
            let zoomFactor = 1.0 + (deltaY * 0.01)
            let newScale = currentZoom * zoomFactor
            let clampedScale = max(0.25, min(4.0, newScale))
            onZoomChange?(clampedScale)
        } else {
            // Default scroll behavior: panning
            let sensitivity: CGFloat = 1.0
            let newPan = CGSize(
                width: currentPan.width + deltaX * sensitivity,
                height: currentPan.height + deltaY * sensitivity
            )
            onPanChange?(newPan, newPan)
        }
    }
    
    override func magnify(with event: NSEvent) {
        let newScale = currentZoom * (1.0 + event.magnification)
        let clampedScale = max(0.25, min(4.0, newScale))
        onZoomChange?(clampedScale)
    }
    
    override func mouseDragged(with event: NSEvent) {
        // Ensure panning by clicking and dragging works
        let newPan = CGSize(
            width: currentPan.width + event.deltaX,
            height: currentPan.height + event.deltaY
        )
        onPanChange?(newPan, newPan)
    }
    
    override func mouseDown(with event: NSEvent) {
        // Start tracking for drag - this ensures click and drag panning works
        super.mouseDown(with: event)
        window?.makeFirstResponder(self)
    }
    
    override var acceptsFirstResponder: Bool {
        return true
    }
    
    override func becomeFirstResponder() -> Bool {
        return true
    }
    
    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if let window = self.window {
                window.makeFirstResponder(self)
            }
        }
    }
} 