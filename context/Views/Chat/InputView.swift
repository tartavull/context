import SwiftUI
import AppKit

struct InputView: View {
    @Binding var inputText: String
    @Binding var isLoading: Bool
    @Binding var selectedModel: String
    @Binding var showModelDropdown: Bool
    let models: [(String, String)]
    let onSubmit: () -> Void
    
    @State private var textHeight: CGFloat = 48
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        VStack(spacing: 0) {
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
                        
                        // Bottom controls
                        HStack {
                            // Model selector
                            modelSelectorView
                            
                            Spacer()
                            
                            // Additional controls
                            HStack(spacing: 8) {
                                Button(action: {
                                    // Image upload functionality placeholder
                                }, label: {
                                    Image(systemName: "photo")
                                        .font(.system(size: 12))
                                        .foregroundColor(.gray)
                                        .frame(width: 24, height: 24)
                                })
                                .buttonStyle(PlainButtonStyle())
                                .help("Attach Image")
                                
                                Button(action: {
                                    // Additional options placeholder
                                }, label: {
                                    Image(systemName: "ellipsis")
                                        .font(.system(size: 12))
                                        .foregroundColor(.gray)
                                        .frame(width: 24, height: 24)
                                })
                                .buttonStyle(PlainButtonStyle())
                                .help("More Options")
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 8)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .padding(.bottom, 12)
            }
            .background(
                BlurView(material: .hudWindow, blendingMode: .behindWindow)
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color(hex: "#3a3a3a"), lineWidth: 1)
            )
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
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
    
    private var modelSelectorView: some View {
        Button(action: {
            showModelDropdown.toggle()
        }, label: {
            HStack(spacing: 4) {
                Text(selectedModel)
                    .font(.system(size: 12))
                    .foregroundColor(.white)
                
                if let tier = models.first(where: { $0.0 == selectedModel })?.1 {
                    Text(tier)
                        .font(.system(size: 10))
                        .foregroundColor(.gray)
                }
                
                Image(systemName: "chevron.down")
                    .font(.system(size: 8))
                    .foregroundColor(.gray)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color.clear)
            .clipShape(RoundedRectangle(cornerRadius: 4))
        })
        .buttonStyle(PlainButtonStyle())
        .popover(isPresented: $showModelDropdown) {
            modelDropdownView
        }
    }
    
    private var modelDropdownView: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(models, id: \.0) { model, tier in
                Button(action: {
                    selectedModel = model
                    showModelDropdown = false
                }, label: {
                    HStack {
                        Text(model)
                            .font(.system(size: 12))
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Text(tier)
                            .font(.system(size: 10))
                            .foregroundColor(.gray)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(selectedModel == model ? Color(hex: "#3a3a3a") : Color.clear)
                })
                .buttonStyle(PlainButtonStyle())
            }
        }
        .frame(minWidth: 200)
        .background(Color(hex: "#2a2a2a"))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color(hex: "#3a3a3a"), lineWidth: 1)
        )
    }
}
