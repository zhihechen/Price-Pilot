//
//  ChatMLMessage+Codable.swift
//  NTUiOSClubLLM
//
//  Created by Jane on 2025/2/28.
//

import Foundation

private let jpgHeader = "data:image/jpeg;base64,"

extension ChatMLMessage {
    init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        let object = try container.decode(ChatMLMessageCodableObject.self)
        
        var text: String?
        var images: [Data] = []
        
        object.content.forEach {
            switch $0 {
                case .text(let string):
                    text = string
                case .image(let imageObject):
                    let imageString = imageObject.base64String.trimmingPrefix(jpgHeader)
                    if let data = Data(base64Encoded: String(imageString)) {
                        images.append(data)
                    }
            }
        }
        
        guard let text else {
            throw DecodingError.valueNotFound(String.self, .init(codingPath: [], debugDescription: "找不到文字訊息"))
        }
        
        
        self.role = object.role
        self.content = text
        self.jpgImagesData = images
    }
    
    func encode(to encoder: any Encoder) throws {
        let object = ChatMLMessageCodableObject(self)
        var container = encoder.singleValueContainer()
        try container.encode(object)
    }
}

struct ChatMLMessageCodableObject: Codable {
    let role: String
    let content: [Content]
    
    init(role: String, content: [Content]) {
        self.role = role
        self.content = content
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.role = try container.decode(String.self, forKey: .role)
        if let content = try? container.decode([ChatMLMessageCodableObject.Content].self, forKey: .content) {
            self.content = content
        } else {
            let plainText = try container.decode(String.self, forKey: .content)
            self.content = [.text(plainText.trimmingCharacters(in: .whitespacesAndNewlines))]
        }
    }
    
    enum Content: Codable {
        case text(String)
        case image(ImageObject)
        
        enum CodingKeys: String, CodingKey {
            case type
            case text
            case image = "image_url"
        }
        
        var type: String {
            switch self {
                case .text: "text"
                case .image: "image_url"
            }
        }
        
        func encode(to encoder: any Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(type, forKey: .type)
            switch self {
                case .text(let string):
                    try container.encode(string, forKey: .text)
                case .image(let imageObject):
                    try container.encode(imageObject, forKey: .image)
            }
        }
        
        init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            if let text = try container.decodeIfPresent(String.self, forKey: .text) {
                self = .text(text.trimmingCharacters(in: .whitespacesAndNewlines))
            } else {
                let image = try container.decode(ImageObject.self, forKey: .image)
                self = .image(image)
            }
        }
        
        
        struct ImageObject: Codable {
            let base64String: String
            
            enum CodingKeys: String, CodingKey {
                case base64String = "url"
            }
        }
    }
}

extension ChatMLMessageCodableObject {
    init(_ message: ChatMLMessage) {
        guard let jpgImagesData = message.jpgImagesData, !jpgImagesData.isEmpty else {
            self.init(role: message.role, content: [.text(message.content)])
            return
        }
        
        let images = jpgImagesData.map { data in
            let base64String = data.base64EncodedString()
            let base64WithHeader = jpgHeader + base64String
            return Content.image(.init(base64String: base64WithHeader))
        }
        
        
        self.init(
            role: message.role,
            content: [.text(message.content)] + images
        )
    }
}
