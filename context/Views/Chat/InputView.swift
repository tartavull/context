import SwiftUI
import AppKit

struct InputView: View {
    @EnvironmentObject var appState: AppStateManager
    @Binding var inputText: String
    @Binding var isLoading: Bool
    @Binding var selectedModel: String
    @Binding var showModelDropdown: Bool
    let models: [(String, String)]
    let namespace: Namespace.ID
    let onSubmit: () -> Void

    @State private var textHeight: CGFloat = 48
    @FocusState private var isTextFieldFocused: Bool

    var body: some View {
        inputFieldView
            .onAppear {
                isTextFieldFocused = true
            }
            .background(
                GeometryReader { geometry in
                    Color.clear
                        .onAppear {
                            appState.setInputViewFrame(geometry.frame(in: .global))
                        }
                        .onChange(of: geometry.frame(in: .global)) { _, newFrame in
                            appState.setInputViewFrame(newFrame)
                        }
                }
            )
    }

    private var inputFieldView: some View {
        HStack(alignment: .center, spacing: 12) {
            // Left side - vertical stack with text input and buttons
            VStack(spacing: 2) {
                // Text input area
                TextField("", text: $inputText, axis: .vertical)
                    .textFieldStyle(PlainTextFieldStyle())
                    .font(.system(size: 14))
                    .foregroundColor(.white)
                    .tint(.white)
                    .lineLimit(1...10)
                    .frame(minHeight: 48)
                    .frame(height: textHeight)
                    .focused($isTextFieldFocused)
                    .onKeyPress { keyPress in
                        if keyPress.key == .return {
                            if keyPress.modifiers.contains(.shift) {
                                // Shift+Enter: add new line
                                inputText += "\n"
                                updateTextHeight(for: inputText)
                                return .handled
                            } else {
                                // Enter: submit if not empty
                                if !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                    onSubmit()
                                }
                                return .handled
                            }
                        }
                        return .ignored
                    }
                    .onChange(of: inputText) { _, newValue in
                        updateTextHeight(for: newValue)
                    }
                    .disabled(isLoading)
                
                // Bottom buttons horizontal stack
                HStack(alignment: .bottom) {
                    // Model selector
                    modelSelectorView
                        .frame(height: 24)

                    // Image button
                    Button(action: {
                        appState.toggleDrawer(.images)
                    }, label: {
                        Image(systemName: "paperclip")
                            .font(.system(size: 11))
                            .foregroundColor(.gray)
                            .frame(width: 24, height: 24)
                    })
                    .buttonStyle(PlainButtonStyle())
                    .help("Attach File")

                    // Template button
                    Button(action: {
                        appState.toggleDrawer(.templates)
                    }, label: {
                        Text("{ }")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.gray)
                            .frame(width: 24, height: 24)
                            .baselineOffset(2)
                            .multilineTextAlignment(.center)
                    })
                    .buttonStyle(PlainButtonStyle())
                    .help("Open Templates")

                    Spacer()
                }
            }
            
            // Right side - send button (centered vertically)
            Button(action: {
                if !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    onSubmit()
                }
            }, label: {
                Image(systemName: "arrow.up")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.white)
                    .frame(width: 24, height: 24)
                    .background(
                        Circle()
                            .fill(Color.white.opacity(0.1))
                    )
            })
            .buttonStyle(PlainButtonStyle())
            .disabled(inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        .floatingBlur(cornerRadius: 16)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(AppColors.Component.borderPrimary, lineWidth: 1)
        )
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
    }

    private func updateTextHeight(for text: String) {
        // Calculate height based on text content
        let font = NSFont.systemFont(ofSize: 14)
        let size = CGSize(
            width: 300,
            height: CGFloat.greatestFiniteMagnitude
        ) // Approximate width
        let boundingRect = text.boundingRect(
            with: size,
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            attributes: [.font: font],
            context: nil
        )

        let newHeight = max(48, min(128, boundingRect.height + 28)) // Add padding
        textHeight = newHeight
    }

    // MARK: - Model Selector
    private var modelSelectorView: some View {
        Button(action: {
            appState.toggleDrawer(.models)
        }, label: {
            HStack(alignment: .center, spacing: 2) {
                Text(selectedModel)
                    .font(.system(size: 10))
                    .foregroundColor(.white)
                    .baselineOffset(0)

                if let tier = models.first(where: { $0.0 == selectedModel })?.1 {
                    Text(tier)
                        .font(.system(size: 8))
                        .foregroundColor(.gray)
                        .baselineOffset(0)
                }

                Image(systemName: "chevron.down")
                    .font(.system(size: 6))
                    .foregroundColor(.gray)
                    .rotationEffect(.degrees(appState.state.ui.modelsDrawerOpen ? 180 : 0))
            }
            .padding(.horizontal, 6)
            .padding(.vertical, 4)
            .frame(minHeight: 24)
            .background(Color.clear)
            .clipShape(RoundedRectangle(cornerRadius: 4))
            .contentShape(Rectangle())
        })
        .buttonStyle(PlainButtonStyle())
    }
}
