import SwiftUI

struct MessageView: View {
    let message: Message
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            if message.role == .assistant {
                // Assistant avatar
                Image(systemName: "message.circle")
                    .font(.system(size: 28))
                    .foregroundColor(.blue)
                    .frame(width: 28, height: 28)
            } else {
                Spacer()
            }
            
            // Message content
            VStack(alignment: message.role == .user ? .trailing : .leading, spacing: 4) {
                Text(message.content)
                    .font(.system(size: 14))
                    .foregroundColor(message.role == .user ? .white : .white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(message.role == .user ? Color.blue : Color(hex: "#2a2a2a"))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                message.role == .user ? Color.clear : Color(hex: "#3a3a3a"), 
                                lineWidth: 1
                            )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .frame(
                maxWidth: .infinity * 0.75, 
                alignment: message.role == .user ? .trailing : .leading
            )
            
            if message.role == .user {
                // User avatar
                Image(systemName: "person.circle")
                    .font(.system(size: 28))
                    .foregroundColor(.gray)
                    .frame(width: 28, height: 28)
            } else {
                Spacer()
            }
        }
    }
}

// Color extension for hex colors
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
} 
