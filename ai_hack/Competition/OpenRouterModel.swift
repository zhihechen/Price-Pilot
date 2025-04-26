//
//  OpenRouter+Model.swift
//  NTUiOSClubLLM
//
//  Created by Jane on 2025/2/22.
//

import Foundation

enum OpenRouterModel: CaseIterable {
    case llama
    case gemini
    // case claude
    case deepseek
    
    var name: String {
        switch self {
            case .llama:
                "Llama"
            case .gemini:
                "Gemini"
            // case .claude:
                // "Claude"
            case .deepseek:
                "Deepseek"
        }
    }
    
    var path: String {
        switch self {
            case .llama:
                "meta-llama/llama-3.3-70b-instruct:free"
            case .gemini:
                "google/gemini-2.0-pro-exp-02-05:free"
            // case .claude:
                // "anthropic/claude-3.7-sonnet:beta"
            case .deepseek:
                "deepseek/deepseek-r1-distill-llama-70b:free"
        }
    }
    
    
}

extension OpenRouterModel: Encodable {
    func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(path)
    }
}
