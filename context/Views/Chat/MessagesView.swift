import SwiftUI
import AppKit

struct MessagesView: View {
    @EnvironmentObject var appState: AppStateManager
    let selectedProjectId: String?
    
    var body: some View {
        ZStack {
            Color.clear
                .ignoresSafeArea()
            
            // Always show chat messages with default values if needed
            ChatMessagesContentView(
                projectId: selectedProjectId ?? "default",
                task: appState.selectedTask ?? defaultTask
            )
        }
    }
    
    private var defaultTask: ProjectTask {
        var task = ProjectTask(
            title: "Chat",
            description: "",
            nodeType: .original
        )
        task.status = .active
        return task
    }
}

struct ChatMessagesContentView: View {
    @EnvironmentObject var appState: AppStateManager
    let projectId: String
    let task: ProjectTask
    
    @State private var isLoading = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Messages only
            messagesView
        }
        .frame(maxHeight: 400)
    }
    
    private var messagesView: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(task.conversation.messages, id: \.id) { message in
                    /*
                    MessageView(message: message)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                    */
                }
                
                if isLoading {
                    LoadingMessageView()
                }
            }
        }
        .background(Color.clear)
    }
} 