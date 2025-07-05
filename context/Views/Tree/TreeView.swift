import SwiftUI

struct TreeContainer: View {
    @EnvironmentObject var appState: AppStateManager
    let selectedProjectId: String?
    
    var body: some View {
        ZStack {
            Color(red: 27/255, green: 27/255, blue: 27/255)
                .ignoresSafeArea()
            
            if let projectId = selectedProjectId,
               let project = appState.state.projects[projectId] {
                TreeView(project: project)
                    .environmentObject(appState)
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

struct TreeView: View {
    @EnvironmentObject var appState: AppStateManager
    let project: Project
    
    @State private var zoomScale: CGFloat = 1.0
    @State private var lastMagnification: CGFloat = 1.0
    @State private var panOffset: CGSize = .zero
    @State private var basePanOffset: CGSize = .zero
    
    var body: some View {
        ZStack {
            // Background color
            Color(red: 27/255, green: 27/255, blue: 27/255)
                .ignoresSafeArea()
            
            // Main content wrapped in scroll container
            ScrollContainer(
                project: project,
                appState: appState,
                zoomScale: $zoomScale,
                panOffset: $panOffset,
                basePanOffset: $basePanOffset,
                lastMagnification: $lastMagnification
            )
            
            // Overlay the original SwiftUI content on top
            GeometryReader { geometry in
                ZStack {
                    // Fixed grid background (responds to zoom but not pan)
                    GridBackgroundView(zoomScale: zoomScale)
                    
                    // Moveable content (nodes and connections)
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
                                x: task.position.x + 110,
                                y: task.position.y + 70
                            )
                        }
                    }
                    .scaleEffect(zoomScale)
                    .offset(panOffset)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .clipped()
            }
            .allowsHitTesting(false)
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
        }
    }
    
    private var maxX: CGFloat {
        project.tasks.values.map { $0.position.x }.max() ?? 0
    }
    
    private var maxY: CGFloat {
        project.tasks.values.map { $0.position.y }.max() ?? 0
    }
}


