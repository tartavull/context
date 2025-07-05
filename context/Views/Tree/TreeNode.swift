import SwiftUI

struct TaskNodeView: View {
    let task: ProjectTask
    let isSelected: Bool
    let onSelect: () -> Void
    let onDelete: () -> Void
    
    @State private var showActions = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Content area - flexible height
            VStack(alignment: .leading, spacing: 4) {
                Text(task.title)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(Color(hex: "#ffffff"))
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                if !task.description.isEmpty {
                    Text(task.description)
                        .font(.system(size: 11))
                        .foregroundColor(Color(hex: "#a0a0a0"))
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .frame(maxWidth: .infinity, minHeight: 40, alignment: .leading)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
        .frame(width: 220, height: 140)
        .tintedBlur(cornerRadius: 8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(isSelected ? Color(hex: "#a0a0a0") : nodeTypeColor, lineWidth: 2)
        )
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
        .onTapGesture {
            onSelect()
        }
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.2)) {
                showActions = hovering
            }
        }
    }
    
    private var nodeTypeColor: Color {
        switch task.nodeType {
        case .clone:
            return Color(hex: "#a0a0a0") // light gray
        case .spawn:
            return Color(hex: "#707070") // medium gray  
        case .original:
            return Color(hex: "#606060") // accent gray
        }
    }
    
    private var statusColor: Color {
        switch task.status {
        case .completed:
            return Color(hex: "#a0a0a0") // light gray
        case .active:
            return Color(hex: "#ffffff") // white
        case .failed:
            return Color(hex: "#707070") // medium gray
        default:
            return Color(hex: "#4d4d4d") // border gray
        }
    }
} 