import SwiftUI

struct HeaderView: View {
    @EnvironmentObject var appState: AppStateManager
    
    var body: some View {
        HStack {
            Spacer()
            
            HStack(spacing: 8) {
                // Projects panel toggle
                Button(action: {
                    appState.updateUI(["showProjects": !appState.state.ui.showProjects])
                }) {
                    LeftPanelIcon(isActive: appState.state.ui.showProjects)
                        .foregroundColor(appState.state.ui.showProjects ? .gray : Color.gray.opacity(0.6))
                }
                .buttonStyle(PlainButtonStyle())
                .help(appState.state.ui.showProjects ? "Hide Projects Panel" : "Show Projects Panel")
                
                // Chart panel toggle
                Button(action: {
                    appState.updateUI(["showChart": !appState.state.ui.showChart])
                }) {
                    MiddlePanelIcon(isActive: appState.state.ui.showChart)
                        .foregroundColor(appState.state.ui.showChart ? .gray : Color.gray.opacity(0.6))
                }
                .buttonStyle(PlainButtonStyle())
                .help(appState.state.ui.showChart ? "Hide Chart Panel" : "Show Chart Panel")
                
                // Chat panel toggle
                Button(action: {
                    appState.updateUI(["showChat": !appState.state.ui.showChat])
                }) {
                    RightPanelIcon(isActive: appState.state.ui.showChat)
                        .foregroundColor(appState.state.ui.showChat ? .gray : Color.gray.opacity(0.6))
                }
                .buttonStyle(PlainButtonStyle())
                .help(appState.state.ui.showChat ? "Hide Chat Panel" : "Show Chat Panel")
            }
        }
        .padding(.horizontal, 16)
        .frame(height: 32)
        .background(Color(hex: "#1a1a1a"))
        .overlay(
            Rectangle()
                .fill(Color(hex: "#0a0a0a"))
                .frame(height: 1),
            alignment: .bottom
        )
    }
}

struct LeftPanelIcon: View {
    let isActive: Bool
    
    var body: some View {
        ZStack {
            Rectangle()
                .stroke(Color.gray, lineWidth: 1)
                .frame(width: 16, height: 12)
            
            if isActive {
                Rectangle()
                    .fill(Color.gray)
                    .frame(width: 8, height: 12)
                    .offset(x: -4)
            }
        }
    }
}

struct MiddlePanelIcon: View {
    let isActive: Bool
    
    var body: some View {
        ZStack {
            Rectangle()
                .stroke(Color.gray, lineWidth: 1)
                .frame(width: 16, height: 12)
            
            if isActive {
                Rectangle()
                    .fill(Color.gray)
                    .frame(width: 6, height: 12)
            }
        }
    }
}

struct RightPanelIcon: View {
    let isActive: Bool
    
    var body: some View {
        ZStack {
            Rectangle()
                .stroke(Color.gray, lineWidth: 1)
                .frame(width: 16, height: 12)
            
            if isActive {
                Rectangle()
                    .fill(Color.gray)
                    .frame(width: 8, height: 12)
                    .offset(x: 4)
            }
        }
    }
} 