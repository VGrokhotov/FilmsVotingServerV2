//
//  OptionController.swift
//  
//
//  Created by Владислав on 13.06.2020.
//

import Foundation
import Vapor
import Fluent
import FluentPostgresDriver

final class OptionController {
    
    var connections: [(WebSocket, UUID)] = []
    
    //MARK: GET
    
    func all(_ req: Request) throws -> EventLoopFuture<[Option]> {
        return Option.query(on: req.db).all()
    }
    
    func showUsingRoomID(_ req: Request) throws -> EventLoopFuture<[Option]>{
        if let roomID = req.parameters.get("roomID", as: UUID.self) {
            
            return Option.query(on: req.db)
                .filter(\.$roomID == roomID).all()
        }
        
        throw Abort.init(.notFound)
    }
    
    func showUsingId(_ req: Request) throws -> EventLoopFuture<Option> {
        if let id = req.parameters.get("optionID", as: UUID.self) {
            return Option.find(id, on: req.db).unwrap(or: Abort.init(.notFound))
        }
        throw Abort.init(.notFound)
    }
    
    
    //MARK: POST
    
    func create(_ req: Request) throws -> EventLoopFuture<Option> {
        let option = try req.content.decode(Option.self)
        let createdOptionRoomID = option.roomID
        let event = option.create(on: req.db).map { option }
        let _ = event.map { (option) -> (Option) in
            for (ws, roomID) in self.connections {
                if roomID == createdOptionRoomID {
                    ws.send(option.toStringJSON())
                }
            }
            return option
        }
        return event
    }
    
    
    //MARK: PUT
    
    func update(_ req: Request) throws -> EventLoopFuture<Option> {
        
        if let id = req.parameters.get("optionID", as: UUID.self) {
            
            let updatedOption = try? req.content.decode(Option.self)
            
            if let updatedOption = updatedOption{
                return Option.find(id, on: req.db).unwrap(or: Abort.init(.notFound)).map { (option) in
                    option.vote = updatedOption.vote
                    let _ = option.save(on: req.db)
                    return option
                }
            }
            
            throw Abort.init(.noContent)
        }
        
        throw Abort.init(.notFound)
    }
    
    
    //MARK: DELETE
    
    func delete(_ req: Request) throws -> EventLoopFuture<HTTPStatus> {
        if let id = req.parameters.get("optionID", as: UUID.self) {
            let option = Option.find(id, on: req.db).unwrap(or: Abort.init(.notFound))
            
            return option.flatMap { (option) in
                return option.delete(on: req.db)
            }.transform(to: .ok)
            
        }
        throw Abort.init(.notFound)
    }
    
    func deleteAllWithRoomID(_ req: Request) throws -> EventLoopFuture<HTTPStatus> {
        if let roomID = req.parameters.get("roomID", as: UUID.self) {
            return Option.query(on: req.db)
                .filter(\.$roomID == roomID)
                .delete()
                .transform(to: .ok)
        }
        throw Abort.init(.notFound)
    }
    
    //MARK: WebSocket
    
    func onUpgrade(_ req: Request, ws: WebSocket) {

        ws.onText { ws, string in
            if string.starts(with: "Connect, ") {
                guard let index = string.firstIndex(of: " ") else { return } // по хорошему надо что-то писать в обратку
                guard let roomID = UUID(String(string[index...])) else { return } // по хорошему надо что-то писать в обратку
                self.connections.append((ws, roomID))
            } else if string == "Disconnect" {
                if let index = self.connections.firstIndex(where: {$0.0 === ws}) {
                    self.connections.remove(at: index)
                }
            }
        }
    }
    
}

