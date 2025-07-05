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
    @State private var toggleButtonShine: Bool = false
    @State private var toggleButtonHovered: Bool = false
    
    private let minPanelWidth: CGFloat = 200
    private let defaultPanelWidth: CGFloat = 300
    
    var body: some View {
        // Main content area - remove the VStack wrapper
        GeometryReader { geometry in
            HStack(spacing: 0) {
                // Projects Panel
                if appState.state.ui.showProjects {
                    ProjectsView(isCollapsed: false)
                        .environmentObject(appState)
                        .frame(width: projectsPanelWidth)
                        .background(Color.clear)
                    
                    // Resize handle for projects panel
                    if appState.state.ui.showProjects && appState.state.ui.showChart {
                        ZStack {
                            // Gray background area (5 pixels wide)
                            Rectangle()
                                .fill(Color(hex: "#1b1b1b"))
                                .frame(width: 5)
                                .contentShape(Rectangle())
                            
                            // Black line (2 pixels thick, positioned to the left)
                            Rectangle()
                                .fill(Color.black)
                                .frame(width: 2)
                                .offset(x: -1.5) // Move 1.5 pixels to the left
                        }
                        .ignoresSafeArea(.all, edges: .top)
                        .accessibilityElement()
                        .accessibilityIdentifier("projects-panel-resize-handle")
                        .accessibilityLabel("Projects Panel Resize Handle")
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    let newWidth = projectsPanelWidth + value.translation.width
                                    
                                    if newWidth < minPanelWidth {
                                        if appState.state.ui.showProjects {
                                            // Trigger shine animation for auto-close
                                            toggleButtonShine = true
                                            withAnimation(.easeInOut(duration: 0.3)) {
                                                appState.updateUI(["showProjects": false])
                                            }
                                            // Reset shine after animation completes
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                                                toggleButtonShine = false
                                            }
                                        }
                                    } else {
                                        let constrainedWidth = min(newWidth, geometry.size.width * 0.5)
                                        projectsPanelWidth = constrainedWidth
                                        appState.updateUI(["projectsPanelSize": Double(constrainedWidth / 10)])
                                    }
                                }
                        )
                        .onHover { hovering in
                            if hovering {
                                NSCursor.resizeLeftRight.set()
                            } else {
                                NSCursor.arrow.set()
                            }
                        }
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
                                    .background(Color.clear)
                                    .cornerRadius(12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.clear, lineWidth: 1)
                                    )
                                    .shadow(color: .clear, radius: 8, x: 0, y: 4)
                                    .padding(.trailing, 20)
                                    .padding(.vertical, 20)
                            }
                        }
                    }
                }
            }
        }
        .background(Color.clear)
        .preferredColorScheme(.dark)
        .overlay(
            Group {
                // Panel toggle button - always visible (positioned in title bar)
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        if appState.state.ui.showProjects {
                            appState.updateUI(["showProjects": false])
                        } else {
                            appState.updateUI(["showProjects": true])
                            projectsPanelWidth = defaultPanelWidth
                        }
                    }
                }, label: {
                    Image(systemName: "sidebar.leading")
                        .font(.system(size: 18, weight: .light))
                        .foregroundColor(
                            toggleButtonShine ? .white :
                            (toggleButtonHovered ? Color(red: 180/255, green: 180/255, blue: 180/255) : 
                             Color(red: 135/255, green: 135/255, blue: 135/255))
                        )
                        .frame(width: 32, height: 24)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(toggleButtonHovered ? Color.white.opacity(0.1) : Color.clear)
                        )
                        .animation(.easeInOut(duration: 0.3).repeatCount(1, autoreverses: true), value: toggleButtonShine)
                        .animation(.easeInOut(duration: 0.15), value: toggleButtonHovered)
                })
                .buttonStyle(PlainButtonStyle())
                .onHover { hovering in
                    toggleButtonHovered = hovering
                }
                .position(x: 90, y: -19)
                .zIndex(1000)
                .help(appState.state.ui.showProjects ? "Hide Projects Panel" : "Show Projects Panel")
                .accessibilityIdentifier("projects-panel-toggle-button")
                .accessibilityLabel("Toggle Projects Panel")
            },
            alignment: .topLeading
        )
        .toolbar {
            ToolbarItem(placement: .principal) {
                Spacer()
            }
        }
        .toolbarBackground(.clear, for: .windowToolbar)
        .toolbarColorScheme(.dark, for: .windowToolbar)
        .onAppear {
            // Set initial panel width based on UI state
            let calculatedWidth = appState.state.ui.projectsPanelSize * 10
            projectsPanelWidth = max(calculatedWidth, defaultPanelWidth)
        }
    }
}

#Preview {
    ContentView()
}


