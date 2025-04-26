//
//  ChatView.swift
//  iOSClubChatBot
//
//  Created by Jane - Apple mac on 2024/11/22.
//

import SwiftUI

typealias ChatCompletion = ([ChatMLMessage]) async throws -> ChatMLMessage

struct ChatView: View {
    var welcomeMessage: String
    @State var messages: [ChatMessageViewModel]
    let chatCompletion: ChatCompletion
    @State private var inputText: String = ""

    @State private var isLoading: Bool = false
    @State private var shouldShowErrorAlert: Bool = false

    private var canSubmitNewMessage: Bool {
        !isLoading && !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    init(
        welcomeMessage: String = "Hello, how can I help you today?",
        initialMessages messages: [ChatMessageViewModel] = [],
        chatCompletion: @escaping ChatCompletion
    ) {
        self.welcomeMessage = welcomeMessage
        self.messages = messages
        self.chatCompletion = chatCompletion
    }

    var body: some View {
        VStack {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 16) {
                    ForEach(messages, content: MessageBubble.init)

                    if isLoading {
                        LoadingBubble()
                    }
                }
                .padding(16)
            }
            .animation(.smooth, value: isLoading)
            .defaultScrollAnchor(.bottom)
            .overlay(alignment: .top) {
                if messages.isEmpty {
                    welcomeMessageView
                }
            }
            .animation(.smooth, value: messages.count)

            textField
        }
        .navigationBarTitleDisplayMode(.inline)
        .alert("無法完成您的請求", isPresented: $shouldShowErrorAlert) {
            
        } message: {
            Text("請確認您的網路連線狀態。如果這個問題持續發生，請聯絡客服。")
        }
    }
}

// MARK: - Subview
extension ChatView {
    fileprivate var welcomeMessageView: some View {
        Text(welcomeMessage)
            .foregroundStyle(.accent)
            .font(.largeTitle)
            .frame(maxWidth: .infinity, alignment: .leading)
            .fontDesign(.serif)
            .padding()
            .padding(.horizontal)
            .transition(.move(edge: .top).combined(with: .opacity))
    }

    fileprivate var textField: some View {
        HStack(spacing: 16) {
            TextField("輸入你的訊息...", text: $inputText)
                .textFieldStyle(.roundedBorder)
                .onSubmit {
                    sendMessage()
                }

            Button(action: sendMessage) {
                Label("Send", systemImage: "paperplane.fill")
                    .labelStyle(.iconOnly)
                    .foregroundStyle(.white)
                    .padding(8)
                    .background(Color.accent.gradient.opacity(canSubmitNewMessage ? 1 : 0.5),
                                in: .capsule)
                    .grayscale(canSubmitNewMessage ? 0 : 1)
            }
            .disabled(!canSubmitNewMessage)
        }
        .padding(16)
        .background(.ultraThinMaterial)
    }
}

// MARK: - Action
extension ChatView {
    fileprivate func sendMessage() {
        guard canSubmitNewMessage else { return }

        let inputText = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !inputText.isEmpty else { return }

        isLoading = true

        let userMessage = ChatMessageViewModel(role: .user, content: inputText)
        messages.append(userMessage)
        self.inputText = ""

        Task {
            do {
                let response = try await chatCompletion(
                    messages.map { .init(role: $0.role, content: $0.content) }
                )
                let aiMessage = ChatMessageViewModel(role: .ai, content: response.content)
                messages.append(aiMessage)
            } catch {
                shouldShowErrorAlert = true
                _ = messages.popLast()
                self.inputText = inputText
                print("❌ \(error)")
            }
            isLoading = false
        }
    }
}

#if DEBUG

private let stubChatCompletion: ChatCompletion = { messages in
    let lastMessage = messages.last!.content
    try? await Task.sleep(for: .seconds(1))
    return ChatMLMessage(role: .ai, content: "假的回應: \(lastMessage)")
}

#Preview("空白畫面") {
    ChatView(chatCompletion: stubChatCompletion)
}

#Preview("短對話") {
    ChatView(initialMessages: Array([ChatMessageViewModel].stub.prefix(2)), chatCompletion: stubChatCompletion)
}

#Preview("長對話") {
    ChatView(initialMessages: .stub, chatCompletion: stubChatCompletion)
}

#endif
