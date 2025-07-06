import SwiftUI

// Observable class to manage canvas state without recreating views
class TreeCanvasState: ObservableObject {
    @Published var zoomScale: CGFloat = 1.0
    @Published var panOffset: CGSize = .zero
    @Published var project: Project?
    @Published var appState: AppStateManager?
}

// Main tree view that handles project selection and creates the interactive canvas
struct TreeView: NSViewRepresentable {
    @EnvironmentObject var appState: AppStateManager
    let selectedProjectId: String?
    
    func makeNSView(context: Context) -> TreeCanvasView {
        let canvasView = TreeCanvasView()
        canvasView.appState = appState
        return canvasView
    }
    
    func updateNSView(_ nsView: TreeCanvasView, context: Context) {
        nsView.appState = appState
        
        // Update project
        if let projectId = selectedProjectId,
           let project = appState.state.projects[projectId] {
            nsView.updateProject(project)
        } else {
            nsView.updateProject(nil)
        }
    }
}

// Single NSView that handles everything: input, rendering, and state management
class TreeCanvasView: NSView {
    var appState: AppStateManager?
    
    // Canvas state management
    private let canvasState = TreeCanvasState()
    
    // Interaction state
    private var isDragging = false
    private var lastMouseLocation: NSPoint = .zero
    
    // SwiftUI hosting for the actual content
    private var hostingView: NSView?
    
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
        
        // Set up tracking area for mouse events
        updateTrackingArea()
        setupContent()
    }
    
    private func updateTrackingArea() {
        // Remove existing tracking areas
        trackingAreas.forEach { removeTrackingArea($0) }
        
        // Add new tracking area
        let trackingArea = NSTrackingArea(
            rect: bounds,
            options: [.activeInActiveApp, .mouseEnteredAndExited, .mouseMoved, .inVisibleRect],
            owner: self,
            userInfo: nil
        )
        addTrackingArea(trackingArea)
    }
    
    override func layout() {
        super.layout()
        updateTrackingArea()
        
        // Disable implicit animations for layout updates to eliminate springiness
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        layoutHostingView()
        CATransaction.commit()
    }
    
    private func setupContent() {
        // Create the hosting view once and reuse it
        let contentView = TreeCanvasContentView()
            .environmentObject(canvasState)
        
        hostingView = NSHostingView(rootView: contentView)
        
        if let hostingView = hostingView {
            addSubview(hostingView)
            hostingView.frame = bounds
            hostingView.autoresizingMask = [.width, .height]
        }
    }
    
    private func layoutHostingView() {
        guard let hostingView = hostingView else { return }
        
        // Simply update the frame without removing/re-adding the view
        hostingView.frame = bounds
        hostingView.autoresizingMask = [.width, .height]
    }
    
    func updateProject(_ project: Project?) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.canvasState.project = project
            self.canvasState.appState = self.appState
        }
    }
    
    // MARK: - Mouse Events
    
    override func mouseDown(with event: NSEvent) {
        super.mouseDown(with: event)
        
        if event.clickCount == 2 {
            // Double click to reset zoom and pan
            DispatchQueue.main.async { [weak self] in
                self?.canvasState.zoomScale = 1.0
                self?.canvasState.panOffset = .zero
            }
            return
        }
        
        // Single click handling
        window?.makeFirstResponder(self)
        lastMouseLocation = event.locationInWindow
        isDragging = true
        
        let localPoint = convert(event.locationInWindow, from: nil)
        handleTaskSelection(at: localPoint)
    }
    
    override func mouseDragged(with event: NSEvent) {
        guard isDragging else { return }
        
        let currentLocation = event.locationInWindow
        let deltaX = currentLocation.x - lastMouseLocation.x
        let deltaY = currentLocation.y - lastMouseLocation.y
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.canvasState.panOffset = CGSize(
                width: self.canvasState.panOffset.width + deltaX,
                height: self.canvasState.panOffset.height - deltaY // Flip Y coordinate
            )
        }
        
        lastMouseLocation = currentLocation
        
        // Update cursor
        NSCursor.closedHand.set()
    }
    
    override func mouseUp(with event: NSEvent) {
        isDragging = false
        NSCursor.openHand.set()
    }
    
    override func mouseEntered(with event: NSEvent) {
        NSCursor.openHand.set()
    }
    
    override func mouseExited(with event: NSEvent) {
        NSCursor.arrow.set()
    }
    
    // MARK: - Scroll and Zoom Events
    
    override func scrollWheel(with event: NSEvent) {
        var deltaX = event.scrollingDeltaX
        var deltaY = event.scrollingDeltaY
        
        // Handle precise scrolling (trackpad)
        if event.hasPreciseScrollingDeltas {
            deltaX = event.scrollingDeltaX
            deltaY = event.scrollingDeltaY
        } else {
            deltaX = event.deltaX * 10
            deltaY = event.deltaY * 10
        }
        
        if event.modifierFlags.contains(.command) {
            // Zoom with command key
            let zoomFactor = 1.0 + (deltaY * 0.01)
            let newScale = canvasState.zoomScale * zoomFactor
            let clampedScale = max(0.25, min(4.0, newScale))
            
            DispatchQueue.main.async { [weak self] in
                self?.canvasState.zoomScale = clampedScale
            }
        } else {
            // Pan without command key
            let sensitivity: CGFloat = 1.0
            let newPanOffset = CGSize(
                width: canvasState.panOffset.width + deltaX * sensitivity,
                height: canvasState.panOffset.height + deltaY * sensitivity
            )
            
            DispatchQueue.main.async { [weak self] in
                self?.canvasState.panOffset = newPanOffset
            }
        }
    }
    
    override func magnify(with event: NSEvent) {
        let newScale = canvasState.zoomScale * (1.0 + event.magnification)
        let clampedScale = max(0.25, min(4.0, newScale))
        
        DispatchQueue.main.async { [weak self] in
            self?.canvasState.zoomScale = clampedScale
        }
    }
    
    // MARK: - Task Selection
    
    private func handleTaskSelection(at point: NSPoint) {
        guard let project = canvasState.project, let appState = appState else { return }
        
        // Transform point to account for zoom and pan
        let transformedPoint = CGPoint(
            x: (point.x - canvasState.panOffset.width) / canvasState.zoomScale,
            y: (point.y - canvasState.panOffset.height) / canvasState.zoomScale
        )
        
        // Check if point hits any task
        var selectedTask: ProjectTask? = nil
        for task in project.tasks.values {
            let taskRect = CGRect(
                x: task.position.x,
                y: task.position.y,
                width: 220, // Approximate task node width
                height: 140  // Approximate task node height
            )
            
            if taskRect.contains(transformedPoint) {
                selectedTask = task
                break
            }
        }
        
        // Update selection
        if let task = selectedTask {
            appState.selectTask(task.id)
        } else {
            appState.selectTask(nil)
        }
    }
    
    // MARK: - First Responder
    
    override var acceptsFirstResponder: Bool {
        return true
    }
    
    override func becomeFirstResponder() -> Bool {
        return true
    }
}

// SwiftUI view that renders the tree content
struct TreeCanvasContentView: View, Equatable {
    @EnvironmentObject var canvasState: TreeCanvasState
    
    // Implement Equatable to prevent unnecessary updates
    static func == (lhs: TreeCanvasContentView, rhs: TreeCanvasContentView) -> Bool {
        // Content is the same if canvas state hasn't changed meaningfully
        return true // Let @EnvironmentObject handle the updates
    }
    
    var body: some View {
        ZStack {
            if let project = canvasState.project, let appState = canvasState.appState {
                // Grid background (responds to both zoom and pan)
                GridBackgroundView(zoomScale: canvasState.zoomScale, panOffset: canvasState.panOffset)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .accessibilityIdentifier("TreeCanvasView_GridBackground")
                
                // Tree content (responds to both zoom and pan)
                ZStack {
                    // Draw connections first (behind nodes)
                    ForEach(Array(project.tasks.values), id: \.id) { task in
                        ForEach(task.childIds.compactMap { childId in
                            project.tasks[childId]
                        }, id: \.id) { childTask in
                            TreeEdge(
                                from: task.position,
                                to: childTask.position,
                                isActive: task.status == .active || childTask.status == .active
                            )
                            .accessibilityIdentifier("TreeCanvasView_Edge_\(task.id)_to_\(childTask.id)")
                        }
                    }
                    
                    // Draw nodes on top
                    ForEach(Array(project.tasks.values), id: \.id) { task in
                        TreeNode(
                            task: task,
                            isSelected: appState.state.selectedTaskId == task.id,
                            onSelect: { appState.selectTask(task.id) },
                            onDelete: { appState.deleteTask(projectId: project.id, taskId: task.id) }
                        )
                        .id(task.id) // Ensure stable identity
                        .position(
                            x: task.position.x + 110,
                            y: task.position.y + 70
                        )
                        .accessibilityIdentifier("TreeCanvasView_TaskNode_\(task.id)")
                    }
                }
                .scaleEffect(canvasState.zoomScale)
                .offset(canvasState.panOffset)
                .accessibilityIdentifier("TreeCanvasView_TreeContent")
            } else {
                // Empty state - just background
                Color(red: 27/255, green: 27/255, blue: 27/255)
                    .ignoresSafeArea()
                    .accessibilityIdentifier("TreeCanvasView_EmptyBackground")
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .clipped()
        .animation(nil, value: canvasState.zoomScale) // Disable implicit animations
        .animation(nil, value: canvasState.panOffset) // Disable implicit animations
        .accessibilityIdentifier("TreeCanvasView_Main")
        .overlay(
            Rectangle()
                .fill(Color(hex: "#3d3d3d"))
                .frame(width: 1),
            alignment: .trailing
        )
    }
}




