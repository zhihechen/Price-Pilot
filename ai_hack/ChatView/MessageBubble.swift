//
//  MessageBubble.swift
//  iOSClubChatBot
//
//  Created by Jane - Apple mac on 2024/11/22.
//

import SwiftUI

struct MessageBubble: View {
    let message: ChatMessageViewModel

    var body: some View {
        Text(message.content)
            .bubbleMessageStyle(isAIMessage: message.role == .ai)

    }
}

extension View {
    func bubbleMessageStyle(isAIMessage: Bool) -> some View {
        self
            .padding(16)
            .frame(minHeight: 48)
            .foregroundStyle(isAIMessage ? Color(.label) : .white)
            .background(
                isAIMessage ? Color(.systemGray6) : Color.accent,
                in: .rect(cornerRadius: 16)
            )
            .frame(
                maxWidth: .infinity,
                alignment: isAIMessage ? .leading : .trailing
            )
            .transition(
                .move(edge: isAIMessage ? .leading : .trailing)
                    .combined(with: .opacity))
    }
}
