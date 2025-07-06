import SwiftUI

struct TemplatesDrawer: View {
    @Binding var isPresented: Bool
    let parentFrame: CGRect
    
    var body: some View {
        DrawerView(
            isPresented: $isPresented,
            parentFrame: parentFrame,
            contentHeight: min(400, max(200, CGFloat(10 * 50 + 80)))  // Reduced row height from 60 to 50, padding from 100 to 80
        ) {
            TemplatesDrawerContent(isPresented: $isPresented)
        }
    }
}

struct TemplatesDrawerContent: View {
    @Binding var isPresented: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            // Scrollable template list
            ScrollView {
                LazyVStack(spacing: 4) {  // Reduced from 8 to 4
                    // Create new template row
                    createNewTemplateRow()
                    
                    ForEach(sampleTemplates, id: \.id) { template in
                        templateRow(template)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)  // Reduced from 16 to 12
            }
        }
    }
    
    private func createNewTemplateRow() -> some View {
        Button(action: {
            // Handle create new template
            print("Create new template")
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                isPresented = false
            }
        }, label: {
            HStack {
                Image(systemName: "plus")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white)
                
                VStack(alignment: .leading, spacing: 2) {  // Reduced from 4 to 2
                    Text("Create a new template")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.leading)
                    
                    Text("Build a custom template for your workflows")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 10))
                    .foregroundColor(.gray)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)  // Reduced from 12 to 8
            .background(Color(hex: "#3a3a3a"))
            .clipShape(RoundedRectangle(cornerRadius: 8))
        })
        .buttonStyle(PlainButtonStyle())
    }
    
    private func templateRow(_ template: TemplateItem) -> some View {
        Button(action: {
            // Handle template selection
            print("Selected template: \(template.title)")
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                isPresented = false
            }
        }, label: {
            HStack {
                Text(template.icon)
                    .font(.system(size: 16))
                
                VStack(alignment: .leading, spacing: 2) {  // Reduced from 4 to 2
                    Text(template.title)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.leading)
                    
                    Text(template.description)
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 10))
                    .foregroundColor(.gray)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)  // Reduced from 12 to 8
            .background(Color(hex: "#3a3a3a"))
            .clipShape(RoundedRectangle(cornerRadius: 8))
        })
        .buttonStyle(PlainButtonStyle())
    }
}

// Sample data structures
struct TemplateItem {
    let id = UUID()
    let title: String
    let description: String
    let icon: String
}

private let sampleTemplates: [TemplateItem] = [
    TemplateItem(title: "/code_review", description: "Review this code for best practices and potential improvements", icon: "👁️"),
    TemplateItem(title: "/bug_report", description: "Help me debug this issue I'm encountering", icon: "🐛"),
    TemplateItem(title: "/explain_code", description: "Explain how this code works step by step", icon: "💡"),
    TemplateItem(title: "/optimize_performance", description: "Suggest optimizations for better performance", icon: "⚡"),
    TemplateItem(title: "/write_tests", description: "Create comprehensive tests for this functionality", icon: "🧪"),
    TemplateItem(title: "/documentation", description: "Generate documentation for this code", icon: "📚"),
    TemplateItem(title: "/refactor_code", description: "Refactor this code for better readability", icon: "🔧"),
    TemplateItem(title: "/api_design", description: "Design a REST API for this functionality", icon: "🔌"),
    TemplateItem(title: "/database_schema", description: "Create a database schema for this data", icon: "🗄️"),
    TemplateItem(title: "/security_review", description: "Review this code for security vulnerabilities", icon: "🔒"),
] 