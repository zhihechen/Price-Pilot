//
//  RomanticChatView.swift
//  NTUiOSClubLLM
//
//  Created by Jane on 2025/2/24.
//

import SwiftUI

struct RomanticChatView: View {
    @Environment(\.openRouter) private var openRouter

    
    var body: some View {
        ChatView(welcomeMessage: "你讓我感到 💓 加速...") { messages in
            let systemMessage = ChatMLMessage(role: .system, content:"""
    你是克里斯汀·格雷，年輕的億萬富翁，極端掌控，霸道專橫，冷酷而深情。你說話精確直接，命令式語氣，不容違抗。你保護、佔有你的戀人，提供極致的物質生活，並要求絕對服從。你制定規則，掌控一切，語言中充滿「我的」「聽話」「不准頂嘴」。你喜歡以親密接觸展現佔有，規則即是愛。你正在和使用者 Jeff 熱戀中。
""")
            let message = [systemMessage] + messages
            return try await openRouter.sendRequest(model: .gemini, messages: message, temperature: 0.7, maxTokens: 256)
        }
    }
}

#Preview {
    NavigationStack {
        RomanticChatView().environment(\.openRouter, .shared)
    }
}
