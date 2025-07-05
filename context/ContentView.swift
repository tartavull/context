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
    @State private var chatInputHandler: InputHandler?
    
    private let minPanelWidth: CGFloat = 200
    private let defaultPanelWidth: CGFloat = 300
    
    // Fixed chat container width
    private var chatContainerWidth: CGFloat {
        return 400
    }
    
    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 0) {
                // Projects Panel - conditionally shown
                if appState.state.ui.showProjects {
                    ProjectsView(isCollapsed: false)
                        .environmentObject(appState)
                        .frame(width: projectsPanelWidth)
                        .background(Color.clear)
                }
                
                // Main Content Area
                chartPanelWithOverlays(geometry: geometry)
                    .frame(maxWidth: .infinity)
            }
            .background(Color.clear)
            .overlay(floatingChatInput)
            .overlay(resizeHandleOverlay(geometry: geometry), alignment: .leading)
            .preferredColorScheme(.dark)
            .overlay(panelToggleButton, alignment: .topLeading)
        }
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
            
            // Initialize chat input handler
            chatInputHandler = InputHandler(appState: appState)
        }
    }
    
    // MARK: - Main Content View (now unused - keeping for reference)
    private var mainContentView: some View {
        VStack(spacing: 0) {
            GeometryReader { geometry in
                HStack(spacing: 0) {
                    // Add spacer for project panel width when it's visible
                    if appState.state.ui.showProjects {
                        Spacer()
                            .frame(width: projectsPanelWidth)
                    }
                    chartPanelWithOverlays(geometry: geometry)
                }
            }
        }
    }
    
    // MARK: - Projects Panel Overlay (now unused - keeping for reference)
    private var projectsPanelOverlay: some View {
        Group {
            if appState.state.ui.showProjects {
                HStack {
                    ProjectsView(isCollapsed: false)
                        .environmentObject(appState)
                        .frame(width: projectsPanelWidth)
                        .background(Color.clear)
                    Spacer()
                }
            }
        }
    }
    
    // MARK: - Chart Panel with Overlays
    private func chartPanelWithOverlays(geometry: GeometryProxy) -> some View {
        Group {
            if appState.state.ui.showChart {
                ZStack {
                    treeContainer
                    chatMessagesOverlay
                }
            }
        }
    }
    
    // MARK: - Tree Container
    private var treeContainer: some View {
        TreeContainer(selectedProjectId: appState.state.selectedProjectId)
            .environmentObject(appState)
            .frame(maxWidth: .infinity)
            .background(Color.clear)
    }
    
    // MARK: - Resize Handle Overlay
    private func resizeHandleOverlay(geometry: GeometryProxy) -> some View {
        Group {
            if appState.state.ui.showProjects {
                VStack(spacing: 0) {
                    HStack {
                        Spacer()
                            .frame(width: projectsPanelWidth - 4) // Position at the edge of the panel
                        resizeHandleRectangle(geometry: geometry)
                        Spacer()
                    }
                    Spacer()
                }
            }
        }
    }
    
    // MARK: - Resize Handle Rectangle
    private func resizeHandleRectangle(geometry: GeometryProxy) -> some View {
        Rectangle()
            .fill(Color.clear)
            .frame(width: 8, height: geometry.size.height)
            .contentShape(Rectangle())
            .gesture(resizeGesture(geometry: geometry))
            .onHover { hovering in
                if hovering {
                    NSCursor.resizeLeftRight.set()
                } else {
                    NSCursor.arrow.set()
                }
            }
            .accessibilityElement()
            .accessibilityIdentifier("projects-panel-resize-handle")
            .accessibilityLabel("Projects Panel Resize Handle")
    }
    
    // MARK: - Resize Gesture
    private func resizeGesture(geometry: GeometryProxy) -> some Gesture {
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
                    
                    // Direct update - no animation needed with proper layout structure
                    projectsPanelWidth = constrainedWidth
                    appState.updateUI(["projectsPanelSize": Double(constrainedWidth / 10)])
                }
            }
    }
    
    // MARK: - Chat Messages Overlay
    private var chatMessagesOverlay: some View {
        Group {
            if appState.state.ui.showChat {
                HStack {
                    Spacer()
                    
                    MessagesView(selectedProjectId: appState.state.selectedProjectId)
                        .environmentObject(appState)
                        .frame(width: chatContainerWidth)
                        .fixedSize(horizontal: false, vertical: true)
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
    
    // MARK: - Floating Chat Input
    private var floatingChatInput: some View {
        Group {
            if appState.state.ui.showChat {
                VStack {
                    Spacer()
                    
                    HStack {
                        Spacer()
                        
                        Group {
                            if let handler = chatInputHandler {
                                InputView(
                                    inputText: Binding(
                                        get: { handler.inputText },
                                        set: { handler.inputText = $0 }
                                    ),
                                    isLoading: Binding(
                                        get: { handler.isLoading },
                                        set: { handler.isLoading = $0 }
                                    ),
                                    selectedModel: Binding(
                                        get: { handler.selectedModel },
                                        set: { handler.selectedModel = $0 }
                                    ),
                                    showModelDropdown: Binding(
                                        get: { handler.showModelDropdown },
                                        set: { handler.showModelDropdown = $0 }
                                    ),
                                    models: handler.models
                                ) {
                                    handler.handleSubmit()
                                }
                            }
                        }
                        .frame(width: 650)
                        
                        Spacer()
                    }
                    .padding(.bottom, 20)
                }
            }
        }
    }
    
    // MARK: - Panel Toggle Button
    private var panelToggleButton: some View {
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
    }
}

#Preview {
    ContentView()
}


