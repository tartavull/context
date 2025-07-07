import SwiftUI

enum DrawerType {
    case templates
    case images
    case models
}

// Custom shape with rounded top corners only
struct TopRoundedRectangle: Shape {
    let cornerRadius: CGFloat
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        // Start from bottom left
        path.move(to: CGPoint(x: rect.minX, y: rect.maxY))
        
        // Left side up to top-left corner
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + cornerRadius))
        
        // Top-left corner
        path.addArc(
            center: CGPoint(x: rect.minX + cornerRadius, y: rect.minY + cornerRadius),
            radius: cornerRadius,
            startAngle: Angle(degrees: 180),
            endAngle: Angle(degrees: 270),
            clockwise: false
        )
        
        // Top side
        path.addLine(to: CGPoint(x: rect.maxX - cornerRadius, y: rect.minY))
        
        // Top-right corner
        path.addArc(
            center: CGPoint(x: rect.maxX - cornerRadius, y: rect.minY + cornerRadius),
            radius: cornerRadius,
            startAngle: Angle(degrees: 270),
            endAngle: Angle(degrees: 0),
            clockwise: false
        )
        
        // Right side down to bottom-right corner
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        
        // Bottom side (straight)
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        
        path.closeSubpath()
        return path
    }
}

struct DrawerView<Content: View>: View {
    @Binding var isPresented: Bool
    let parentFrame: CGRect
    let contentHeight: CGFloat
    let content: Content
    
    @State private var animationProgress: CGFloat = 0
    @State private var isAnimating: Bool = false
    
    init(
        isPresented: Binding<Bool>,
        parentFrame: CGRect,
        contentHeight: CGFloat,
        @ViewBuilder content: () -> Content
    ) {
        self._isPresented = isPresented
        self.parentFrame = parentFrame
        self.contentHeight = contentHeight
        self.content = content()
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Drawer content
            content
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(
                    FloatingBlur(cornerRadius: 16)
                        .allowsHitTesting(false) // Ensure blur doesn't block interactions
                )
                .clipShape(TopRoundedRectangle(cornerRadius: 16))
                .overlay(
                    TopRoundedRectangle(cornerRadius: 16)
                        .stroke(AppColors.Component.borderPrimary, lineWidth: 1)
                        .allowsHitTesting(false) // Ensure stroke doesn't block interactions
                )
        }
        .frame(
            width: max(0, parentFrame.width - 60),
            height: contentHeight * animationProgress
        )
        .clipped()
        .onAppear {
            if isPresented {
                withAnimation(.easeInOut(duration: 0.3)) {
                    animationProgress = 1.0
                }
            }
        }
        .onChange(of: isPresented) { _, newValue in
            withAnimation(.easeInOut(duration: 0.3)) {
                animationProgress = newValue ? 1.0 : 0.0
            }
        }
    }
}