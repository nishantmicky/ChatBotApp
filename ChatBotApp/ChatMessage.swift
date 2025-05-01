//
//  ChatMessage.swift
//  ChatBotApp
//
//  Created by Nishant Kumar on 01/05/25.
//

import Foundation

struct ChatMessage: Codable {
    let type: ChatMessageType
    let message: String
    var isFailed: Bool = false
}

enum ChatMessageType: Codable {
    case user
    case bot
}
