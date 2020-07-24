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
    
    //MARK: GET
    
    func all(_ req: Request) throws -> EventLoopFuture<[Option]> {
        return Option.query(on: req.db).all()
    }
    
//    func showUsingId(_ req: Request) throws -> EventLoopFuture<Option> {
//        if let id = req.parameters.get("optionID", as: UUID.self) {
//            return Option.find(id, on: req.db).unwrap(or: Abort.init(.notFound))
//        }
//        throw Abort.init(.notFound)
//    }
    
    
    //MARK: POST
    
    func create(_ req: Request) throws -> EventLoopFuture<Option> {
        let option = try req.content.decode(Option.self)
        let createdOptionRoomID = option.roomID
        let event = option.create(on: req.db).map { option }
        let _ = event.map { (option) -> (Option) in
            if let optionData = try? JSONEncoder().encode(option) {
                let message = Message(type: .option, content: optionData)
                if let messageData = try? JSONEncoder().encode(message) {
                    let sendData = [UInt8](messageData)
                    for (ws, roomID) in SocketController.shared.optionsConnections {
                        if roomID == createdOptionRoomID {
                            ws.send(sendData)
                        }
                    }
                }
            }
            return option
        }
        return event
    }
    
    func showUsingRoomID(_ req: Request) throws -> EventLoopFuture<[Option]> {
        
        let optionSelector = try req.content.decode(OptionSelector.self)
        
        return Option.query(on: req.db)
            .filter(\.$roomID == optionSelector.roomID).all()
    }
    
    //MARK: PUT
    
    func update(_ req: Request) throws -> EventLoopFuture<Option> {
        
        let optionID = try req.content.decode(OptionID.self)
        
        return Option
            .find(optionID.id, on: req.db)
            .unwrap(or: Abort.init(.notFound))
            .map { (option) in
                option.vote += 1
                let _ = option.save(on: req.db)
                return option
            }
        
    }
    
    
    //MARK: DELETE
    
    func delete(_ req: Request) throws -> EventLoopFuture<HTTPStatus> {
        
        let optionID = try req.content.decode(OptionID.self)
        
        let option = Option.find(optionID.id, on: req.db).unwrap(or: Abort.init(.notFound))
        
        return option.flatMap { (option) in
            return option.delete(on: req.db)
        }.transform(to: .ok)
        
        
    }
    
    func deleteAllWithRoomID(_ req: Request) throws -> EventLoopFuture<HTTPStatus> {
        
        let optionSelector = try req.content.decode(OptionSelector.self)
        
        return Option.query(on: req.db)
            .filter(\.$roomID == optionSelector.roomID)
            .delete()
            .transform(to: .ok)
        
    }
    
}

