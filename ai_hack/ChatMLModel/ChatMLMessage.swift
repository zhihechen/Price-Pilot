//
//  ChatMLMessage.swift
//  NTUiOSClubLLM
//
//  Created by Jane on 2025/2/22.
//

import Foundation
import UIKit

struct ChatMLMessage: Codable {
    let role: String
    let content: String
    let jpgImagesData: [Data]?
    
    init(role: String, content: String, jpgImagesData: [Data]?) {
        self.role = role
        self.content = content
        self.jpgImagesData = jpgImagesData?.isEmpty == true ? nil : jpgImagesData
    }
}

extension ChatMLMessage {
    init(role: ChatMLRole, content: String, uiImages: [UIImage]?) {
        guard let uiImages else {
            self.init(role: role.rawValue, content: content, jpgImagesData: nil)
            return
        }
        let datas = uiImages.compactMap { $0.jpegData(compressionQuality: 0.7) }
        self.init(role: role.rawValue, content: content, jpgImagesData: datas)
    }
    
    init(role: ChatMLRole, content: String, uiImage: UIImage? = nil) {
        let uiImages: [UIImage]? = if let uiImage { [uiImage] } else { nil }
        self.init(role: role, content: content, uiImages: uiImages)
    }
}

extension ChatMLMessage: CustomStringConvertible {
    var description: String {
        "➡️ \(role):\n\(content)\n"
    }
}

extension [ChatMLMessage] {
    func printPrompt() {
        forEach { print($0.description) }
    }
}
