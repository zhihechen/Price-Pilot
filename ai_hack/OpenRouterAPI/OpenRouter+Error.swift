//
//  OpenRouter+Error.swift
//  NTUiOSClubLLM
//
//  Created by Jane on 2025/2/22.
//

import Foundation

enum OpenRouterError: Error {
    case unknown
    case invalidURL
    case rateLimitReached
    case badResponseStatusCode(Int)
}
