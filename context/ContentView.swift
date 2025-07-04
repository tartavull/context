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
    @State private var chartPanelWidth: CGFloat = 500
    @State private var isResizingProjects = false
    @State private var isResizingChart = false
    
    private let minPanelWidth: CGFloat = 200
    private let collapsedPanelWidth: CGFloat = 60
    private let collapseThreshold: CGFloat = 120
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HeaderView()
                .environmentObject(appState)
            
            // Main content area
            GeometryReader { geometry in
                HStack(spacing: 0) {
                    // Projects Panel
                    if appState.state.ui.showProjects {
                        ProjectsView(isCollapsed: appState.state.ui.projectsCollapsed)
                            .environmentObject(appState)
                            .frame(width: appState.state.ui.projectsCollapsed ? collapsedPanelWidth : projectsPanelWidth)
                            .background(Color(hex: "#2d2d2d"))
                            .animation(.easeInOut(duration: 0.2), value: appState.state.ui.projectsCollapsed)
                        
                        // Resize handle for projects panel
                        if !appState.state.ui.projectsCollapsed && (appState.state.ui.showChart || appState.state.ui.showChat) {
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
                    
                    // Chart Panel
                    if appState.state.ui.showChart {
                        ChartView(selectedProjectId: appState.state.selectedProjectId)
                            .environmentObject(appState)
                            .frame(width: calculateChartWidth(geometry: geometry))
                            .background(Color(hex: "#2d2d2d"))
                        
                        // Resize handle for chart panel
                        if appState.state.ui.showChat {
                            Rectangle()
                                .fill(isResizingChart ? Color(hex: "#5a5a5a") : Color(hex: "#3d3d3d"))
                                .frame(width: 1)
                                .contentShape(Rectangle())
                                .gesture(
                                    DragGesture()
                                        .onChanged { value in
                                            isResizingChart = true
                                            chartPanelWidth = max(minPanelWidth, chartPanelWidth + value.translation.width)
                                        }
                                        .onEnded { _ in
                                            isResizingChart = false
                                        }
                                )
                                .onHover { hovering in
                                    if hovering {
                                        NSCursor.resizeLeftRight.set()
                                    } else {
                                        NSCursor.arrow.set()
                                    }
                                }
                                .animation(.easeInOut(duration: 0.1), value: isResizingChart)
                        }
                    }
                    
                    // Chat Panel
                    if appState.state.ui.showChat {
                        ChatView(selectedProjectId: appState.state.selectedProjectId)
                            .environmentObject(appState)
                            .frame(maxWidth: .infinity)
                            .background(Color(hex: "#1a1a1a"))
                    }
                }
            }
            
            // Footer
            FooterView()
        }
        .background(Color(hex: "#1e1e1e"))
        .preferredColorScheme(.dark)
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
    
    private func calculateChartWidth(geometry: GeometryProxy) -> CGFloat {
        let totalWidth = geometry.size.width
        let projectsWidth = appState.state.ui.showProjects ? 
            (appState.state.ui.projectsCollapsed ? collapsedPanelWidth : projectsPanelWidth) : 0
        let chatMinWidth: CGFloat = appState.state.ui.showChat ? 300 : 0
        
        let availableWidth = totalWidth - projectsWidth - chatMinWidth - 2 // 2px for resize handles
        
        if appState.state.ui.showChat {
            return max(minPanelWidth, min(chartPanelWidth, availableWidth))
        } else {
            return availableWidth
        }
    }
}

#Preview {
    ContentView()
}
