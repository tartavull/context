import SwiftUI

// Custom shape that smoothly transitions from top-only rounded to fully rounded
struct AnimatedRoundedRectangle: Shape {
    let cornerRadius: CGFloat
    let progress: CGFloat // 0 = top-only rounded, 1 = fully rounded
    
    func path(in rect: CGRect) -> Path {
        let topRadius = cornerRadius
        let bottomRadius = cornerRadius * progress // Interpolate bottom radius
        
        var path = Path()
        
        // Start from bottom left, accounting for bottom radius
        if bottomRadius > 0 {
            path.move(to: CGPoint(x: rect.minX, y: rect.maxY - bottomRadius))
        } else {
            path.move(to: CGPoint(x: rect.minX, y: rect.maxY))
        }
        
        // Left side up to top-left corner
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + topRadius))
        
        // Top-left corner
        path.addArc(
            center: CGPoint(x: rect.minX + topRadius, y: rect.minY + topRadius),
            radius: topRadius,
            startAngle: Angle(degrees: 180),
            endAngle: Angle(degrees: 270),
            clockwise: false
        )
        
        // Top side
        path.addLine(to: CGPoint(x: rect.maxX - topRadius, y: rect.minY))
        
        // Top-right corner
        path.addArc(
            center: CGPoint(x: rect.maxX - topRadius, y: rect.minY + topRadius),
            radius: topRadius,
            startAngle: Angle(degrees: 270),
            endAngle: Angle(degrees: 0),
            clockwise: false
        )
        
        // Right side down to bottom-right corner
        if bottomRadius > 0 {
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - bottomRadius))
            
            // Bottom-right corner
            path.addArc(
                center: CGPoint(x: rect.maxX - bottomRadius, y: rect.maxY - bottomRadius),
                radius: bottomRadius,
                startAngle: Angle(degrees: 0),
                endAngle: Angle(degrees: 90),
                clockwise: false
            )
            
            // Bottom side
            path.addLine(to: CGPoint(x: rect.minX + bottomRadius, y: rect.maxY))
            
            // Bottom-left corner
            path.addArc(
                center: CGPoint(x: rect.minX + bottomRadius, y: rect.maxY - bottomRadius),
                radius: bottomRadius,
                startAngle: Angle(degrees: 90),
                endAngle: Angle(degrees: 180),
                clockwise: false
            )
        } else {
            // No bottom radius - straight bottom
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        }
        
        path.closeSubpath()
        return path
        }
}

struct DrawerView<Content: View>: View {
    @Binding var isPresented: Bool
    let parentFrame: CGRect
    let contentHeight: CGFloat
    let expansionProgress: CGFloat
    let content: Content

    @State private var openProgress: CGFloat = 0
    @State private var windowSize: CGSize = .zero
    @State private var windowFrameObserver: Any?


    // Calculate expanded dimensions based on window bounds with smooth interpolation
    private var expandedHeight: CGFloat {
        let normalHeight = contentHeight
        
        // Distances from window edges when expanded
        let expandedTopDistance: CGFloat = 50
        let expandedBottomDistance: CGFloat = 50
        // Use window size for calculation - fallback to reasonable defaults if not available
        let targetExpandedHeight = windowSize.height - expandedTopDistance - expandedBottomDistance
        let fullExpandedHeight = max(contentHeight, targetExpandedHeight)
        
        // Interpolate smoothly between normal and expanded height
        return normalHeight + (fullExpandedHeight - normalHeight) * expansionProgress
    }
    
    // Calculate expanded width - smoothly interpolate to 680px
    private var expandedWidth: CGFloat {
        let normalWidth = max(0, parentFrame.width - 60)
        let targetExpandedWidth: CGFloat = 680         
        // Interpolate smoothly between normal and expanded width
        return normalWidth + (targetExpandedWidth - normalWidth) * expansionProgress
    }
    
    // Shape that smoothly transitions from top-rounded to fully-rounded based on expansion
    private var drawerShape: some Shape {
        return AnimatedRoundedRectangle(cornerRadius: 16, progress: expansionProgress)
    }

    init(
        isPresented: Binding<Bool>,
        parentFrame: CGRect,
        contentHeight: CGFloat,
        expansionProgress: CGFloat = 0,
        @ViewBuilder content: () -> Content
    ) {
        self._isPresented = isPresented
        self.parentFrame = parentFrame
        self.contentHeight = contentHeight
        self.expansionProgress = expansionProgress
        self.content = content()
    }

    var body: some View {
        // Single view that smoothly transitions between normal and expanded states
        VStack(spacing: 0) {
            // Drawer content
            content
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(
                    FloatingBlur(cornerRadius: 16)
                        .allowsHitTesting(false) // Ensure blur doesn't block interactions
                )
                .clipShape(drawerShape)
                .overlay(
                    drawerShape
                        .stroke(AppColors.Component.borderPrimary, lineWidth: 1)
                        .allowsHitTesting(false) // Ensure stroke doesn't block interactions
                )
        }
        .frame(
            width: expandedWidth,
            height: expandedHeight * openProgress
        )
        .clipped()
        .background(
            // GeometryReader to track window frame changes
            GeometryReader { geometry in
                Color.clear
                    .onAppear {
                        updateWindowSize(geometry)
                        setupWindowObserver()
                    }
                    .onChange(of: geometry.size) { _, _ in
                        updateWindowSize(geometry)
                    }
                    .onChange(of: geometry.frame(in: .global)) { _, _ in
                        updateWindowSize(geometry)
                    }
            }
        )
        .onAppear {
            if isPresented {
                withAnimation(.easeInOut(duration: 0.3)) {
                    openProgress = 1.0
                }
            }
        }
        .onDisappear {
            removeWindowObserver()
        }
        .onChange(of: isPresented) { _, newValue in
            withAnimation(.easeInOut(duration: 0.3)) {
                openProgress = newValue ? 1.0 : 0.0
            }
        }

    }
    
    private func updateWindowSize(_ geometry: GeometryProxy) {
        // Try to get the actual window size from NSApplication
        if let window = NSApplication.shared.windows.first(where: { $0.isKeyWindow }) {
            let windowFrame = window.frame
            self.windowSize = CGSize(width: windowFrame.width, height: windowFrame.height)
        }
    }
    
    private func setupWindowObserver() {
        // Set up notification observer for window resize events
        windowFrameObserver = NotificationCenter.default.addObserver(
            forName: NSWindow.didResizeNotification,
            object: nil,
            queue: .main
        ) { notification in
            // Force update window size when window resizes
            if let window = notification.object as? NSWindow,
               window.isKeyWindow {
                DispatchQueue.main.async {
                    self.windowSize = CGSize(width: window.frame.width, height: window.frame.height)
                }
            }
        }
    }
    
    private func removeWindowObserver() {
        if let observer = windowFrameObserver {
            NotificationCenter.default.removeObserver(observer)
            windowFrameObserver = nil
        }
    }
}
