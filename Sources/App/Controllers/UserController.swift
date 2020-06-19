//
//  UserController.swift
//  
//
//  Created by Владислав on 12.06.2020.
//


import Foundation
import Vapor
import Fluent
import FluentPostgresDriver

final class UserController {
    
    //MARK: GET
    
    func all(_ req: Request) throws -> EventLoopFuture<[User]> {
        return User.query(on: req.db).all()
    }
    
    func showUsingLogin(_ req: Request) throws -> EventLoopFuture<User>{
        if let login = req.parameters.get("login", as: String.self) {
            
            guard let password = req.query[String.self, at: "password"] else {
                throw Abort(HTTPResponseStatus.init(statusCode: 400, reasonPhrase: "Wrong user password"))
            }
            
            return User.query(on: req.db)
                .filter(\.$login == login)
                .first()
                .unwrap(or: Abort.init(.notFound))
                .flatMapThrowing { (user) -> User in
                    if user.password != password {
                        throw Abort.init(HTTPResponseStatus.init(statusCode: 400, reasonPhrase: "Wrong user password"))
                    }
                    return user
            }
    
        }
        
        throw Abort.init(.notFound)
    }
    
    func showUsingId(_ req: Request) throws -> EventLoopFuture<User> {
        if let id = req.parameters.get("userID", as: UUID.self) {
            return User.find(id, on: req.db).unwrap(or: Abort.init(.notFound))
        }
        throw Abort.init(.notFound)
    }
    
    
    //MARK: POST
    
    func create(_ req: Request) throws -> EventLoopFuture<User> {
        let user = try req.content.decode(User.self)
        return user.create(on: req.db).map { user }
    }
    
    
    //MARK: PUT
    
    func update(_ req: Request) throws -> EventLoopFuture<User> {
        
        if let id = req.parameters.get("userID", as: UUID.self) {
            
            let updatedUser = try? req.content.decode(User.self)
            
            if let updatedUser = updatedUser{
                return User.find(id, on: req.db).unwrap(or: Abort.init(.notFound)).map { (user) in
                    user.name = updatedUser.name
                    user.password = updatedUser.password
                    let _ = user.save(on: req.db)
                    return user
                }
            }
            
            throw Abort.init(.noContent)
        }
        
        throw Abort.init(.notFound)
    }
    
    
    //MARK: DELETE
    
    func delete(_ req: Request) throws -> EventLoopFuture<HTTPStatus> {
        if let id = req.parameters.get("userID", as: UUID.self) {
            let user = User.find(id, on: req.db).unwrap(or: Abort.init(.notFound))
            
            return user.flatMap { (user) in
                return user.delete(on: req.db)
            }.transform(to: .ok)
            
        }
        throw Abort.init(.notFound)
    }
    
}

