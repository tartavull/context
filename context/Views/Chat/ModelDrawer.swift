import SwiftUI

// MARK: - Model Drawer Component
struct ModelDrawer: View {
    @Binding var isPresented: Bool
    @Binding var selectedModel: String
    let parentFrame: CGRect
    let onModelSelect: (String) -> Void

    // Sample token usage for demonstration
    private let sampleInputTokens = 1500
    private let sampleOutputTokens = 800

    // Calculate height based on requirements:
    // 1. Never more than the number of models available
    // 2. If only one model, height should be one model plus padding
    // 3. Never show more than 3 rows of models
    private var calculatedHeight: CGFloat {
        let modelCount = AIModels.available.count
        let maxVisibleModels = min(modelCount, 3) // Never show more than 3 rows
        let modelRowHeight: CGFloat = 80 // Height per model row
        let padding: CGFloat = 60 // Top and bottom padding

        return CGFloat(maxVisibleModels) * modelRowHeight + padding
    }

    var body: some View {
        DrawerView(
            isPresented: $isPresented,
            parentFrame: parentFrame,
            contentHeight: calculatedHeight
        ) {
            ModelDrawerContent(
                isPresented: $isPresented,
                selectedModel: $selectedModel,
                sampleInputTokens: sampleInputTokens,
                sampleOutputTokens: sampleOutputTokens,
                onModelSelect: onModelSelect
            )
        }
    }
}

// MARK: - Model Drawer Content
struct ModelDrawerContent: View {
    @Binding var isPresented: Bool
    @Binding var selectedModel: String
    let sampleInputTokens: Int
    let sampleOutputTokens: Int
    let onModelSelect: (String) -> Void

    @State private var hoveredModel: String?
    @State private var isProcessingSelection = false

    var body: some View {
        VStack(spacing: 0) {
            // Model list
            ScrollView {
                LazyVStack(spacing: 4) {
                    ForEach(AIModels.available, id: \.name) { model in
                        modelRow(model)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func modelRow(_ model: AIModel) -> some View {
        Button(
            action: { handleModelSelection(model) },
            label: { modelRowContent(model) }
        )
        .buttonStyle(PlainButtonStyle())
        .disabled(isProcessingSelection)
        .background(modelRowBackground())
        .overlay(modelRowBorder(model))
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: hoveredModel == model.name)
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: selectedModel == model.name)
        .onHover { isHovered in
            withAnimation(.easeInOut(duration: 0.2)) {
                hoveredModel = isHovered ? model.name : nil
            }
        }
    }

    private func handleModelSelection(_ model: AIModel) {
        guard !isProcessingSelection else { return }
        isProcessingSelection = true

        selectedModel = model.name
        onModelSelect(model.name)

        // Reset processing flag after a brief delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            isProcessingSelection = false
        }
    }

    private func modelRowContent(_ model: AIModel) -> some View {
        VStack(spacing: 0) {
            HStack(alignment: .top, spacing: 12) {
                modelInfoSection(model)
                Spacer()
                modelCostSection(model)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
        }
    }

    private func modelInfoSection(_ model: AIModel) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(spacing: 8) {
                Text(model.name)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(AppColors.Semantic.textPrimary)

                modelTierBadge(model.tier)
            }

            Text(model.description)
                .font(.system(size: 11))
                .foregroundColor(AppColors.Semantic.textSecondary)
                .lineLimit(3)
                .multilineTextAlignment(.leading)
        }
    }

    private func modelTierBadge(_ tier: String) -> some View {
        Text(tier)
            .font(.system(size: 9, weight: .semibold))
            .foregroundColor(AppColors.Semantic.textSecondary)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(AppColors.Component.surfacePrimary)
            .clipShape(RoundedRectangle(cornerRadius: 4))
    }

    private func modelCostSection(_ model: AIModel) -> some View {
        VStack(alignment: .trailing, spacing: 2) {
            Text(model.formatCost(inputTokens: sampleInputTokens, outputTokens: sampleOutputTokens))
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(AppColors.Semantic.textPrimary)

            Text("\(formatTokenCount(sampleInputTokens + sampleOutputTokens)) tokens")
                .font(.system(size: 9))
                .foregroundColor(AppColors.Semantic.textSecondary)
        }
    }

    private func modelRowBackground() -> some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(Color.clear)
    }

    private func modelRowBorder(_ model: AIModel) -> some View {
        RoundedRectangle(cornerRadius: 8)
            .stroke(
                selectedModel == model.name 
                    ? AppColors.Component.borderSelected 
                    : AppColors.Component.borderPrimary,
                lineWidth: 1
            )
    }

    private func backgroundColorForModel(_ model: AIModel) -> Color {
        if selectedModel == model.name {
            return AppColors.Component.surfaceSelected
        } else if hoveredModel == model.name {
            return AppColors.Component.surfaceHover
        } else {
            return AppColors.Component.surfacePrimary
        }
    }

    private func formatTokenCount(_ count: Int) -> String {
        if count >= 1000 {
            return String(format: "%.1fK", Double(count) / 1000.0)
        }
        return "\(count)"
    }

}
