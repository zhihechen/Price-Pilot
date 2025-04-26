//
//  MyTextEditor.swift
//  NTUiOSClubLLM
//
//  Created by Jane on 2025/2/24.
//

import SwiftUI

struct MyTextEditor: View {
    @Binding var text: String
    let prompt: String
    
    var body: some View {
        TextEditor(text: $text)
            .overlay(alignment: .topLeading) {
                Text(prompt)
                    .foregroundStyle(.secondary)
                    .padding(5)
                    .padding(.top, 3)
                    .opacity(text.isEmpty ? 1 : 0)
            }
    }
}

#Preview {
    @Previewable @State var text: String = ""
    Form {
        MyTextEditor(text: $text, prompt: "請輸入內容...")
            .frame(height: 120)
    }
}
