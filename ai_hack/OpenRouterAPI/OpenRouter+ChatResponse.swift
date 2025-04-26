//
//  OpenRouter+ChatResponse.swift
//  NTUiOSClubLLM
//
//  Created by Jane on 2025/2/22.
//

import Foundation

extension OpenRouterManager {
    struct ChatResponse: Decodable {
        let choices: [Choice]
        
        struct Choice: Decodable {
            let message: ChatMLMessage
        }
    }
}
