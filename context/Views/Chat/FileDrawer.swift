import SwiftUI
import AppKit

struct FileDrawer: View {
    @Binding var isPresented: Bool
    let parentFrame: CGRect
    
    // Calculate height for single row of images with padding
    private var calculatedHeight: CGFloat {
        return 152 // Height for single row with consistent padding
    }
    
    var body: some View {
        DrawerView(
            isPresented: $isPresented,
            parentFrame: parentFrame,
            contentHeight: calculatedHeight
        ) {
            FileDrawerContent(isPresented: $isPresented)
        }
    }
}

struct FileDrawerContent: View {
    @Binding var isPresented: Bool
    @State private var isProcessingSelection = false
    @State private var imageCount = 0
    
    var body: some View {
        VStack(spacing: 0) {
            // Horizontal image row with scroll
            ScrollViewReader { scrollProxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        // Regular image items (reversed so newest is on the left)
                        ForEach((0..<imageCount).reversed(), id: \.self) { index in
                            imageGridItem(index: index)
                                .id(index)
                        }
                        
                        // Add new image button (always on the right)
                        Button(action: {
                            // Add new image to the left (increment count)
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                imageCount += 1
                            }
                            
                            // Scroll to show the new image (leftmost - highest index since we reversed)
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                scrollProxy.scrollTo(imageCount - 1, anchor: .leading)
                            }
                            
                            print("Added new image. Total count: \(imageCount)")
                        }, label: {
                            Rectangle()
                                .fill(Color.clear)
                                .frame(width: 80, height: 120)  // Portrait aspect ratio
                                .overlay(
                                    Image(systemName: "plus")
                                        .font(.system(size: 28, weight: .medium))
                                        .foregroundColor(.white)
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(AppColors.Component.borderPrimary, lineWidth: 1)
                                )
                        })
                        .buttonStyle(PlainButtonStyle())
                        .id("add")
                    }
                    .padding(.horizontal, 16)
                }
                .frame(maxWidth: .infinity, maxHeight: 140)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity) // Ensure VStack takes full width and height
    }
    
    private func imageGridItem(index: Int) -> some View {
        Button(action: {
            // Prevent multiple clicks
            guard !isProcessingSelection else { return }
            isProcessingSelection = true
            
            // Handle image selection
            print("Selected image: \(index)")
            
            // Delay to prevent multiple triggers
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    isPresented = false
                }
                // Reset after animation completes
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    isProcessingSelection = false
                }
            }
        }, label: {
            ZStack {
                Rectangle()
                    .fill(Color.clear)
                    .frame(width: 80, height: 120)  // Portrait aspect ratio
                    .overlay(
                        Image(systemName: "photo")
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(AppColors.Component.borderPrimary, lineWidth: 1)
                    )
                
                // Trash icon overlay
                TrashOverlay(index: index, imageCount: $imageCount)
            }
        })
        .buttonStyle(PlainButtonStyle())
        .disabled(isProcessingSelection)
    }
}

struct TrashOverlay: View {
    let index: Int
    @Binding var imageCount: Int
    @State private var isHovered = false
    
    var body: some View {
        VStack {
            HStack {
                if isHovered {
                    Button(action: {
                        // Remove this image by decrementing imageCount
                        // Since we're using reversed indices, removing any image
                        // will shift the indices, so we just decrement the count
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            imageCount = max(0, imageCount - 1)
                        }
                        print("Removed image at index: \(index)")
                    }) {
                        Image(systemName: "trash")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.white)
                            .frame(width: 20, height: 20)
                            .background(
                                FloatingBlur(cornerRadius: 10)
                            )
                            .clipShape(Circle())
                    }
                    .buttonStyle(PlainButtonStyle())
                    .transition(.scale.combined(with: .opacity))
                    .padding(.leading, 6)
                    .padding(.top, 6)
                }
                Spacer()
            }
            Spacer()
        }
        .frame(width: 80, height: 120)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.2)) {
                isHovered = hovering
            }
        }
    }
}