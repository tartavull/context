import SwiftUI

@MainActor
class InputHandler: ObservableObject {
    @Published var inputText = ""
    @Published var isLoading = false
    @Published var selectedModel = "claude-4-sonnet"
    @Published var showModelDropdown = false
    
    let models = [
        ("claude-4-sonnet", "MAX"),
        ("claude-3-sonnet", "PRO"),
        ("claude-3-haiku", "FAST"),
        ("gpt-4", "MAX"),
        ("gpt-3.5-turbo", "FAST")
    ]
    
    private let appState: AppStateManager
    
    init(appState: AppStateManager) {
        self.appState = appState
    }
    
    func handleSubmit() {
        guard !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        let trimmedInput = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        let projectId = appState.state.selectedProjectId ?? "default"
        let task = appState.selectedTask ?? defaultTask
        
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
            handleCommand(trimmedInput, projectId: projectId, task: task)
        } else {
            // Handle regular message
            handleRegularMessage(trimmedInput, projectId: projectId, task: task)
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
    
    private func handleCommand(_ command: String, projectId: String, task: ProjectTask) {
        isLoading = true
        
        Task {
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
            
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
    
    private func handleRegularMessage(_ message: String, projectId: String, task: ProjectTask) {
        isLoading = true
        
        Task {
            try? await Task.sleep(nanoseconds: 1_000_000_000) // 1.0 seconds
            
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