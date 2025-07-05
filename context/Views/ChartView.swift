import SwiftUI

struct ChartView: View {
    @EnvironmentObject var appState: AppStateManager
    let selectedProjectId: String?
    
    var body: some View {
        ZStack {
            Color(red: 27/255, green: 27/255, blue: 27/255)
                .ignoresSafeArea()
            
            if let projectId = selectedProjectId,
               let project = appState.state.projects[projectId] {
                TaskTreeView(project: project)
            } 
        }
        .overlay(
            Rectangle()
                .fill(Color(hex: "#3d3d3d"))
                .frame(width: 1),
            alignment: .trailing
        )
    }
}

struct TaskTreeView: View {
    @EnvironmentObject var appState: AppStateManager
    let project: Project
    
    @State private var zoomScale: CGFloat = 1.0
    @State private var lastMagnification: CGFloat = 1.0
    @State private var panOffset: CGSize = .zero
    @State private var basePanOffset: CGSize = .zero
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Fixed grid background (responds to zoom but not pan)
                GridBackgroundView(
                    panOffset: .zero,
                    zoomScale: zoomScale,
                    viewSize: geometry.size
                )
                
                // Moveable content (nodes and connections)
                ZStack {
                    // Draw connections first (behind nodes)
                    ForEach(Array(project.tasks.values), id: \.id) { task in
                        ForEach(task.childIds.compactMap { childId in
                            project.tasks[childId]
                        }, id: \.id) { childTask in
                            TaskConnectionView(
                                from: task.position,
                                to: childTask.position,
                                isActive: task.status == .active || childTask.status == .active
                            )
                        }
                    }
                    
                    // Draw nodes on top
                    ForEach(Array(project.tasks.values), id: \.id) { task in
                        TaskNodeView(
                            task: task,
                            isSelected: appState.state.selectedTaskId == task.id,
                            onSelect: { appState.selectTask(task.id) },
                            onDelete: { appState.deleteTask(projectId: project.id, taskId: task.id) }
                        )
                        .position(
                            x: task.position.x + 110 + geometry.size.width / 2,
                            y: task.position.y + 70 + geometry.size.height / 2
                        )
                    }
                }
                .scaleEffect(zoomScale)
                .offset(panOffset)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .clipped()
        }
        .background(Color(red: 27/255, green: 27/255, blue: 27/255))
        .onHover { isHovering in
            if isHovering {
                NSCursor.openHand.set()
            } else {
                NSCursor.arrow.set()
            }
        }
        .onTapGesture(count: 2) {
            // Double tap to reset zoom and pan
            withAnimation(.easeInOut(duration: 0.3)) {
                zoomScale = 1.0
                panOffset = .zero
                basePanOffset = .zero
            }
        }
        .onTapGesture {
            appState.selectTask(nil)
        }
        .gesture(
            SimultaneousGesture(
                MagnificationGesture()
                    .onChanged { value in
                        let delta = value / lastMagnification
                        lastMagnification = value
                        let newScale = zoomScale * delta
                        zoomScale = max(0.25, min(4.0, newScale))
                    }
                    .onEnded { _ in
                        lastMagnification = 1.0
                    },
                DragGesture()
                    .onChanged { value in
                        NSCursor.closedHand.set()
                        panOffset = CGSize(
                            width: basePanOffset.width + value.translation.width,
                            height: basePanOffset.height + value.translation.height
                        )
                    }
                    .onEnded { _ in
                        NSCursor.openHand.set()
                        basePanOffset = panOffset
                    }
            )
        )
                .background(
            // Invisible view to capture scroll events
            ScrollWheelCaptureView { deltaY, deltaX, modifierFlags in
                if modifierFlags.contains(.command) {
                    let zoomFactor = 1.0 + (deltaY * 0.01)
                    let newScale = zoomScale * zoomFactor
                    withAnimation(.easeInOut(duration: 0.1)) {
                        zoomScale = max(0.25, min(4.0, newScale))
                    }
                } else {
                    // Regular scroll for panning
                    let newOffset = CGSize(
                        width: panOffset.width + deltaX * 2,
                        height: panOffset.height + deltaY * 2
                    )
                    panOffset = newOffset
                    basePanOffset = newOffset
                }
            }
        )

    }
    
    private var maxX: CGFloat {
        project.tasks.values.map { $0.position.x }.max() ?? 0
    }
    
    private var maxY: CGFloat {
        project.tasks.values.map { $0.position.y }.max() ?? 0
    }
}

// Helper view to capture scroll wheel events
struct ScrollWheelCaptureView: NSViewRepresentable {
    let onScrollWheel: (CGFloat, CGFloat, NSEvent.ModifierFlags) -> Void
    
    func makeNSView(context: Context) -> NSView {
        let view = ScrollWheelView()
        view.onScrollWheel = onScrollWheel
        return view
    }
    
    func updateNSView(_ nsView: NSView, context: Context) {}
}

class ScrollWheelView: NSView {
    var onScrollWheel: ((CGFloat, CGFloat, NSEvent.ModifierFlags) -> Void)?
    
    override func scrollWheel(with event: NSEvent) {
        onScrollWheel?(event.deltaY, event.deltaX, event.modifierFlags)
        super.scrollWheel(with: event)
    }
    
    override var acceptsFirstResponder: Bool {
        return true
    }
    
    override func becomeFirstResponder() -> Bool {
        return true
    }
}

struct GridBackgroundView: View {
    let panOffset: CGSize
    let zoomScale: CGFloat
    let viewSize: CGSize
    
    private let baseGridSpacing: CGFloat = 60
    private let dotSize: CGFloat = 1.5
    private let minSpacing: CGFloat = 30  // Minimum spacing before switching to larger grid
    private let maxSpacing: CGFloat = 120 // Maximum spacing before switching to smaller grid
    
    @State private var currentLevel: Int = 0
    @State private var animatedOpacity: Double = 1.0
    
    var body: some View {
        Canvas { context, size in
            // Determine which single grid level to show
            let optimalLevel = determineOptimalGridLevel()
            
            // Check if we need to transition to a new level
            if optimalLevel != currentLevel {
                // Start fade out animation
                withAnimation(.easeInOut(duration: 0.2)) {
                    animatedOpacity = 0.0
                }
                
                // After fade out, switch level and fade back in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    currentLevel = optimalLevel
                    withAnimation(.easeInOut(duration: 0.2)) {
                        animatedOpacity = 1.0
                    }
                }
            }
            
            drawSingleGridLevel(context: context, size: size, level: currentLevel)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            currentLevel = determineOptimalGridLevel()
        }
    }
    
    private func determineOptimalGridLevel() -> Int {
        // Test different grid levels and pick the one that fits best
        let testLevels = [-2, -1, 0, 1, 2]
        
        for level in testLevels {
            let levelMultiplier = pow(2.0, Double(level))
            let gridSpacing = baseGridSpacing * CGFloat(levelMultiplier)
            let scaledSpacing = gridSpacing * zoomScale
            
            // Check if this level is in the optimal range
            if scaledSpacing >= minSpacing && scaledSpacing <= maxSpacing {
                return level
            }
        }
        
        // Fallback to level 0 if no optimal level found
        return 0
    }
    
    private func drawSingleGridLevel(context: GraphicsContext, size: CGSize, level: Int) {
        // Calculate spacing for this grid level
        let levelMultiplier = pow(2.0, Double(level))
        let gridSpacing = baseGridSpacing * CGFloat(levelMultiplier)
        let scaledSpacing = gridSpacing * zoomScale
        
        // Calculate fade based on how close we are to the edges of the optimal range
        let opacity = calculateFadeOpacity(scaledSpacing: scaledSpacing)
        
        // Skip drawing if opacity is too low
        guard opacity > 0.05 else { return }
        
        // Calculate grid offset to create a proper infinite grid pattern
        let offsetX: CGFloat = 0
        let offsetY: CGFloat = 0
        
        // Calculate the range of grid indices we need to draw to cover the entire view
        let extraDots = 3
        let minX = -scaledSpacing * CGFloat(extraDots)
        let maxX = size.width + scaledSpacing * CGFloat(extraDots)
        let minY = -scaledSpacing * CGFloat(extraDots)
        let maxY = size.height + scaledSpacing * CGFloat(extraDots)
        
        // Calculate starting indices based on the offset
        let startCol = Int(floor((minX - offsetX) / scaledSpacing))
        let endCol = Int(ceil((maxX - offsetX) / scaledSpacing))
        let startRow = Int(floor((minY - offsetY) / scaledSpacing))
        let endRow = Int(ceil((maxY - offsetY) / scaledSpacing))
        
        // Draw dots for this grid level
        for col in startCol...endCol {
            for row in startRow...endRow {
                let x = CGFloat(col) * scaledSpacing + offsetX
                let y = CGFloat(row) * scaledSpacing + offsetY
                
                // Only draw dots that are within the visible area (with some margin)
                guard x >= -dotSize && x <= size.width + dotSize &&
                      y >= -dotSize && y <= size.height + dotSize else { continue }
                
                context.fill(
                    Path(ellipseIn: CGRect(
                        x: x - dotSize/2,
                        y: y - dotSize/2,
                        width: dotSize,
                        height: dotSize
                    )),
                    with: .color(.white.opacity(0.25 * opacity * animatedOpacity))
                )
            }
        }
    }
    
    private func calculateFadeOpacity(scaledSpacing: CGFloat) -> Double {
        let center = (minSpacing + maxSpacing) / 2
        let range = maxSpacing - minSpacing
        let distance = abs(scaledSpacing - center)
        let normalizedDistance = distance / (range / 2)
        
        // Smooth fade at the edges
        if normalizedDistance > 1.0 {
            return max(0, 1.0 - (normalizedDistance - 1.0) * 2)
        }
        return 1.0
    }
}

struct TaskNodeView: View {
    let task: Task
    let isSelected: Bool
    let onSelect: () -> Void
    let onDelete: () -> Void
    
    @State private var showActions = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Header row
            HStack {
                Circle()
                    .fill(nodeTypeColor)
                    .frame(width: 12, height: 12)
                
                Spacer()
                
                HStack(spacing: 4) {
                    Circle()
                        .fill(statusColor)
                        .frame(width: 8, height: 8)
                    
                    Button(action: onDelete) {
                        Image(systemName: "trash")
                            .font(.system(size: 12))
                            .foregroundColor(Color(hex: "#707070"))
                    }
                    .buttonStyle(PlainButtonStyle())
                    .opacity(showActions ? 1 : 0)
                    .help("Delete node")
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
            
            // Content area - flexible height
            VStack(alignment: .leading, spacing: 4) {
                Text(task.title)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(Color(hex: "#ffffff"))
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                if !task.description.isEmpty {
                    Text(task.description)
                        .font(.system(size: 11))
                        .foregroundColor(Color(hex: "#a0a0a0"))
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .frame(maxWidth: .infinity, minHeight: 40, alignment: .leading)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            
            // Footer row
            HStack {
                Text(task.nodeType.rawValue.capitalized)
                    .font(.system(size: 10))
                    .foregroundColor(Color(hex: "#707070"))
                    .truncationMode(.tail)
                
                Spacer()
                
                Text(task.executionMode.rawValue.capitalized)
                    .font(.system(size: 10))
                    .foregroundColor(Color(hex: "#707070"))
                    .truncationMode(.tail)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 12)
            .overlay(
                Rectangle()
                    .fill(Color(hex: "#4d4d4d"))
                    .frame(height: 1),
                alignment: .top
            )
        }
        .frame(width: 220, height: 140)
        .background(Color.black.opacity(0.8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(isSelected ? Color(hex: "#a0a0a0") : nodeTypeColor, lineWidth: 2)
        )
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
        .onTapGesture {
            onSelect()
        }
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.2)) {
                showActions = hovering
            }
        }
    }
    
    private var nodeTypeColor: Color {
        switch task.nodeType {
        case .clone:
            return Color(hex: "#a0a0a0") // light gray
        case .spawn:
            return Color(hex: "#707070") // medium gray  
        case .original:
            return Color(hex: "#606060") // accent gray
        }
    }
    
    private var statusColor: Color {
        switch task.status {
        case .completed:
            return Color(hex: "#a0a0a0") // light gray
        case .active:
            return Color(hex: "#ffffff") // white
        case .failed:
            return Color(hex: "#707070") // medium gray
        default:
            return Color(hex: "#4d4d4d") // border gray
        }
    }
}

struct TaskConnectionView: View {
    let from: Task.Position
    let to: Task.Position
    let isActive: Bool
    
    var body: some View {
        Path { path in
            let fromPoint = CGPoint(x: from.x + 110, y: from.y + 140) // Bottom of from node
            let toPoint = CGPoint(x: to.x + 110, y: to.y) // Top of to node
            
            // Create a smooth step path
            let midY = (fromPoint.y + toPoint.y) / 2
            
            path.move(to: fromPoint)
            path.addLine(to: CGPoint(x: fromPoint.x, y: midY))
            path.addLine(to: CGPoint(x: toPoint.x, y: midY))
            path.addLine(to: toPoint)
        }
        .stroke(
            isActive ? Color(hex: "#a0a0a0") : Color(hex: "#707070"),
            lineWidth: 2
        )
    }
} 
