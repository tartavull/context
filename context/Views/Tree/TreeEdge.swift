import SwiftUI

struct TreeEdge: View {
    let from: ProjectTask.Position
    let to: ProjectTask.Position
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
