//
//  Message.swift
//  
//
//  Created by Владислав on 22.07.2020.
//

import Foundation

struct Message: Codable {
    let type: MessageType
    let content: Data
}

enum MessageType: String, Codable {
    case room = "room"
    case option = "option"
    case connectRoom = "connectRoom"
    case connectOption = "connectOption"
    case disconnect = "disconnect"
}
