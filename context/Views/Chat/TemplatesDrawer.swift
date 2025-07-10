import SwiftUI

struct TemplatesDrawer: View {
    @EnvironmentObject var appState: AppStateManager
    @Binding var isPresented: Bool
    let parentFrame: CGRect
    let namespace: Namespace.ID
    
    // Calculate height based on template content
    private var calculatedHeight: CGFloat {
        return min(400, max(200, CGFloat(10 * 50 + 80))) // Dynamic based on content
    }
    
    var body: some View {
        DrawerView(
            isPresented: $isPresented,
            parentFrame: parentFrame,
            contentHeight: calculatedHeight,
            expansionProgress: appState.state.ui.editingTemplateId != nil ? 1.0 : 0.0
        ) {
            TemplatesDrawerContent(
                isPresented: $isPresented,
                namespace: namespace,
                editingTemplateId: Binding(
                    get: { appState.state.ui.editingTemplateId },
                    set: { appState.setEditingTemplateId($0) }
                )
            )
        }
    }
}

struct TemplatesDrawerContent: View {
    @Binding var isPresented: Bool
    let namespace: Namespace.ID
    @Binding var editingTemplateId: String?
    @State private var hoveredTemplate: String?
    
    var body: some View {
        VStack(spacing: 0) {
            // Scrollable template list
            ScrollView {
                LazyVStack(spacing: 0) {
                    // Create new template row
                    createNewTemplateRow()
                    
                    ForEach(sampleTemplates, id: \.id) { template in
                        TemplateDrawerRowView(
                            template: template,
                            namespace: namespace,
                            hoveredTemplate: $hoveredTemplate,
                            isPresented: $isPresented,
                            editingTemplateId: $editingTemplateId
                        )
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)  // Reduced from 16 to 12
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func createNewTemplateRow() -> some View {
        Button(action: {
            // Handle create new template
            print("Create new template")
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                isPresented = false
            }
        }, label: {
            HStack {
                Image(systemName: "plus")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(AppColors.Semantic.textPrimary)
                
                VStack(alignment: .leading, spacing: 2) {  // Reduced from 4 to 2
                    Text("Create a new template")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(AppColors.Semantic.textPrimary)
                        .multilineTextAlignment(.leading)
                    
                    Text("Build a custom template for your workflows")
                        .font(.system(size: 12))
                        .foregroundColor(AppColors.Semantic.textSecondary)
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)
                }
                
                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.clear)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(AppColors.Component.borderPrimary, lineWidth: 1)
            )
        })
        .buttonStyle(.plain)
        .frame(height: 50)
    }
}

// MARK: - Drawer-Specific Template Row Component

struct TemplateDrawerRowView: View {
    let template: TemplateItem
    let namespace: Namespace.ID
    @Binding var hoveredTemplate: String?
    @Binding var isPresented: Bool
    @Binding var editingTemplateId: String?
    
    var body: some View {
        GeometryReader { geometry in
            Button(action: {
                // Handle template selection
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    isPresented = false
                }
            }, label: {
                HStack {
                    Text(template.icon)
                        .font(.system(size: 16))
                    
                    VStack(alignment: .leading, spacing: 2) {  // Reduced from 4 to 2
                        Text(template.title)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(AppColors.Semantic.textPrimary)
                            .multilineTextAlignment(.leading)
                        
                        Text(template.description)
                            .font(.system(size: 12))
                            .foregroundColor(AppColors.Semantic.textSecondary)
                            .multilineTextAlignment(.leading)
                            .lineLimit(2)
                    }
                    
                    Spacer()
                    
                    if hoveredTemplate == template.id {
                        Button(action: {
                            // Toggle edit mode for this template
                            if editingTemplateId == template.id {
                                editingTemplateId = nil
                            } else {
                                editingTemplateId = template.id
                            }
                        }) {
                            Image(systemName: "pencil")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.white)
                        }
                        .buttonStyle(.plain)
                        .transition(.scale.combined(with: .opacity))
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
            })
            .buttonStyle(.plain)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.clear)
                    .matchedGeometryEffect(
                        id: "\(template.id)-background", 
                        in: namespace, 
                        anchor: .center, 
                        isSource: true
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(AppColors.Component.borderPrimary, lineWidth: 1)
            )
            .animation(.easeInOut(duration: 0.2), value: hoveredTemplate == template.id)
            .onHover { isHovered in
                withAnimation(.easeInOut(duration: 0.2)) {
                    hoveredTemplate = isHovered ? template.id : nil
                }
            }
        }
        .frame(height: 50) // Fixed height for consistent layout
    }
}

// MARK: - Frame Tracking Infrastructure (Simplified)

// Note: The frame tracking infrastructure is now simplified since we're using GeometryReader directly
// in the TemplateDrawerRowView to capture frames when the edit button is pressed.

struct TemplateRowFramePreferenceKey: PreferenceKey {
    static var defaultValue: [String: CGRect] = [:]
    
    static func reduce(value: inout [String: CGRect], nextValue: () -> [String: CGRect]) {
        value.merge(nextValue()) { _, new in new }
    }
}

class TemplateRowFrameStore: ObservableObject {
    static let shared = TemplateRowFrameStore()
    
    private var frames: [String: CGRect] = [:]
    
    func setFrame(for templateId: String, frame: CGRect) {
        frames[templateId] = frame
    }
    
    func getFrame(for templateId: String) -> CGRect {
        return frames[templateId] ?? .zero
    }
} 