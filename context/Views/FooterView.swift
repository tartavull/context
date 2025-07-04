import SwiftUI

struct FooterView: View {
    @State private var currentTime = Date()
    
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        HStack {
            Spacer()
            
            Text(formatTime(currentTime))
                .font(.system(size: 12, design: .monospaced))
                .foregroundColor(.gray)
        }
        .padding(.horizontal, 16)
        .frame(height: 32)
        .background(Color.black)
        .overlay(
            Rectangle()
                .fill(Color(hex: "#0a0a0a"))
                .frame(height: 1),
            alignment: .top
        )
        .onReceive(timer) { time in
            currentTime = time
        }
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "mm:ss"
        return formatter.string(from: date)
    }
} 