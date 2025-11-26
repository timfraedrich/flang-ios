//
//  ChatMessageParams.swift
//  FlangCore
//
//  Created by Tim Fraedrich on 21.11.25.
//


struct ChatMessageParameters: Codable {
    let text: String  // Base64URL encoded
    let attachedGame: String?  // Base64URL encoded
}
