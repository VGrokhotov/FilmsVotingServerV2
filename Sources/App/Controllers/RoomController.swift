//
//  RoomController.swift
//  App
//
//  Created by Владислав on 27.03.2020.
//

import Foundation
import Vapor
import Fluent
import FluentPostgresDriver

final class RoomController {
    
    var connections: [WebSocket] = []
    
    //MARK: GET
    
    func all(_ req: Request) throws -> EventLoopFuture<[Room]> {
        return Room.query(on: req.db).all()
    }
    
    func showUsingName(_ req: Request) throws -> EventLoopFuture<Room>{
        if let name = req.parameters.get("name", as: String.self) {
            
            return Room.query(on: req.db)
                .filter(\.$name == name)
                .first()
                .unwrap(or: Abort.init(.notFound))
        }
        
        throw Abort.init(.notFound)
    }
    
    func showUsingId(_ req: Request) throws -> EventLoopFuture<Room> {
        if let id = req.parameters.get("roomID", as: UUID.self) {
            return Room.find(id, on: req.db).unwrap(or: Abort.init(.notFound))
        }
        throw Abort.init(.notFound)
    }
    
    
    //MARK: POST
    
    func create(_ req: Request) throws -> EventLoopFuture<Room> {
        let room = try req.content.decode(Room.self)
        let event = room.create(on: req.db).map { room }
        let _ = event.map { (room) -> (Room) in
            for ws in self.connections {
                ws.send(room.toStringJSON())
            }
            return room
        }
        return event
    }
    
    
    //MARK: PUT
    
    func update(_ req: Request) throws -> EventLoopFuture<Room> {
        
        if let id = req.parameters.get("roomID", as: UUID.self) {
            
            let updatedRoom = try? req.content.decode(Room.self)
            
            if let updatedRoom = updatedRoom{
                return Room.find(id, on: req.db).unwrap(or: Abort.init(.notFound)).map { (room) in
                    room.isVotingAvailable = updatedRoom.isVotingAvailable
                    room.users = updatedRoom.users
                    let _ = room.save(on: req.db)
                    return room
                }
            }
            
            throw Abort.init(.noContent)
        }
        
        throw Abort.init(.notFound)
    }
    
    
    //MARK: DELETE
    
    func delete(_ req: Request) throws -> EventLoopFuture<HTTPStatus> {
        if let id = req.parameters.get("roomID", as: UUID.self) {
            let room = Room.find(id, on: req.db).unwrap(or: Abort.init(.notFound))
            
            return room.flatMap { (room) in
                return room.delete(on: req.db)
            }.transform(to: .ok)
            
        }
        throw Abort.init(.notFound)
    }
    
    //MARK: WebSocket
    
    func onUpgrade(_ req: Request, ws: WebSocket) {
        
        ws.onText { ws, string in
            switch(string){
            case "Connect":
                self.connections.append(ws)
                break
            case "Disconnect":
                if let index = self.connections.firstIndex(where: {$0 === ws}) {
                    self.connections.remove(at: index)
                }
                break
            default:
                break
            }
        }
    }
    
}
