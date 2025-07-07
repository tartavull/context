import SwiftUI

struct TemplatesDrawer: View {
    @Binding var isPresented: Bool
    let parentFrame: CGRect
    let namespace: Namespace.ID
    @ObservedObject private var modalManager = TemplateEditModalManager.shared
    
    // Calculate height based on template content
    private var calculatedHeight: CGFloat {
        return min(400, max(200, CGFloat(10 * 50 + 80))) // Dynamic based on content
    }
    
    var body: some View {
        DrawerView(
            isPresented: $isPresented,
            parentFrame: parentFrame,
            contentHeight: calculatedHeight
        ) {
            TemplatesDrawerContent(
                isPresented: $isPresented,
                modalManager: modalManager,
                namespace: namespace
            )
        }
    }
}

struct TemplatesDrawerContent: View {
    @Binding var isPresented: Bool
    let modalManager: TemplateEditModalManager
    let namespace: Namespace.ID
    @State private var hoveredTemplate: String?
    
    var body: some View {
        VStack(spacing: 0) {
            // Scrollable template list
            ScrollView {
                LazyVStack(spacing: 4) {  // Reduced from 8 to 4
                    // Create new template row
                    createNewTemplateRow()
                    
                    ForEach(sampleTemplates, id: \.id) { template in
                        templateRow(template)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)  // Reduced from 16 to 12
            }
        }
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
            .padding(.vertical, 8)  // Reduced from 12 to 8
            .background(Color.clear)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(AppColors.Component.borderPrimary, lineWidth: 1)
            )
        })
        .buttonStyle(.plain)
    }
    
    private func templateRow(_ template: TemplateItem) -> some View {
        Button(action: {
            // Handle template selection
            print("Selected template: \(template.title)")
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
                        .matchedGeometryEffect(id: "\(template.id)-title", in: namespace, isSource: true)
                    
                    Text(template.description)
                        .font(.system(size: 12))
                        .foregroundColor(AppColors.Semantic.textSecondary)
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)
                        .matchedGeometryEffect(id: "\(template.id)-description", in: namespace, isSource: true)
                }
                
                Spacer()
                
                if hoveredTemplate == template.id {
                    Button(action: {
                        // Get the stored frame for this template row
                        let rowFrame = TemplateRowFrameStore.shared.getFrame(for: template.id)
                        modalManager.startEditing(template, sourceFrame: rowFrame)
                    }) {
                        Image(systemName: "pencil")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                    }
                    .buttonStyle(.plain)
                    .transition(.scale.combined(with: .opacity))
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)  // Reduced from 12 to 8
            .background(
                GeometryReader { geometry in
                    Color.clear
                        .preference(key: TemplateRowFramePreferenceKey.self, value: [template.id: geometry.frame(in: .global)])
                }
            )
            .background(Color.clear)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(AppColors.Component.borderPrimary, lineWidth: 1)
            )
            .matchedGeometryEffect(id: "\(template.id)-background", in: namespace, properties: .frame, anchor: .center, isSource: true)
            .animation(.easeInOut(duration: 0.2), value: hoveredTemplate == template.id)
        })
        .buttonStyle(.plain)
        .onHover { isHovered in
            withAnimation(.easeInOut(duration: 0.2)) {
                hoveredTemplate = isHovered ? template.id : nil
            }
        }
        .onPreferenceChange(TemplateRowFramePreferenceKey.self) { frames in
            // Store the frame for this template row
            if let frame = frames[template.id] {
                TemplateRowFrameStore.shared.setFrame(for: template.id, frame: frame)
            }
        }
    }
}

// MARK: - Frame Tracking Infrastructure

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