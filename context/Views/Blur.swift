import SwiftUI
import AppKit

// MARK: - Basic Blur View
struct BlurView: NSViewRepresentable {
    let material: NSVisualEffectView.Material
    let blendingMode: NSVisualEffectView.BlendingMode
    
    init(
        material: NSVisualEffectView.Material = .hudWindow,
        blendingMode: NSVisualEffectView.BlendingMode = .behindWindow
    ) {
        self.material = material
        self.blendingMode = blendingMode
    }
    
    func makeNSView(context: Context) -> NSVisualEffectView {
        let effectView = NSVisualEffectView()
        effectView.material = material
        effectView.blendingMode = blendingMode
        effectView.state = .active
        return effectView
    }
    
    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        nsView.material = material
        nsView.blendingMode = blendingMode
    }
}

// MARK: - Behind Window Blur (Blurs desktop/wallpaper behind window)
struct BehindWindowBlur: View {
    let cornerRadius: CGFloat
    
    init(cornerRadius: CGFloat = 0) {
        self.cornerRadius = cornerRadius
    }
    
    var body: some View {
        BlurView(material: .hudWindow, blendingMode: .behindWindow)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
    }
}

// MARK: - Floating Blur (For floating elements - blurs content within window)
struct FloatingBlur: View {
    let cornerRadius: CGFloat
    
    init(cornerRadius: CGFloat = 16) {
        self.cornerRadius = cornerRadius
    }
    
    var body: some View {
        BlurView(material: .hudWindow, blendingMode: .withinWindow)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
    }
}

// MARK: - Tinted Blur (Animated gradient with blur)
struct TintedBlur: View {
    let cornerRadius: CGFloat
    
    // Animation state
    @State private var gradientOffset: CGFloat = 0
    @State private var gradientAngle: CGFloat = 0
    @State private var gradientStops: [Gradient.Stop] = []
    @State private var animationTimer: Timer?
    
    init(cornerRadius: CGFloat = 8) {
        self.cornerRadius = cornerRadius
    }
    
    var body: some View {
        ZStack {
            // Animated gradient background with peaks
            LinearGradient(
                gradient: Gradient(stops: gradientStops),
                startPoint: UnitPoint(
                    x: gradientOffset - 0.5,
                    y: gradientAngle
                ),
                endPoint: UnitPoint(
                    x: gradientOffset + 0.5,
                    y: 1 - gradientAngle
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .onAppear {
                generateRandomGradient()
                startRandomAnimation()
            }
            .onDisappear {
                animationTimer?.invalidate()
            }
            
            // Blur overlay
            BlurView(material: .hudWindow, blendingMode: .withinWindow)
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
                .opacity(0.85)
        }
    }
    
    // MARK: - Animation Functions
    private func startRandomAnimation() {
        animateToRandomPosition()
        
        // Set up continuous random animations
        animationTimer = Timer.scheduledTimer(withTimeInterval: Double.random(in: 0.5...2.0), repeats: true) { _ in
            animateToRandomPosition()
        }
    }
    
    private func animateToRandomPosition() {
        let randomDuration = Double.random(in: 1.5...2.5)
        let randomOffset = CGFloat.random(in: -1.0...3.0)
        let randomAngle = CGFloat.random(in: -0.3...0.3)
        
        // Always generate a new gradient pattern
        generateRandomGradient()
        
        withAnimation(.easeInOut(duration: randomDuration)) {
            gradientOffset = randomOffset
            gradientAngle = randomAngle
        }
    }
    
    // MARK: - Gradient Generation
    private func generateRandomGradient() {
        var stops: [Gradient.Stop] = []
        
        // Always start and end with clear
        stops.append(.init(color: Color.clear, location: 0.0))
        
        // Generate single peak with random position and intensity
        let peakCenter = CGFloat.random(in: 0.2...0.8)
        let peakWidth = CGFloat.random(in: 0.1...0.3)
        let leadIntensity = CGFloat.random(in: 0.02...0.1)
        
        // Add leading edge
        let leadPosition = max(0.05, peakCenter - peakWidth)
        stops.append(.init(color: Color.red.opacity(leadIntensity), location: leadPosition))
        // Add peak
        let peakIntensity = CGFloat.random(in: 0.25...0.5)
        stops.append(.init(color: Color.red.opacity(peakIntensity), location: peakCenter))
        // Add trailing edge
        let trailPosition = min(0.95, peakCenter + peakWidth)
        stops.append(.init(color: Color.red.opacity(leadIntensity), location: trailPosition))

        // Always end with clear
        stops.append(.init(color: Color.clear, location: 1.0))
        
        gradientStops = stops
    }
}

// MARK: - Convenience Extensions
extension View {
    func behindWindowBlur(cornerRadius: CGFloat = 0) -> some View {
        self.background(
            BehindWindowBlur(cornerRadius: cornerRadius)
        )
    }
    
    func floatingBlur(cornerRadius: CGFloat = 16) -> some View {
        self.background(
            FloatingBlur(cornerRadius: cornerRadius)
        )
    }
    
    func tintedBlur(cornerRadius: CGFloat = 8) -> some View {
        self.background(
            TintedBlur(cornerRadius: cornerRadius)
        )
    }
} 