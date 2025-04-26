//
//  OpenRouterAPIProvider.swift
//  NTUiOSClubLLM
//
//  Created by Jane on 2025/2/24.
//

import SwiftUI

protocol OpenRouterAPIProvider {
    func sendRequest(model: OpenRouterModel, messages: [ChatMLMessage], temperature: Double, maxTokens: Int) async throws -> ChatMLMessage
}

extension OpenRouterAPIProvider where Self == OpenRouterManager {
    static var shared: OpenRouterAPIProvider { OpenRouterManager.shared }
    static var stub: OpenRouterAPIProvider { StubAPIManager() }
}

// MARK: - environment
extension EnvironmentValues {
    @Entry var openRouter: OpenRouterAPIProvider = .stub
}

// MARK: - stub api for testing
private struct StubAPIManager: OpenRouterAPIProvider {
    func sendRequest(model: OpenRouterModel, messages: [ChatMLMessage], temperature: Double, maxTokens: Int) async throws -> ChatMLMessage {
        let lastMessage = messages.last!.content
        try? await Task.sleep(for: .seconds(1))
        return ChatMLMessage(role: .ai, content: "**這是測試用的假回應，會重複一樣內容**\n\(lastMessage)")
    }
}
