import SwiftUI

struct HeaderView: View {
    var body: some View {
        HStack {
            Spacer()
            
            // New conversation button (center)
            Button(action: {
                // Add new conversation action here
                print("New conversation")
            }) {
                NewConversationIcon()
                    .foregroundColor(.gray)
            }
            .buttonStyle(PlainButtonStyle())
            .help("New Conversation")
            
            Spacer()
        }
        .padding(.horizontal, 4)
        .frame(height: 32)
        .background(Color.black)
        .overlay(
            Rectangle()
                .fill(Color(hex: "#0a0a0a"))
                .frame(height: 1),
            alignment: .bottom
        )
    }
}



// New conversation icon (iMessage-style)
struct NewConversationIcon: View {
    var body: some View {
        ZStack {
            // Square background with rounded corners
            RoundedRectangle(cornerRadius: 3)
                .stroke(Color.gray, lineWidth: 1)
                .frame(width: 16, height: 16)
            
            // Pencil/edit icon
            Image(systemName: "square.and.pencil")
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(.gray)
        }
    }
}

 