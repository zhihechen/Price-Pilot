//
//  OpenRouter+ChatRequest.swift
//  NTUiOSClubLLM
//
//  Created by Jane on 2025/2/22.
//

import Foundation

extension OpenRouterManager {
    // See more parameters at: https://openrouter.ai/docs/api-reference/parameters
    struct ChatRequest: Encodable {
        let model: OpenRouterModel
        let messages: [ChatMLMessage]
        let temperature: Double
        let maxTokens: Int
        
        enum CodingKeys: String, CodingKey {
            case model
            case messages
            case temperature
            case maxTokens = "max_tokens"
        }
    }
}
