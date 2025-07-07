import SwiftUI
import AppKit

struct InputView: View {
    @Binding var inputText: String
    @Binding var isLoading: Bool
    @Binding var selectedModel: String
    @Binding var showModelDropdown: Bool
    let models: [(String, String)]
    let namespace: Namespace.ID
    let onSubmit: () -> Void
    
    @State private var textHeight: CGFloat = 48
    @FocusState private var isTextFieldFocused: Bool
    @State private var showDrawer: Bool = false
    @State private var drawerType: DrawerType = .templates
    @State private var inputViewFrame: CGRect = .zero
    
    var body: some View {
        ZStack {
            // Main input content with geometry tracking
            VStack(spacing: 0) {
                // Drawer overlays - self-contained components
                if showDrawer && drawerType == .templates {
                    TemplatesDrawer(
                        isPresented: .constant(showDrawer && drawerType == .templates),
                        parentFrame: inputViewFrame,
                        namespace: namespace
                    )
                    .zIndex(2)  // Above input when shown
                }
                
                FileDrawer(
                    isPresented: .constant(showDrawer && drawerType == .images),
                    parentFrame: inputViewFrame
                )
                .zIndex(showDrawer && drawerType == .images ? 2 : -1)  // Above input when shown
                
                ModelDrawer(
                    isPresented: .constant(showDrawer && drawerType == .models),
                    selectedModel: $selectedModel,
                    parentFrame: inputViewFrame,
                    onModelSelect: { model in
                        selectedModel = model
                    }
                )
                .zIndex(showDrawer && drawerType == .models ? 2 : -1)  // Above input when shown
                
                // Main input area
                VStack(spacing: 0) {
                    // Main input area
                    HStack(alignment: .bottom, spacing: 0) {
                        // Text input container
                        VStack(spacing: 0) {
                            // Text input area
                            HStack(alignment: .bottom, spacing: 12) {
                                // Expandable text input
                                ZStack(alignment: .topLeading) {
                                    // Background
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color.clear)
                                        .frame(height: max(48, textHeight))
                                    
                                    // Text input
                                    TextField("Type your message here...", text: $inputText, axis: .vertical)
                                        .textFieldStyle(PlainTextFieldStyle())
                                        .font(.system(size: 14))
                                        .foregroundColor(.white)
                                        .disabled(isLoading)
                                        .focused($isTextFieldFocused)
                                        .padding(.horizontal, 4)
                                        .padding(.vertical, 8)
                                        .background(Color.clear)
                                        .onSubmit {
                                            if !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                                onSubmit()
                                            }
                                        }
                                        .onChange(of: inputText) { _, newValue in
                                            updateTextHeight(for: newValue)
                                        }
                                }
                                
                                // Send button
                                Button(action: {
                                    if !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                        onSubmit()
                                    }
                                }, label: {
                                    Image(systemName: isLoading ? "hourglass" : "arrow.up")
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(.white)
                                        .frame(width: 24, height: 24)
                                        .background(
                                            inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty 
                                                ? Color.gray.opacity(0.3) 
                                                : Color.blue
                                        )
                                        .clipShape(Circle())
                                })
                                .buttonStyle(PlainButtonStyle())
                                .disabled(inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isLoading)
                            }
                            
                            // Bottom controls - all buttons on same row, left-justified
                            HStack(alignment: .bottom, spacing: 8) {
                                // Model selector
                                modelSelectorView
                                    .frame(height: 24)
                                
                                // Image button
                                Button(action: {
                                    if showDrawer && drawerType == .images {
                                        // If images drawer is already open, close it
                                        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                            showDrawer = false
                                        }
                                    } else {
                                        // If templates drawer is open, close it first
                                        if showDrawer && drawerType == .templates {
                                            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                                showDrawer = false
                                            }
                                            // Wait for dismissal animation, then open images
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                                drawerType = .images
                                                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                                    showDrawer = true
                                                }
                                            }
                                        } else {
                                            // Open images drawer directly
                                            drawerType = .images
                                            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                                showDrawer = true
                                            }
                                        }
                                    }
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
                                    if showDrawer && drawerType == .templates {
                                        // If templates drawer is already open, close it
                                        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                            showDrawer = false
                                        }
                                    } else {
                                        // If images drawer is open, close it first
                                        if showDrawer && drawerType == .images {
                                            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                                showDrawer = false
                                            }
                                            // Wait for dismissal animation, then open templates
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                                drawerType = .templates
                                                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                                    showDrawer = true
                                                }
                                            }
                                        } else {
                                            // Open templates drawer directly
                                            drawerType = .templates
                                            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                                showDrawer = true
                                            }
                                        }
                                    }
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
                            .padding(.horizontal, 16)
                            .padding(.top, 2)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    .padding(.bottom, 12)
                }
                .floatingBlur(cornerRadius: 16)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(AppColors.Component.borderPrimary, lineWidth: 1)
                )
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
                .zIndex(1)  // Above drawers
            }
            .background(
                GeometryReader { geometry in
                    Color.clear
                        .onAppear {
                            inputViewFrame = geometry.frame(in: .global)
                        }
                        .onChange(of: geometry.frame(in: .global)) { _, newFrame in
                            inputViewFrame = newFrame
                        }
                }
            )
        }
        .onAppear {
            isTextFieldFocused = true
        }
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
            if showDrawer && drawerType == .models {
                // If models drawer is already open, close it
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    showDrawer = false
                }
            } else {
                // Close any other open drawers first
                if showDrawer {
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                        showDrawer = false
                    }
                    // Wait for dismissal animation, then open models drawer
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        drawerType = .models
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                            showDrawer = true
                        }
                    }
                } else {
                    // Open models drawer directly
                    drawerType = .models
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                        showDrawer = true
                    }
                }
            }
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
                    .rotationEffect(.degrees(showDrawer && drawerType == .models ? 180 : 0))
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
