import SwiftUI

struct LoadingMessageView: View {
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Assistant avatar
            Image(systemName: "message.circle")
                .font(.system(size: 28))
                .foregroundColor(.blue)
                .frame(width: 28, height: 28)
            
            // Loading indicator
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    ProgressView()
                        .scaleEffect(0.8)
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    
                    Text("Thinking...")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color.clear)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.clear, lineWidth: 1)
                )
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .frame(maxWidth: .infinity * 0.75, alignment: .leading)
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
} 