//
//  LoadingBubble.swift
//  iOSClubChatBot
//
//  Created by Jane - Apple mac on 2024/11/22.
//

import SwiftUI

struct LoadingBubble: View {
    var body: some View {
        Image(systemName: "ellipsis")
            .font(.system(size: 45))
            .symbolEffect(.breathe)
            .symbolEffect(.variableColor)
            .foregroundStyle(.gray.gradient)
            .transition(.opacity)
            .bubbleMessageStyle(isAIMessage: true)
    }
}

#Preview {
    LoadingBubble()
}
