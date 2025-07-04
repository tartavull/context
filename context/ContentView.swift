//
//  ContentView.swift
//  context
//
//  Created by Ignacio Tartavull on 7/3/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var appState = AppStateManager()
    @State private var projectsPanelWidth: CGFloat = 300
    @State private var isResizingProjects = false
    
    private let minPanelWidth: CGFloat = 200
    private let collapsedPanelWidth: CGFloat = 60
    private let collapseThreshold: CGFloat = 120
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HeaderView()
            
            // Main content area
            GeometryReader { geometry in
                HStack(spacing: 0) {
                    // Projects Panel
                    if appState.state.ui.showProjects {
                        ProjectsView(isCollapsed: appState.state.ui.projectsCollapsed)
                            .environmentObject(appState)
                            .frame(width: appState.state.ui.projectsCollapsed ? collapsedPanelWidth : projectsPanelWidth)
                            .background(Color.clear)
                            .animation(.easeInOut(duration: 0.2), value: appState.state.ui.projectsCollapsed)
                        
                        // Resize handle for projects panel
                        if !appState.state.ui.projectsCollapsed && appState.state.ui.showChart {
                            Rectangle()
                                .fill(isResizingProjects ? Color(hex: "#5a5a5a") : Color(hex: "#3d3d3d"))
                                .frame(width: 1)
                                .contentShape(Rectangle())
                                .gesture(
                                    DragGesture()
                                        .onChanged { value in
                                            isResizingProjects = true
                                            let newWidth = projectsPanelWidth + value.translation.width
                                            
                                            if newWidth < collapseThreshold {
                                                withAnimation(.easeInOut(duration: 0.2)) {
                                                    appState.updateUI(["projectsCollapsed": true])
                                                }
                                            } else if newWidth >= minPanelWidth {
                                                projectsPanelWidth = min(newWidth, geometry.size.width * 0.5)
                                                appState.updateUI([
                                                    "projectsCollapsed": false,
                                                    "projectsPanelSize": Double(projectsPanelWidth / 10) // Convert to approximate percentage
                                                ])
                                            }
                                        }
                                        .onEnded { _ in
                                            isResizingProjects = false
                                        }
                                )
                                .onHover { hovering in
                                    if hovering {
                                        NSCursor.resizeLeftRight.set()
                                    } else {
                                        NSCursor.arrow.set()
                                    }
                                }
                                .animation(.easeInOut(duration: 0.1), value: isResizingProjects)
                        }
                    }
                    
                    // Chart Panel with Chat Overlay
                    if appState.state.ui.showChart {
                        ZStack {
                            // Chart Panel (background)
                            ChartView(selectedProjectId: appState.state.selectedProjectId)
                                .environmentObject(appState)
                                .frame(maxWidth: .infinity)
                                .background(Color.clear)
                            
                            // Chat Panel (transparent overlay)
                            if appState.state.ui.showChat {
                                HStack {
                                    Spacer()
                                    
                                    ChatView(selectedProjectId: appState.state.selectedProjectId)
                                        .environmentObject(appState)
                                        .frame(width: 400)
                                        .background(Color.black.opacity(0.75))
                                        .cornerRadius(12)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(Color.white.opacity(0.1), lineWidth: 1)
                                        )
                                        .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
                                        .padding(.trailing, 20)
                                        .padding(.vertical, 20)
                                }
                            }
                        }
                    }
                }
            }
        }
        .background(Color.clear)
        .preferredColorScheme(.dark)
        .ignoresSafeArea(.all, edges: .top)
        .onAppear {
            // Set initial panel width based on UI state
            projectsPanelWidth = appState.state.ui.projectsPanelSize * 10 // Convert percentage to pixels approximation
        }
        .onChange(of: appState.state.ui.projectsCollapsed) { _, collapsed in
            if !collapsed {
                // Restore panel width when uncollapsing
                projectsPanelWidth = max(minPanelWidth, appState.state.ui.projectsPanelSize * 10)
            }
        }
    }
    

}

#Preview {
    ContentView()
}
