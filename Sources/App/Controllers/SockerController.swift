//
//  SocketController.swift
//  
//
//  Created by Владислав on 22.07.2020.
//

import Foundation
import Vapor

final class SocketController {
    
    var roomsConnections: [WebSocket] = []
    var optionsConnections: [(WebSocket, UUID)] = []
    
    
    public static let shared = SocketController()
    private init() {}
    
    func onUpgrade(_ req: Request, ws: WebSocket) {
        
        ws.onText { ws, string in
            
            if  let data = string.data(using: .utf8) {
                let message = try? JSONDecoder().decode(Message.self, from: data)
                if let message = message {
                    switch message.type {
                    case .connectRoom:
                        self.roomsConnections.append(ws)
                    case .connectOption:
                        guard
                            let roomID = UUID(uuidString: message.content)
                        else { return }
                        
                        self.optionsConnections.append((ws, roomID))
                    case .disconnect:
                        if let index = self.roomsConnections.firstIndex(where: {$0 === ws}) {
                            self.roomsConnections.remove(at: index)
                        }
                        if let index = self.optionsConnections.firstIndex(where: {$0.0 === ws}) {
                            self.optionsConnections.remove(at: index)
                        }
                    default:
                        break
                    }
                }
            }
//            switch(string){
//            case "Connect":
//                self.roomsConnections.append(ws)
//                break
//            case "Disconnect":
//                if let index = self.roomsConnections.firstIndex(where: {$0 === ws}) {
//                    self.roomsConnections.remove(at: index)
//                }
//                if let index = self.optionsConnections.firstIndex(where: {$0.0 === ws}) {
//                    self.optionsConnections.remove(at: index)
//                }
//                break
//            default:
//                guard
//                    let index = string.firstIndex(of: " "),
//                    let roomID = UUID(String(string[string.index(after: index)...]))
//                else { return } // по хорошему надо что-то писать в обратку
//
//                self.optionsConnections.append((ws, roomID))
//            }
        }
    }
}
