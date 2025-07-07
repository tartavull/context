import Foundation

// MARK: - Template Data Model

struct TemplateItem: Identifiable, Codable {
    let id: String
    let title: String
    let description: String
    let icon: String
    let content: String?

    init(id: String, title: String, description: String, icon: String, content: String? = nil) {
        self.id = id
        self.title = title
        self.description = description
        self.icon = icon
        self.content = content
    }
}

// MARK: - Sample Templates

let sampleTemplates: [TemplateItem] = [
    TemplateItem(
        id: "code_review",
        title: "/code_review",
        description: "Review this code for best practices and potential improvements",
        icon: "👁️",
        content: "Please review the following code for:\n- Best practices\n- Performance improvements\n" +
            "- Security considerations\n- Code readability\n\n```\n{code}\n```"
    ),
    TemplateItem(
        id: "bug_report",
        title: "/bug_report",
        description: "Help me debug this issue I'm encountering",
        icon: "🐛",
        content: "I'm encountering the following bug:\n\n**Issue Description:**\n{description}\n\n" +
            "**Steps to Reproduce:**\n1. {step1}\n2. {step2}\n3. {step3}\n\n**Expected Behavior:**\n{expected}\n\n" +
            "**Actual Behavior:**\n{actual}\n\n**Code:**\n```\n{code}\n```"
    ),
    TemplateItem(
        id: "explain_code",
        title: "/explain_code",
        description: "Explain how this code works step by step",
        icon: "💡",
        content: "Please explain how this code works step by step:\n\n```\n{code}\n```\n\n" +
            "Please break down:\n- What each section does\n- How the logic flows\n" +
            "- Any important concepts or patterns used"
    ),
    TemplateItem(
        id: "optimize_performance",
        title: "/optimize_performance",
        description: "Suggest optimizations for better performance",
        icon: "⚡",
        content: "Please analyze this code for performance optimizations:\n\n```\n{code}\n```\n\n" +
            "Please focus on:\n- Algorithm efficiency\n- Memory usage\n- Database queries (if applicable)\n" +
            "- Network requests\n- Caching opportunities"
    ),
    TemplateItem(
        id: "write_tests",
        title: "/write_tests",
        description: "Create comprehensive tests for this functionality",
        icon: "🧪",
        content: "Please create comprehensive tests for this code:\n\n```\n{code}\n```\n\n" +
            "Please include:\n- Unit tests\n- Edge cases\n- Error scenarios\n- Mock data where needed"
    ),
    TemplateItem(
        id: "documentation",
        title: "/documentation",
        description: "Generate documentation for this code",
        icon: "📚",
        content: "Please generate documentation for this code:\n\n```\n{code}\n```\n\n" +
            "Please include:\n- Function/method descriptions\n- Parameter explanations\n" +
            "- Return value descriptions\n- Usage examples\n- Any important notes or warnings"
    ),
    TemplateItem(
        id: "refactor_code",
        title: "/refactor_code",
        description: "Refactor this code for better readability",
        icon: "🔧",
        content: "Please refactor this code for better readability and maintainability:\n\n```\n{code}\n```\n\n" +
            "Please focus on:\n- Code organization\n- Naming conventions\n- Reducing complexity\n" +
            "- Following best practices\n- Maintaining functionality"
    ),
    TemplateItem(
        id: "api_design",
        title: "/api_design",
        description: "Design a REST API for this functionality",
        icon: "🔌",
        content: "Please design a REST API for the following functionality:\n\n**Requirements:**\n{requirements}\n\n" +
            "**Data Models:**\n{models}\n\nPlease include:\n- Endpoint definitions\n- HTTP methods\n" +
            "- Request/response formats\n- Error handling\n- Authentication (if needed)"
    ),
    TemplateItem(
        id: "database_schema",
        title: "/database_schema",
        description: "Create a database schema for this data",
        icon: "🗄️",
        content: "Please create a database schema for the following data:\n\n**Requirements:**\n{requirements}\n\n" +
            "**Data Description:**\n{description}\n\nPlease include:\n- Table definitions\n- Relationships\n" +
            "- Indexes\n- Constraints\n- Sample data"
    ),
    TemplateItem(
        id: "security_review",
        title: "/security_review",
        description: "Review this code for security vulnerabilities",
        icon: "🔒",
        content: "Please review this code for security vulnerabilities:\n\n```\n{code}\n```\n\n" +
            "Please check for:\n- Input validation\n- SQL injection\n- XSS vulnerabilities\n" +
            "- Authentication/authorization issues\n- Data exposure\n- Other security best practices"
    )
]
