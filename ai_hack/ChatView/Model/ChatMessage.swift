//
//  ChatMessage.swift
//  NTUiOSClubLLM
//
//  Created by Jane on 2025/2/22.
//

import Foundation

struct ChatMessageViewModel: Identifiable {
    let id: UUID
    let role: ChatMLRole
    let content: String
    
    init(id: UUID = UUID() , role: ChatMLRole, content: String) {
        self.id = id
        self.role = role
        self.content = content
    }
}
