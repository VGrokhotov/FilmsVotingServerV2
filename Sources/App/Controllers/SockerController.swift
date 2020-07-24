//
//  SocketController.swift
//  
//
//  Created by Владислав on 22.07.2020.
//

import Foundation
import Vapor
import Fluent

final class SocketController {
    
    var roomsConnections: [WebSocket] = []
    var optionsConnections: [(WebSocket, UUID)] = []
    
    
    public static let shared = SocketController()
    private init() {}
    
    func onUpgrade(_ req: Request, ws: WebSocket) {
        
        ws.onBinary { (ws, data) in
            if let message = try? JSONDecoder().decode(Message.self, from: data) {
                switch message.type {
                case .connectRoom:
                    self.roomsConnections.append(ws)
                case .connectOption:
                    guard
                        let roomIDData = message.content,
                        let roomID = UUID(uuidString: String(data: roomIDData, encoding: .utf8) ?? "" )
                    else { return }
                    
                    self.optionsConnections.append((ws, roomID))
                case .disconnect:
                    if let index = self.roomsConnections.firstIndex(where: {$0 === ws}) {
                        self.roomsConnections.remove(at: index)
                    }
                    if let index = self.optionsConnections.firstIndex(where: {$0.0 === ws}) {
                        self.optionsConnections.remove(at: index)
                    }
                case .disconnectFromOption:
                    if let index = self.optionsConnections.firstIndex(where: {$0.0 === ws}) {
                        self.optionsConnections.remove(at: index)
                    }
                case .startVoting:
                    guard
                        let roomIDData = message.content,
                        let receivedRoomID = UUID(uuidString: String(data: roomIDData, encoding: .utf8) ?? "" )
                    else { return }
                    
                    let message = Message(type: .startVoting, content: nil)
                    if let messageData = try? JSONEncoder().encode(message) {
                        let sendData = [UInt8](messageData)
                        for (ws, roomID) in self.optionsConnections {
                            if roomID == receivedRoomID {
                                ws.send(sendData)
                            }
                        }
                    }
                    
                case .endVoting:
                    guard
                        let roomIDData = message.content,
                        let receivedRoomID = UUID(uuidString: String(data: roomIDData, encoding: .utf8) ?? "" )
                    else { return }
                    
                    let message = Message(type: .endVoting, content: nil)
                    if let messageData = try? JSONEncoder().encode(message) {
                        let sendData = [UInt8](messageData)
                        for (ws, roomID) in self.optionsConnections {
                            if roomID == receivedRoomID {
                                ws.send(sendData)
                            }
                        }
                    }
                case .exit:
                    guard
                        let roomIDData = message.content,
                        let receivedRoomID = UUID(uuidString: String(data: roomIDData, encoding: .utf8) ?? "" )
                    else { return }
                    
                    let message = Message(type: .exit, content: nil)
                    if let messageData = try? JSONEncoder().encode(message) {
                        let sendData = [UInt8](messageData)
                        for (ws, roomID) in self.optionsConnections {
                            if roomID == receivedRoomID {
                                ws.send(sendData)
                            }
                        }
                    }
                default:
                    break
                }
            }
        }
        
    }
}
