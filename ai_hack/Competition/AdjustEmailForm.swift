//
//  AdjustEmailForm.swift
//  NTUiOSClubLLM
//
//  Created by Jane on 2025/2/24.
//

import SwiftUI

struct AdjustEmailForm: View {
    @Environment(\.dismiss) private var dismiss

    @State var aiWrittenEmailContent: String
    let onRequestChanges: (EmailModificationRequest) async throws -> String
    
    @State private var contentID: UUID = UUID()
    @State private var isProcessing: Bool = false
    @State private var adjustmentInput: String = ""

    var body: some View {
        VStack(spacing: 24) {
            ScrollView {
                Text(aiWrittenEmailContent)
                    .transition(.slide.combined(with: .opacity))
                    .id(contentID)
                    .lineSpacing(8)
                    .padding(16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
            }
            .defaultScrollAnchor(.top)
            .background(Color(.secondarySystemGroupedBackground), in: .rect(cornerRadius: 16))
           

            MyTextEditor(text: $adjustmentInput, prompt: "輸入調整要求...")
                .frame(height: 120)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color(.secondarySystemGroupedBackground), in: .rect(cornerRadius: 16))
            
            sendButton
                .disabled(adjustmentInput.isEmpty)
        }
        .padding(16)
        .disabled(isProcessing)
        .animation(.smooth.speed(0.7), value: contentID)
        .background(Color(.systemGroupedBackground))
        .navigationTitle("AI Email 內容調整")
        .toolbar{
            Button("複製內容", systemImage: "document.on.document") {
                UIPasteboard.general.string = aiWrittenEmailContent
            }
        }
    }

    var sendButton: some View {
        Button(action: sendMessages) {
            Text("修正")
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

    func sendMessages() {
        Task {
            isProcessing = true
            defer {
                isProcessing = false
            }
            do {
                let updatedContent = try await onRequestChanges(
                    EmailModificationRequest(originalContent: aiWrittenEmailContent,
                                             request: adjustmentInput)
                )

                self.contentID = UUID()
                self.aiWrittenEmailContent = updatedContent
            } catch {
                print(error)
            }
        }
    }
}

extension AdjustEmailForm {
    struct EmailModificationRequest {
        let originalContent: String
        let request: String
    }
}

#Preview {
    NavigationStack {
        AdjustEmailForm(
            aiWrittenEmailContent: "老闆：我已經在這間公司待一年了薪水卻沒有變動，如果不幫我加薪我就要離職了", onRequestChanges: {
                try? await Task.sleep(for: .seconds(1))
                return "***這是一段假的回傳，直接回傳原本的請求內容***\n\($0.request)"
            }
        ).environment(\.openRouter, .shared)
    }
}
