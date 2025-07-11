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
    @State private var drawerExpansionProgress: CGFloat = 0.0

    @Namespace private var geometryNamespace
    
    // Chat input states
    @State private var inputText = ""
    @State private var isLoading = false
    @State private var showModelDropdown = false
    @State private var inputViewHeight: CGFloat = 80 // Initial estimate
    
    private let models = AIModels.simpleList

    private let minPanelWidth: CGFloat = 200
    private let defaultPanelWidth: CGFloat = 300



    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 0) {
                // Projects panel (fixed position when visible)
                if appState.state.ui.showProjects {
                    ProjectsView(isCollapsed: false)
                        .environmentObject(appState)
                        .frame(width: projectsPanelWidth)
                        .background(Color.clear)
                }

                // Main content area (TreeView with overlays)
                ZStack {
                    // Tree container (fills remaining space) - always visible
                    treeContainer
                        
                    drawerOverlay
                    
                    floatingChatInput(geometry: geometry)
                }
                .frame(maxWidth: .infinity)
                .background(Color.clear)
            }
            .overlay(resizeHandleOverlay(geometry: geometry), alignment: .leading)
            .preferredColorScheme(.dark)
            .overlay(panelToggleButton, alignment: .topLeading)
        }
        .background(
            // Window background blur - prevents see-through during animations
            BlurView(material: .windowBackground, blendingMode: .behindWindow)
                .ignoresSafeArea(.all)
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
            
            // Set initial drawer expansion progress
            drawerExpansionProgress = appState.state.ui.editingTemplateId != nil ? 1.0 : 0.0
        }
        .onChange(of: appState.state.ui.editingTemplateId) { _, newValue in
            // Animate drawer expansion progress when editing state changes
            withAnimation(.easeInOut(duration: 0.6)) {
                drawerExpansionProgress = newValue != nil ? 1.0 : 0.0
            }
        }
    }

    // MARK: - Tree Container
    private var treeContainer: some View {
        TreeView(selectedProjectId: appState.state.selectedProjectId)
            .environmentObject(appState)
            .frame(maxWidth: .infinity)
            .background(Color.clear)
            .ignoresSafeArea(.all, edges: .top)
    }

    // MARK: - Resize Handle Overlay
    private func resizeHandleOverlay(geometry: GeometryProxy) -> some View {
        Group {
            if appState.state.ui.showProjects {
                HStack {
                    Spacer()
                        .frame(width: projectsPanelWidth - 4) // Position at the edge of the panel
                    resizeHandleRectangle(geometry: geometry)
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



    // MARK: - Floating Chat Input
    private func floatingChatInput(geometry: GeometryProxy) -> some View {
        InputView(
            inputText: $inputText,
            isLoading: $isLoading,
            selectedModel: Binding(
                get: { appState.state.ui.selectedModel },
                set: { _ in }
            ),
            showModelDropdown: $showModelDropdown,
            models: models,
            namespace: geometryNamespace,
            onSubmit: {
                handleSubmit()
            },
            onHeightChange: { height in
                inputViewHeight = height
            }
        )
        .environmentObject(appState)  // Pass the environment object
        .frame(width: 650)
        .position(
            x: geometry.size.width / 2,
            y: geometry.size.height - 72 -  (inputViewHeight / 2) 
        )
        .allowsHitTesting(true)
    }

    // MARK: - Drawer Overlay
    private var drawerOverlay: some View {
        GeometryReader { geometry in
            VStack(alignment: .center, spacing: 0) {
                // Top spacer - allows room for drawer expansion
                Spacer()
                
                // Single drawer instances that smoothly transition between normal and expanded states
                ZStack {
                    // Templates Drawer - single instance that handles both states
                    TemplatesDrawer(
                        isPresented: Binding(
                            get: { appState.state.ui.templatesDrawerOpen },
                            set: { _ in }
                        ),
                        parentFrame: isAnyDrawerExpanded ? 
                            CGRect(x: 0, y: 0, width: 750, height: geometry.size.height - 100) :
                            appState.state.ui.inputViewFrame,
                        namespace: geometryNamespace
                    )
                    .environmentObject(appState)
                    .allowsHitTesting(appState.state.ui.templatesDrawerOpen)

                    // File Drawer - single instance that handles both states
                    FileDrawer(
                        isPresented: Binding(
                            get: { appState.state.ui.imagesDrawerOpen },
                            set: { _ in }
                        ),
                        parentFrame: isAnyDrawerExpanded ?
                            CGRect(x: 0, y: 0, width: 750, height: geometry.size.height - 100) :
                            appState.state.ui.inputViewFrame
                    )
                    .allowsHitTesting(appState.state.ui.imagesDrawerOpen)

                    // Model Drawer - single instance that handles both states
                    ModelDrawer(
                        isPresented: Binding(
                            get: { appState.state.ui.modelsDrawerOpen },
                            set: { _ in }
                        ),
                        selectedModel: Binding(
                            get: { appState.state.ui.selectedModel },
                            set: { _ in }
                        ),
                        parentFrame: isAnyDrawerExpanded ?
                            CGRect(x: 0, y: 0, width: 750, height: geometry.size.height - 100) :
                            appState.state.ui.inputViewFrame,
                        onModelSelect: { model in
                            appState.setSelectedModel(model)
                        }
                    )
                    .allowsHitTesting(appState.state.ui.modelsDrawerOpen)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .allowsHitTesting(
                    appState.state.ui.templatesDrawerOpen || 
                    appState.state.ui.imagesDrawerOpen || 
                    appState.state.ui.modelsDrawerOpen
                )
                
                // Bottom spacer - fixes drawer bottom to input view top
                Spacer()
                    .frame(height: drawerBottomSpacing(for: geometry))
            }
        }
        .ignoresSafeArea()
    }
    
    // Helper to check if any drawer is in expanded state
    private var isAnyDrawerExpanded: Bool {
        // Check if any drawer is in expanded state (only when editing)
        return appState.state.ui.editingTemplateId != nil
    }
    
    // Helper to calculate drawer bottom spacing for VStack positioning
    private func drawerBottomSpacing(for geometry: GeometryProxy) -> CGFloat {
        let inputViewFrame = appState.state.ui.inputViewFrame
        
        // If we have a valid input view frame, calculate smooth transition
        if inputViewFrame != .zero {
            // Spacing when open (drawer bottom aligns with input top)
            let openStateSpacing = geometry.size.height - inputViewFrame.minY
            
            // Spacing when expanded (drawer has bottom margin)
            let expandedBottomMargin: CGFloat = 50
            let expandedStateSpacing = expandedBottomMargin
            
            // Smooth interpolation between open and expanded spacing using animated progress
            let interpolatedSpacing = openStateSpacing + (expandedStateSpacing - openStateSpacing) * drawerExpansionProgress
            
            // Ensure spacing is not negative
            return max(interpolatedSpacing, 0)
        } else {
            // Fallback spacing
            return 125 // Matches the input view position from bottom
        }
    }
    
    // MARK: - Chat Input Handler
    private func handleSubmit() {
        guard !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }

        let trimmedInput = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Clear input
        inputText = ""
        
        // TODO: Handle input submission
        print("Input submitted: \(trimmedInput)")
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
