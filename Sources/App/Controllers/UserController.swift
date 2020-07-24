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
    
//    func showUsingId(_ req: Request) throws -> EventLoopFuture<User> {
//        if let id = req.parameters.get("userID", as: UUID.self) {
//            return User.find(id, on: req.db).unwrap(or: Abort.init(.notFound))
//        }
//        throw Abort.init(.notFound)
//    }
    
    
    //MARK: POST
    
    func create(_ req: Request) throws -> EventLoopFuture<User> {
        let user = try req.content.decode(User.self)
        return user.create(on: req.db).map { user }
    }
    
    func showUsingLogin(_ req: Request) throws -> EventLoopFuture<User>{
        
        let authorizationUser = try req.content.decode(AuthorizationUser.self)
        
        return User.query(on: req.db)
            .filter(\.$login == authorizationUser.login)
            .first()
            .unwrap(or: Abort.init(HTTPResponseStatus.custom(code: 404, reasonPhrase: "Cannot find user with such login")))
            .flatMapThrowing { (user) -> User in
                if user.password != authorizationUser.password {
                    throw Abort.init(HTTPResponseStatus.custom(code: 400, reasonPhrase: "Wrong user password"))
                }
                return user
        }
    }
    
    //MARK: PUT
    
//    func update(_ req: Request) throws -> EventLoopFuture<User> {
//        
//        if let id = req.parameters.get("userID", as: UUID.self) {
//            
//            let updatedUser = try? req.content.decode(User.self)
//            
//            if let updatedUser = updatedUser{
//                return User.find(id, on: req.db).unwrap(or: Abort.init(.notFound)).map { (user) in
//                    user.name = updatedUser.name
//                    user.password = updatedUser.password
//                    let _ = user.save(on: req.db)
//                    return user
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
        
        let userID = try req.content.decode(UserID.self)
        
        let user = User.find(userID.id, on: req.db).unwrap(or: Abort.init(.notFound))
        
        return user.flatMap { (user) in
            return user.delete(on: req.db)
        }.transform(to: .ok)
            
    }
    
}

