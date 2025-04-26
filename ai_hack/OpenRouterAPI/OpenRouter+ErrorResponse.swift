//
//  OpenRouterErrorResponse.swift
//  NTUiOSClubLLM
//
//  Created by Jane on 2025/2/23.
//

struct OpenRouterErrorResponse: Decodable {
    let error: Error
    
    struct Error: Decodable {
        let code: Int
        let message: String
    }
}
