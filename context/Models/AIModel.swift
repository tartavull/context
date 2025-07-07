import Foundation

// MARK: - AI Model Data Structure
struct AIModel {
    let name: String
    let tier: String
    let inputTokenCost: Double  // Cost per 1M input tokens
    let outputTokenCost: Double // Cost per 1M output tokens
    let contextWindow: Int      // Maximum context window
    let description: String
    let provider: String

    // Calculate cost for given token counts
    func calculateCost(inputTokens: Int, outputTokens: Int) -> Double {
        let inputCost = (Double(inputTokens) / 1_000_000) * inputTokenCost
        let outputCost = (Double(outputTokens) / 1_000_000) * outputTokenCost
        return inputCost + outputCost
    }

    // Format cost as currency string
    func formatCost(inputTokens: Int, outputTokens: Int) -> String {
        let cost = calculateCost(inputTokens: inputTokens, outputTokens: outputTokens)
        if cost < 0.01 {
            return "<$0.01"
        }
        return String(format: "$%.2f", cost)
    }

    // Simple tuple format for backward compatibility
    var simpleTuple: (String, String) {
        return (name, tier)
    }
}

// MARK: - Available AI Models
struct AIModels {
    static let available: [AIModel] = [
        AIModel(
            name: "claude-4-sonnet",
            tier: "MAX",
            inputTokenCost: 15.0,
            outputTokenCost: 75.0,
            contextWindow: 200_000,
            description: "Most capable model for complex reasoning, advanced analysis, and creative tasks. " +
                "Excels at code generation, mathematical problem-solving, and nuanced writing.",
            provider: "Anthropic"
        ),
        AIModel(
            name: "claude-3-sonnet",
            tier: "PRO",
            inputTokenCost: 3.0,
            outputTokenCost: 15.0,
            contextWindow: 200_000,
            description: "Balanced performance and cost with strong reasoning capabilities. " +
                "Great for general tasks, content creation, and moderate complexity coding projects.",
            provider: "Anthropic"
        ),
        AIModel(
            name: "claude-3-haiku",
            tier: "FAST",
            inputTokenCost: 0.25,
            outputTokenCost: 1.25,
            contextWindow: 200_000,
            description: "Fastest responses with lowest cost while maintaining quality. " +
                "Perfect for quick questions, simple tasks, and high-volume applications.",
            provider: "Anthropic"
        ),
        AIModel(
            name: "gpt-4",
            tier: "MAX",
            inputTokenCost: 30.0,
            outputTokenCost: 60.0,
            contextWindow: 8_000,
            description: "OpenAI's most capable model with exceptional reasoning and creative abilities. " +
                "Best for complex problem-solving, detailed analysis, and sophisticated writing tasks.",
            provider: "OpenAI"
        ),
        AIModel(
            name: "gpt-3.5-turbo",
            tier: "FAST",
            inputTokenCost: 0.5,
            outputTokenCost: 1.5,
            contextWindow: 4_000,
            description: "Fast and cost-effective with reliable performance. " +
                "Ideal for everyday tasks, basic coding assistance, and applications requiring quick responses.",
            provider: "OpenAI"
        )
    ]

    // Convenience methods
    static func model(named name: String) -> AIModel? {
        return available.first { $0.name == name }
    }

    static var simpleList: [(String, String)] {
        return available.map { $0.simpleTuple }
    }
}
