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
                // Grid background
                GridBackgroundView(
                    panOffset: panOffset,
                    zoomScale: zoomScale,
                    viewSize: geometry.size
                )
                
                // Draw connections first (behind nodes)
                ForEach(Array(project.tasks.values), id: \.id) { task in
                    ForEach(task.childIds, id: \.self) { childId in
                        if let childTask = project.tasks[childId] {
                            TaskConnectionView(
                                from: task.position,
                                to: childTask.position,
                                isActive: task.status == .active || childTask.status == .active
                            )
                        }
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
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .scaleEffect(zoomScale)
            .offset(panOffset)
            .clipped()
        }
        .background(Color(red: 27/255, green: 27/255, blue: 27/255))
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
                        panOffset = CGSize(
                            width: basePanOffset.width + value.translation.width,
                            height: basePanOffset.height + value.translation.height
                        )
                    }
                    .onEnded { _ in
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
    
    private let gridSpacing: CGFloat = 50
    private let dotSize: CGFloat = 2
    
    var body: some View {
        Canvas { context, size in
            // Calculate the effective grid spacing with zoom
            let scaledSpacing = gridSpacing * zoomScale
            
            // Calculate the grid offset to create an infinite grid
            // The grid should appear to extend infinitely in all directions
            let offsetX = panOffset.width.truncatingRemainder(dividingBy: scaledSpacing)
            let offsetY = panOffset.height.truncatingRemainder(dividingBy: scaledSpacing)
            
            // Calculate the range of grid indices we need to draw
            let extraDots = 3 // Extra dots beyond visible area for smooth scrolling
            let minX = -scaledSpacing * CGFloat(extraDots)
            let maxX = size.width + scaledSpacing * CGFloat(extraDots)
            let minY = -scaledSpacing * CGFloat(extraDots)
            let maxY = size.height + scaledSpacing * CGFloat(extraDots)
            
            // Calculate starting indices based on the offset
            let startCol = Int(floor((minX - offsetX) / scaledSpacing))
            let endCol = Int(ceil((maxX - offsetX) / scaledSpacing))
            let startRow = Int(floor((minY - offsetY) / scaledSpacing))
            let endRow = Int(ceil((maxY - offsetY) / scaledSpacing))
            
            // Draw dots in an infinite grid pattern
            for col in startCol...endCol {
                for row in startRow...endRow {
                    let x = CGFloat(col) * scaledSpacing + offsetX
                    let y = CGFloat(row) * scaledSpacing + offsetY
                    
                    // Draw the dot
                    context.fill(
                        Path(ellipseIn: CGRect(
                            x: x - dotSize/2,
                            y: y - dotSize/2,
                            width: dotSize,
                            height: dotSize
                        )),
                        with: .color(.white.opacity(0.3))
                    )
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
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
