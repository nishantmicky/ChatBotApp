//
//  ChatMessage.swift
//  ChatBotApp
//
//  Created by Nishant Kumar on 01/05/25.
//

import Foundation

/// Represents a single message in the chat conversation.
struct ChatMessage: Codable {
    let type: ChatMessageType
    let message: String
    var isFailed: Bool = false
}

/// Represents the sender of a chat message.
enum ChatMessageType: Codable {
    case user
    case bot
}
