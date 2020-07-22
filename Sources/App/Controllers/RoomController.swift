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
    
    //MARK: GET
    
    func all(_ req: Request) throws -> EventLoopFuture<[Room]> {
        return Room.query(on: req.db).all()
    }
    
    func allWithoutValidation(_ req: Request) throws -> EventLoopFuture<[NotVerifiedRoom]> {
        return Room.query(on: req.db).all().map { (rooms) -> [NotVerifiedRoom] in
            var notValidatedRooms = [NotVerifiedRoom]()
            for room in rooms {
                let notValidatedRoom = NotVerifiedRoom(id: room.id, name: room.name)
                notValidatedRooms.append(notValidatedRoom)
            }
            return notValidatedRooms
        }
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
    
    
    //MARK: POST
    
    func create(_ req: Request) throws -> EventLoopFuture<Room> {
        let room = try req.content.decode(Room.self)
        let event = room.create(on: req.db).map { room }
        let _ = event.map { (room) -> (Room) in
            for ws in SocketController.shared.roomsConnections {
                let message = Message(type: .room, content: room.toNotVerifiedRoomStringJSON())
                ws.send(message.toString())
            }
            return room
        }
        return event
    }
    
    func showUsingId(_ req: Request) throws -> EventLoopFuture<Room>{
        
        let authorizationRoom = try req.content.decode(AuthorizationRoom.self)
        
        return Room
            .find(authorizationRoom.id, on: req.db)
            .unwrap(or: Abort.init(HTTPResponseStatus.custom(code: 404, reasonPhrase: "Cannot find this room, try to refresh Room's list")))
            .flatMapThrowing { (room) -> Room in
                if room.password != authorizationRoom.password {
                    throw Abort.init(HTTPResponseStatus.custom(code: 400, reasonPhrase: "Wrong room password"))
                }
                return room
        }
    }
    
    
    //MARK: PUT
//
//    func update(_ req: Request) throws -> EventLoopFuture<Room> {
//
//        if let id = req.parameters.get("roomID", as: UUID.self) {
//
//            let updatedRoom = try? req.content.decode(Room.self)
//
//            if let updatedRoom = updatedRoom{
//                return Room.find(id, on: req.db).unwrap(or: Abort.init(.notFound)).map { (room) in
//                    //TO CHANGE SOMETHING
//                    let _ = room.save(on: req.db)
//                    return room
//                }
//            }
//
//            throw Abort.init(.noContent)
//        }
//
//        throw Abort.init(.notFound)
//    }
    
    
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
    
}
