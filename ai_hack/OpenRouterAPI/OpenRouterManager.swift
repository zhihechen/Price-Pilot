//
//  OpenRouterManager.swift
//  NTUiOSClubLLM
//
//  Created by Jane on 2025/2/22.
//

import Foundation

final class OpenRouterManager: OpenRouterAPIProvider {
    private let baseURL = URL(string: "https://openrouter.ai/api/v1/chat/completions")!
    private let session: URLSession
    
    static let shared = OpenRouterManager()
    
    init() {
        let config = URLSessionConfiguration.default
        var header = config.httpAdditionalHeaders ?? [:]
        header["Authorization"] = "Bearer \(Constant.openRouterAPIKey)"
        header["Content-Type"] = "application/json"
        config.httpAdditionalHeaders = header
        
        self.session = URLSession(configuration: config)
    }
    
    
    func sendRequest(model: OpenRouterModel, messages: [ChatMLMessage], temperature: Double, maxTokens: Int) async throws -> ChatMLMessage {
        let chatRequest = ChatRequest(model: model, messages: messages, temperature: temperature, maxTokens: maxTokens)
        let chatData = try JSONEncoder().encode(chatRequest)
        var urlRequest = URLRequest(url: baseURL)
        urlRequest.httpMethod = "POST"
        urlRequest.httpBody = chatData
        
        let response = try await session.sendHTTPRequest(urlRequest, responseType: ChatResponse.self)
        
        guard let newMessage = response.choices.first else {
            print("❌ 沒有回傳訊息")
            throw OpenRouterError.unknown
        }
        
        return newMessage.message
    }
}

private extension URLSession {
    func sendHTTPRequest<Response: Decodable>(_ request: URLRequest, responseType: Response.Type, retry: Int = 1) async throws -> Response {
        let (data, response) = try await data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            print("❌ 不是 HTTP 請求")
            throw OpenRouterError.invalidURL
        }
        
        guard 200...299 ~= httpResponse.statusCode else {
            print("❌ 非正常狀態碼：\(httpResponse.statusCode)")
            throw OpenRouterError.badResponseStatusCode(httpResponse.statusCode)
        }
        
        do {
            let decodedData = try JSONDecoder().decode(responseType, from: data)
            return decodedData
            
        } catch {
            if let errorResponse = (try? JSONDecoder().decode(OpenRouterErrorResponse.self, from: data))?.error {
                switch errorResponse.code {
                    case 429:
                        if retry > 0 {
                            print("⏳ 超過額度，將自動於一秒後重試")
                            try await Task.sleep(for: .seconds(1))
                            return try await sendHTTPRequest(request, responseType: responseType, retry: retry - 1)
                        } else {
                            print("❌ 超過額度")
                            throw OpenRouterError.rateLimitReached
                        }
                        
                    default:
                        print("❌ error \(errorResponse.code): \(errorResponse.message)")
                }
                throw OpenRouterError.badResponseStatusCode(errorResponse.code)
            }
            
            if let data = String(data: data, encoding: .utf8) {
                print("❌ 轉換成 JSON 失敗：\(data)")
            }
            throw error
        }
    }
}
