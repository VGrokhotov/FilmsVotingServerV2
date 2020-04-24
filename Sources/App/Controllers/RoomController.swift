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
    
//    func showUsingName(_ req: Request) throws -> EventLoopFuture<Room>{
//        if let name = req.parameters.get("name") {
//            return req.withPooledConnection(to: .psql) { connection in
//                return connection.select()
//                    .all().from(Room.self)
//                    .where(\Room.name == name)
//                    .all(decoding: Room.self).map { rows in
//                        if rows.count == 0{
//                            throw RoutingError.init(identifier: "404", reason: "There is no room with login \(name)")
//                        } else {
//                            return rows[0]
//                        }
//                }
//            }
//        }
//
//    }
    
    func showUsingId(_ req: Request) throws -> EventLoopFuture<Room> {
        if let id = req.parameters.get("roomID", as: UUID.self) {
            var flag = true
            let room = Room.find(id, on: req.db).map { (room) -> (Room) in
                if let room = room {
                    return room
                } else {
                    flag = false
                    return Room()
                }
            }
            if flag {
                return room
            }
//            let ourRoom = try? room.wait()
//
//            if let _ = ourRoom?.id {
//                return room
//            }
            throw Abort.init(.notFound)
        }
        throw Abort.init(.notFound)
    }
    
    
    
    
    //MARK: POST
    
    func create(_ req: Request) throws -> EventLoopFuture<Room> {
        let room = try req.content.decode(Room.self)
        return room.create(on: req.db).map { room }
    }
    
    
    //MARK: PUT
    
//    func update(_ req: Request) throws -> EventLoopFuture<Room> {
//        return try flatMap(to: Room.self, req.parameters.next(Room.self), req.content.decode(Room.self)) { room, updatedRoom in
//            room.name = updatedRoom.name
////            room.password = updatedRoom.password
////            room.creatorID = updatedRoom.creatorID
//            room.isVotingAvailable = updatedRoom.isVotingAvailable
//            room.users = updatedRoom.users
//            return room.save(on: req)
//        }
//    }
    
    
    //MARK: DELETE
    
//    func delete(_ req: Request) throws -> EventLoopFuture<HTTPStatus> {
//        return try req.parameters.next(Room.self).flatMap(to: Void.self) { room in
//            return room.delete(on: req)
//        }.transform(to: .ok)
//    }
    
}
