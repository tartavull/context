import SwiftUI
import AppKit

struct ProjectsView: View {
    @EnvironmentObject var appState: AppStateManager
    @State private var isEditing: String? = nil
    @State private var editTitle: String = ""
    @FocusState private var isTextFieldFocused: Bool
    let isCollapsed: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                if !isCollapsed {
                    Text("Projects")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.white)
                    Spacer()
                }
                
                Button(action: {
                    createNewProject()
                }) {
                    NewConversationIcon()
                        .foregroundColor(.white)
                        .frame(width: isCollapsed ? 32 : 24, height: isCollapsed ? 32 : 24)
                }
                .buttonStyle(PlainButtonStyle())
                .help("Create New Project")
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .overlay(
                Rectangle()
                    .fill(Color.white.opacity(0.1))
                    .frame(height: 1),
                alignment: .bottom
            )
            
            // Projects List
            ScrollView {
                LazyVStack(spacing: 0) {
                    if appState.state.projects.isEmpty {
                        // Empty state
                        VStack(spacing: 12) {
                            if !isCollapsed {
                                Text("No projects yet")
                                    .font(.system(size: 13))
                                    .foregroundColor(.gray)
                            }
                            
                            Button(action: {
                                createNewProject()
                            }) {
                                HStack {
                                    NewConversationIcon()
                                        .foregroundColor(.white)
                                    if !isCollapsed {
                                        Text("Create Project")
                                            .font(.system(size: 12))
                                    }
                                }
                                .foregroundColor(.white)
                                .padding(.horizontal, isCollapsed ? 0 : 12)
                                .padding(.vertical, 8)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        .padding(16)
                    } else {
                        ForEach(Array(appState.state.projects.values), id: \.id) { project in
                            projectItemView(for: project)
                        }
                    }
                }
            }
            
            // Add a spacer to push content to top and ensure background fills remaining space
            Spacer(minLength: 0)
        }
        .frame(maxHeight: .infinity)
        .background(
            BlurView(material: .hudWindow, blendingMode: .behindWindow)
                .ignoresSafeArea(.all, edges: .top)
        )

        .onChange(of: isEditing) { _, newValue in
            if newValue != nil {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    isTextFieldFocused = true
                }
            }
        }
    }
    
    private func projectItemView(for project: Project) -> some View {
        ProjectItemView(
            project: project,
            isSelected: appState.state.selectedProjectId == project.id,
            isCollapsed: isCollapsed,
            isEditing: isEditing == project.id,
            editTitle: editTitle,
            onSelect: { 
                if isEditing != project.id {
                    appState.selectProject(project.id) 
                }
            },
            onEdit: { 
                startEditing(project: project)
            },
            onSaveEdit: { newTitle in
                saveEdit(project: project, newTitle: newTitle)
            },
            onCancelEdit: {
                cancelEdit()
            },
            onDelete: { 
                deleteProject(project.id)
            },
            onTitleChange: { editTitle = $0 }
        )
        .focused($isTextFieldFocused, equals: isEditing == project.id)
    }
    
    private func createNewProject() {
        appState.createProject(title: "New Project", description: "Project description")
        // Auto-start editing the new project
        if let newProjectId = appState.state.selectedProjectId {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isEditing = newProjectId
                editTitle = "New Project"
                isTextFieldFocused = true
            }
        }
    }
    
    private func startEditing(project: Project) {
        isEditing = project.id
        editTitle = project.title
        isTextFieldFocused = true
    }
    
    private func saveEdit(project: Project, newTitle: String) {
        let trimmedTitle = newTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedTitle.isEmpty && trimmedTitle != project.title {
            appState.updateProject(projectId: project.id, updates: ["title": trimmedTitle])
        }
        isEditing = nil
        isTextFieldFocused = false
    }
    
    private func cancelEdit() {
        isEditing = nil
        isTextFieldFocused = false
    }
    
    private func deleteProject(_ projectId: String) {
        // Show confirmation dialog
        let alert = NSAlert()
        alert.messageText = "Delete Project"
        alert.informativeText = "Are you sure you want to delete this project? This action cannot be undone."
        alert.alertStyle = .warning
        alert.addButton(withTitle: "Delete")
        alert.addButton(withTitle: "Cancel")
        
        let response = alert.runModal()
        if response == .alertFirstButtonReturn {
            appState.deleteProject(projectId)
        }
    }
}

struct ProjectItemView: View {
    let project: Project
    let isSelected: Bool
    let isCollapsed: Bool
    let isEditing: Bool
    let editTitle: String
    let onSelect: () -> Void
    let onEdit: () -> Void
    let onSaveEdit: (String) -> Void
    let onCancelEdit: () -> Void
    let onDelete: () -> Void
    let onTitleChange: (String) -> Void
    
    @State private var showActions = false
    
    var body: some View {
        HStack(spacing: 0) {
            // Project Avatar
            Text(String(project.title.prefix(1)).uppercased())
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.white)
                .frame(width: 32, height: 32)
                .background(statusColor)
                .clipShape(Circle())
            
            if !isCollapsed {
                // Project Content
                VStack(alignment: .leading, spacing: 2) {
                    HStack {
                        if isEditing {
                            TextField("Project Title", text: Binding(
                                get: { editTitle },
                                set: onTitleChange
                            ))
                            .textFieldStyle(PlainTextFieldStyle())
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.white)
                            .onSubmit {
                                onSaveEdit(editTitle)
                            }
                            .onExitCommand {
                                onCancelEdit()
                            }
                        } else {
                            Text(project.title)
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.white)
                                .lineLimit(1)
                                .truncationMode(.tail)
                        }
                        
                        Spacer()
                        
                        if !isEditing {
                            Text(formatDate(project.createdAt))
                                .font(.system(size: 11))
                                .foregroundColor(.gray)
                        }
                    }
                    
                    if !project.description.isEmpty && !isEditing {
                        Text(project.description)
                            .font(.system(size: 11))
                            .foregroundColor(.gray)
                            .lineLimit(1)
                            .truncationMode(.tail)
                    }
                }
                .padding(.leading, 12)
                
                // Actions
                if showActions && !isEditing {
                    HStack(spacing: 4) {
                        Button(action: onEdit) {
                            Image(systemName: "pencil")
                                .font(.system(size: 12))
                                .foregroundColor(.gray)
                                .frame(width: 24, height: 24)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .help("Edit")
                        
                        Button(action: onDelete) {
                            Image(systemName: "trash")
                                .font(.system(size: 12))
                                .foregroundColor(.gray)
                                .frame(width: 24, height: 24)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .help("Delete")
                    }
                    .opacity(showActions ? 1 : 0)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            isSelected ? 
                Color.accentColor.opacity(0.2) : 
                Color.clear
        )
        .contentShape(Rectangle())
        .onTapGesture {
            if !isEditing {
                onSelect()
            }
        }
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.2)) {
                showActions = hovering
            }
        }
    }
    
    private var statusColor: Color {
        switch project.status {
        case .completed:
            return Color(hex: "#10B981")
        case .active:
            return Color(hex: "#3B82F6")
        case .failed:
            return Color(hex: "#EF4444")
        default:
            return Color(hex: "#6B7280")
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let now = Date()
        let diffInHours = now.timeIntervalSince(date) / 3600
        
        if diffInHours < 24 {
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            return formatter.string(from: date)
        } else if diffInHours < 24 * 7 {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEE"
            return formatter.string(from: date)
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM d"
            return formatter.string(from: date)
        }
    }
}

struct BlurView: NSViewRepresentable {
    let material: NSVisualEffectView.Material
    let blendingMode: NSVisualEffectView.BlendingMode
    
    init(material: NSVisualEffectView.Material = .hudWindow, blendingMode: NSVisualEffectView.BlendingMode = .behindWindow) {
        self.material = material
        self.blendingMode = blendingMode
    }
    
    func makeNSView(context: Context) -> NSVisualEffectView {
        let effectView = NSVisualEffectView()
        effectView.material = material
        effectView.blendingMode = blendingMode
        effectView.state = .active
        return effectView
    }
    
    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        nsView.material = material
        nsView.blendingMode = blendingMode
    }
}

// New conversation icon (iMessage-style) - moved from HeaderView
struct NewConversationIcon: View {
    var body: some View {
        // Pencil/edit icon
        Image(systemName: "square.and.pencil")
            .font(.system(size: 15, weight: .medium))
            .foregroundColor(.gray)
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
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
} 