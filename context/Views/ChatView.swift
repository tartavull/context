import SwiftUI
import AppKit

struct ChatView: View {
    @EnvironmentObject var appState: AppStateManager
    let selectedProjectId: String?
    
    var body: some View {
        ZStack {
            Color.clear
                .ignoresSafeArea()
            
            // Always show chat content with default values if needed
            ChatContentView(
                projectId: selectedProjectId ?? "default",
                task: appState.selectedTask ?? defaultTask
            )
        }
    }
    
    private var defaultTask: Task {
        Task(
            id: "default",
            title: "Chat",
            description: "",
            status: .active,
            nodeType: .task,
            conversation: Conversation(messages: [])
        )
    }
    

}

struct ChatContentView: View {
    @EnvironmentObject var appState: AppStateManager
    let projectId: String
    let task: Task
    
    @State private var inputText = ""
    @State private var isLoading = false
    @State private var selectedModel = "claude-4-sonnet"
    @State private var showModelDropdown = false
    
    private let models = [
        ("claude-4-sonnet", "MAX"),
        ("claude-3-sonnet", "PRO"),
        ("claude-3-haiku", "FAST"),
        ("gpt-4", "MAX"),
        ("gpt-3.5-turbo", "FAST")
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // Messages
            messagesView
            
            // Input Area
            ChatInputView(
                inputText: $inputText,
                isLoading: $isLoading,
                selectedModel: $selectedModel,
                showModelDropdown: $showModelDropdown,
                models: models
            ) {
                handleSubmit()
            }
        }
    }
    
    private var taskHeaderView: some View {
        HStack {
            Circle()
                .fill(statusColor)
                .frame(width: 12, height: 12)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(task.title)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.white)
                    .lineLimit(1)
                
                if !task.description.isEmpty {
                    Text(task.description)
                        .font(.system(size: 11))
                        .foregroundColor(.gray)
                        .lineLimit(1)
                }
            }
            
            Spacer()
            
            Text(task.nodeType.rawValue.capitalized)
                .font(.system(size: 11))
                .foregroundColor(.gray)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(hex: "#2a2a2a"))
        .overlay(
            Rectangle()
                .fill(Color(hex: "#3a3a3a"))
                .frame(height: 1),
            alignment: .bottom
        )
    }
    
    private var statusColor: Color {
        switch task.status {
        case .pending: return .yellow
        case .active: return .blue
        case .completed: return .green
        case .failed: return .red
        }
    }
    
    private var messagesView: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(task.conversation.messages, id: \.id) { message in
                    MessageView(message: message)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                }
                
                if isLoading {
                    loadingView
                }
            }
        }
        .background(Color.clear)
    }
    
    private var loadingView: some View {
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
                .background(Color(hex: "#2a2a2a"))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color(hex: "#3a3a3a"), lineWidth: 1)
                )
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .frame(maxWidth: .infinity * 0.75, alignment: .leading)
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
    
    private func handleSubmit() {
        guard !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        let trimmedInput = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Add user message
        let userMessage = Message(
            id: UUID().uuidString,
            role: .user,
            content: trimmedInput,
            timestamp: Date()
        )
        
        appState.addMessage(projectId: projectId, taskId: task.id, message: userMessage)
        inputText = ""
        
        // Handle commands
        if trimmedInput.hasPrefix("/") {
            handleCommand(trimmedInput)
        } else {
            // Handle regular message
            handleRegularMessage(trimmedInput)
        }
    }
    
    private func handleCommand(_ command: String) {
        isLoading = true
        
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) {
            DispatchQueue.main.async {
                let parts = command.split(separator: " ")
                let commandName = String(parts.first ?? "")
                let args = parts.dropFirst().map(String.init)
                
                var responseMessage = ""
                
                switch commandName {
                case "/clone":
                    appState.cloneTask(projectId: projectId, taskId: task.id)
                    responseMessage = "✅ Task cloned successfully! A new clone has been created."
                    
                case "/spawn":
                    let title = args.joined(separator: " ").isEmpty ? "New Task" : args.joined(separator: " ")
                    let description = "Spawned from \(task.title)"
                    appState.spawnTask(
                        projectId: projectId, 
                        parentTaskId: task.id, 
                        title: title, 
                        description: description
                    )
                    responseMessage = "✅ New task \"\(title)\" spawned successfully!"
                    
                case "/exit":
                    responseMessage = "✅ Task folded back to parent successfully."
                    
                default:
                    responseMessage = "❌ Unknown command: \(commandName). " +
                                    "Available commands: /clone, /spawn [title], /exit"
                }
                
                let assistantMessage = Message(
                    id: UUID().uuidString,
                    role: .assistant,
                    content: responseMessage,
                    timestamp: Date()
                )
                
                appState.addMessage(projectId: projectId, taskId: task.id, message: assistantMessage)
                isLoading = false
            }
        }
    }
    
    private func handleRegularMessage(_ message: String) {
        isLoading = true
        
        DispatchQueue.global().asyncAfter(deadline: .now() + 1.0) {
            DispatchQueue.main.async {
                let assistantMessage = Message(
                    id: UUID().uuidString,
                    role: .assistant,
                    content: "I received your message: \"\(message)\". This is a mock response " +
                             "using \(selectedModel). In a real implementation, this would connect to an AI service.",
                    timestamp: Date()
                )
                
                appState.addMessage(projectId: projectId, taskId: task.id, message: assistantMessage)
                isLoading = false
            }
        }
    }
}
