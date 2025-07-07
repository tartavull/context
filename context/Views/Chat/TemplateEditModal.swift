import SwiftUI

// MARK: - Template Modal Manager

// Shared state manager for template editing modal
class TemplateEditModalManager: ObservableObject {
    static let shared = TemplateEditModalManager()

    @Published var editingTemplate: TemplateItem?
    @Published var showEditModal: Bool = false
    @Published var isModalVisible: Bool = false
    @Published var sourceRowFrame: CGRect = .zero

    func startEditing(_ template: TemplateItem, sourceFrame: CGRect = .zero) {
        editingTemplate = template
        sourceRowFrame = sourceFrame

        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            showEditModal = true
            isModalVisible = true
        }
    }

    func cancelEditing() {
        // First trigger the contraction animation
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            showEditModal = false
        }

        // Then hide the modal after the animation completes
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { [self] in
            isModalVisible = false
            editingTemplate = nil
            sourceRowFrame = .zero
        }
    }

    func saveTemplate(title: String, description: String, content: String) {
        print("Saving template: \(title)")
        // Handle save logic here

        // First trigger the contraction animation
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            showEditModal = false
        }

        // Then hide the modal after the animation completes
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { [self] in
            isModalVisible = false
            editingTemplate = nil
            sourceRowFrame = .zero
        }
    }
}

// MARK: - Template Row Component

struct TemplateRowView: View {
    let template: TemplateItem
    let namespace: Namespace.ID
    @ObservedObject var modalManager: TemplateEditModalManager

    var body: some View {
        GeometryReader { geometry in
            HStack {
                Text(template.icon)
                    .font(.system(size: 16))
                    .matchedGeometryEffect(
                        id: "\(template.id)-icon", 
                        in: namespace, 
                        anchor: .center, 
                        isSource: true
                    )

                VStack(alignment: .leading, spacing: 2) {
                    Text(template.title)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.leading)
                        .lineLimit(1)
                        .matchedGeometryEffect(
                            id: "\(template.id)-title", 
                            in: namespace, 
                            anchor: .center, 
                            isSource: true
                        )

                    Text(template.description)
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)
                        .matchedGeometryEffect(
                            id: "\(template.id)-description", 
                            in: namespace, 
                            anchor: .center, 
                            isSource: true
                        )
                }

                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(AppColors.Component.surfacePrimary)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(AppColors.Component.borderPrimary, lineWidth: 1)
            )
            .matchedGeometryEffect(
                id: "\(template.id)-background", 
                in: namespace, 
                anchor: .center, 
                isSource: true
            )
            .onTapGesture {
                // Capture the global frame of this row
                let globalFrame = geometry.frame(in: .global)
                modalManager.startEditing(template, sourceFrame: globalFrame)
            }
        }
        .frame(height: 60) // Fixed height for consistent layout
    }
}

// MARK: - Hero Animated Modal

// Hero animated modal for editing templates
struct TemplateEditModalHero: View {
    let template: TemplateItem
    @Binding var editingTemplate: TemplateItem?
    @Binding var showEditModal: Bool
    let namespace: Namespace.ID
    let sourceRowFrame: CGRect
    let modalWidth: CGFloat
    @State private var isExpanded: Bool = false
    @State private var editableTitle: String = ""
    @State private var editableDescription: String = ""
    @State private var editableContent: String = ""
    let onSave: (String, String, String) -> Void
    let onCancel: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text(template.icon)
                    .font(.system(size: isExpanded ? 24 : 16))
                    .matchedGeometryEffect(
                        id: "\(template.id)-icon", 
                        in: namespace, 
                        anchor: .center, 
                        isSource: false
                    )
                    .animation(.spring(response: 0.6, dampingFraction: 0.8), value: isExpanded)

                VStack(alignment: .leading, spacing: isExpanded ? 8 : 2) {
                    Text(template.title)
                        .font(.system(size: isExpanded ? 18 : 14, weight: .medium))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.leading)
                        .lineLimit(isExpanded ? nil : 1)
                        .matchedGeometryEffect(
                            id: "\(template.id)-title", 
                            in: namespace, 
                            anchor: .center, 
                            isSource: false
                        )

                    Text(template.description)
                        .font(.system(size: isExpanded ? 14 : 12))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.leading)
                        .lineLimit(isExpanded ? nil : 2)
                        .matchedGeometryEffect(
                            id: "\(template.id)-description", 
                            in: namespace, 
                            anchor: .center, 
                            isSource: false
                        )
                }

                Spacer()

                // Close button (only show when expanded)
                if isExpanded {
                    Button(action: onCancel) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                            .frame(width: 16, height: 16)
                            .padding(10)
                            .background(Color.red.opacity(0.8))
                            .clipShape(Circle())
                    }
                    .buttonStyle(.plain)
                    .transition(
                        .asymmetric(
                            insertion: .scale.combined(with: .opacity), 
                            removal: .scale.combined(with: .opacity)
                        )
                    )
                }
            }
            .padding(.horizontal, isExpanded ? 24 : 12)
            .padding(.vertical, isExpanded ? 20 : 8)

            // Additional content area that only appears when expanded
            if isExpanded {
                VStack(spacing: 16) {
                    Divider()
                        .background(Color.gray.opacity(0.3))

                    ScrollView {
                        VStack(alignment: .leading, spacing: 20) {
                            // Template title editing
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Template Title")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.white)

                                TextField("Enter template title", text: $editableTitle)
                                    .textFieldStyle(.plain)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(AppColors.Component.surfaceSecondary)
                                    .clipShape(RoundedRectangle(cornerRadius: 6))
                                    .foregroundColor(.white)
                            }

                            // Template description editing
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Description")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.white)

                                TextField(
                                    "Enter template description", 
                                    text: $editableDescription, 
                                    axis: .vertical
                                )
                                    .textFieldStyle(.plain)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(AppColors.Component.surfaceSecondary)
                                    .clipShape(RoundedRectangle(cornerRadius: 6))
                                    .foregroundColor(.white)
                                    .lineLimit(3...6)
                            }

                            // Template content editing
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Template Content")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.white)

                                TextField(
                                    "Enter template content...", 
                                    text: $editableContent, 
                                    axis: .vertical
                                )
                                    .textFieldStyle(.plain)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(AppColors.Component.surfaceSecondary)
                                    .clipShape(RoundedRectangle(cornerRadius: 6))
                                    .foregroundColor(.white)
                                    .lineLimit(8...15)
                            }

                            // Action buttons
                            HStack(spacing: 12) {
                                Button("Cancel") {
                                    onCancel()
                                }
                                .buttonStyle(.plain)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(AppColors.Component.surfaceSecondary)
                                .clipShape(RoundedRectangle(cornerRadius: 6))
                                .foregroundColor(.gray)

                                Spacer()

                                Button("Save Template") {
                                    onSave(editableTitle, editableDescription, editableContent)
                                }
                                .buttonStyle(.plain)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(AppColors.Semantic.info)
                                .clipShape(RoundedRectangle(cornerRadius: 6))
                                .foregroundColor(.white)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 20)
                }
                .transition(
                    .asymmetric(
                        insertion: .move(edge: .top).combined(with: .opacity), 
                        removal: .move(edge: .top).combined(with: .opacity)
                    )
                )
            }
        }
        .background(AppColors.Component.surfacePrimary)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(AppColors.Component.borderPrimary, lineWidth: 1)
        )
        .shadow(
            color: .black.opacity(isExpanded ? 0.3 : 0.0), 
            radius: isExpanded ? 20 : 0, 
            x: 0, 
            y: isExpanded ? 10 : 0
        )
        .frame(
            width: isExpanded ? modalWidth : sourceRowFrame.width,
            height: isExpanded ? nil : sourceRowFrame.height
        )
        .matchedGeometryEffect(
            id: "\(template.id)-background", 
            in: namespace, 
            anchor: .center, 
            isSource: false
        )
        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: isExpanded)
        .onAppear {
            // Initialize editable fields
            editableTitle = template.title
            editableDescription = template.description
            editableContent = template.content ?? ""

            // Trigger expansion after a brief delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    isExpanded = true
                }
            }
        }
        .onChange(of: showEditModal) { _, _ in
            // When modal is being dismissed, contract back to original size
            if !showEditModal && isExpanded {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    isExpanded = false
                }
            }
        }
    }
}

// MARK: - Helper Extensions

// Helper extension for conditional view modifiers
extension View {
    @ViewBuilder func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

// MARK: - Modal Overlay

// Global modal overlay that can be placed at the root level
struct TemplateEditModalOverlay: View {
    @ObservedObject var modalManager: TemplateEditModalManager
    let namespace: Namespace.ID

    // Calculate modal width (wider than source row)
    private var modalWidth: CGFloat {
        let sourceFrame = modalManager.sourceRowFrame
        return max(sourceFrame.width + 200, 400)  // At least 400px wide
    }

    // Calculate the source center point
    private var sourceCenter: CGPoint {
        let frame = modalManager.sourceRowFrame
        return CGPoint(
            x: frame.midX,
            y: frame.midY
        )
    }

    var body: some View {
        GeometryReader { _ in
            ZStack {
                if modalManager.isModalVisible, let template = modalManager.editingTemplate {
                    // Background overlay
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                        .onTapGesture {
                            modalManager.cancelEditing()
                        }

                    // Modal with hero animation
                    TemplateEditModalHero(
                        template: template,
                        editingTemplate: $modalManager.editingTemplate,
                        showEditModal: $modalManager.showEditModal,
                        namespace: namespace,
                        sourceRowFrame: modalManager.sourceRowFrame,
                        modalWidth: modalWidth,
                        onSave: { title, description, content in
                            modalManager.saveTemplate(title: title, description: description, content: content)
                        },
                        onCancel: {
                            modalManager.cancelEditing()
                        }
                    )
                }
            }
        }
        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: modalManager.isModalVisible)
    }
}
