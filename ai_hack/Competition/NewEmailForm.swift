//
//  NewEmailForm.swift
//  NTUiOSClubLLM
//
//  Created by Jane on 2025/2/24.
//

import SwiftUI

struct NewEmailForm: View {
    @Environment(\.openRouter) private var openRouter
    @State private var isProcessing: Bool = false
    @State private var userRequest: String = "不給我加薪我就要離職"
    @Binding var navigationPath: NavigationPath
    @State private var selectedStyle: EmailStyle = .convo
    
    var body: some View {
        Form {
            HStack {
                Rectangle()
                    .frame(width: 10)
                    .foregroundStyle(.accent)
                Text("🤖")
                    .font(.largeTitle)
                Text("請提供以下資訊，讓我幫你轉寫一封專業的信！")
                    .padding(.vertical, 16)
            }
            .listRowInsets(.init())
            Section("風格"){
                Picker("風格", selection: $selectedStyle) {
                    ForEach(EmailStyle.allCases, id: \.self) { style in
                        Text(style.name)
                    }
                }
            }.labelsHidden()
                .pickerStyle(.segmented)
                .listRowBackground(Color.clear)
                .listRowInsets(.init())
            Section("描述 email 目的與需求") {
                TextEditor(text: $userRequest)
                    .frame(height: 90)
            }
            
            sendButton
                .disabled(userRequest.isEmpty)
        }
        .disabled(isProcessing)
        .navigationDestination(for: String.self) { string in
                    AdjustEmailForm(aiWrittenEmailContent: string, onRequestChanges: updateEmail)
                }
    }
    
    
    var sendButton: some View {
        Button(action: generateInitialEmail) {
            Text("送出")
                .frame(maxWidth: .infinity)
                .bold()
                .font(.title3)
        }
        .buttonStyle(.borderedProminent)
        .overlay {
            ProgressView()
                .opacity(isProcessing ? 1 : 0)
                .controlSize(.extraLarge)
        }
        .listRowBackground(Color.clear)
        .listRowInsets(.init())
    }
}

extension NewEmailForm {
    // TODO: 在這設定系統訊息
    var systemMessage: ChatMLMessage {
        ChatMLMessage(role: .system, content: """
            你是寫 email 的專家，你的工作是把使用者提供的內容轉換成 email 的形式。你的用語應符合使用者的要求，直接提供 email，不聊天
            # 今天日期：\(Date.now.formatted(date: .abbreviated, time: .omitted))
            """)
    }
    
    // TODO: 在這設定使用者的第一個訊息
    var userInitialRequestMessage: ChatMLMessage{
        let style: String = switch selectedStyle {
            case .convo: "朋友間的隨性自然口語"
            case .bussiness: "簡潔俐落、business casual"
        }
        return ChatMLMessage(role: .user, content: """
            我是Jeff, 一名大學生
            請幫用我寫這封 email
            * 風格：
            \(style)
            * 我想說的是：
            \(userRequest)
            ---
            直接回覆台灣繁體中文的 email 標題和內文：
            """)
    }

    func generateInitialEmail() {
        Task {
            isProcessing = true
            defer {
                isProcessing = false
            }
            do {
                // TODO: 在這呼叫 api，寫初始的 email
                let messages = [systemMessage, userInitialRequestMessage]
                let response = try await openRouter.sendRequest(model: .gemini, messages: messages, temperature: 0.7, maxTokens: 1024)
                navigationPath.append(response.content)
            } catch {
                print(error)
            }
        }
    }
    
    func updateEmail(request: AdjustEmailForm.EmailModificationRequest) async throws -> String {
        // TODO: 在這呼叫 api 更新 email 內容，你可以在 request 中拿到原本的 email 內容和使用者要求的更新
        let messages = [
            systemMessage,
            userInitialRequestMessage,
            .init(role: .ai, content: request.originalContent),
            .init(role: .user, content: request.request)
            ]
        let response = try await openRouter.sendRequest(
            model: .gemini,
            messages: messages,
            temperature: 0.3,
            maxTokens: 1024
            )
        
        return response.content
    }
    
    private enum EmailStyle: CaseIterable {
        case convo
        case bussiness
        
        var name: String {
            switch self {
            case .convo:
                return " conversational"
            case .bussiness:
                return " business"
            }
        }
    }
}


#Preview {
    @Previewable @State var path = NavigationPath()
    NavigationStack(path: $path) {
        NewEmailForm(navigationPath: $path).environment(\.openRouter, .shared)
    }
}
