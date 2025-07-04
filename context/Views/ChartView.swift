import SwiftUI

struct ChartView: View {
    @EnvironmentObject var appState: AppStateManager
    let selectedProjectId: String?
    
    var body: some View {
        ZStack {
            Color(hex: "#2d2d2d")
                .ignoresSafeArea()
            
            if let projectId = selectedProjectId,
               let project = appState.state.projects[projectId] {
                TaskTreeView(project: project)
            } else {
                // No project selected state
                VStack(spacing: 16) {
                    Image(systemName: "rectangle.3.group")
                        .font(.system(size: 48))
                        .foregroundColor(.gray)
                    
                    Text("No Project Selected")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.white)
                    
                    Text("Select a project from the left panel to view its task tree")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                }
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
    
    var body: some View {
        ScrollView([.horizontal, .vertical]) {
            ZStack {
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
                    .position(x: task.position.x + 110, y: task.position.y + 70) // Center the node
                }
            }
            .frame(width: max(1200, maxX + 300), height: max(800, maxY + 200))
        }
        .background(Color(hex: "#2d2d2d"))
        .onTapGesture {
            appState.selectTask(nil)
        }
    }
    
    private var maxX: CGFloat {
        project.tasks.values.map { $0.position.x }.max() ?? 0
    }
    
    private var maxY: CGFloat {
        project.tasks.values.map { $0.position.y }.max() ?? 0
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
        .background(Color(hex: "#2d2d2d"))
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