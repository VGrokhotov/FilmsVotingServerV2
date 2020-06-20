//
//  User.swift
//  
//
//  Created by Владислав on 12.06.2020.
//

import Foundation
import Vapor
import Fluent
import FluentPostgresDriver

final class User: Model, Content{
    
    // Name of the table or collection.
    static let schema = "users"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "name")
    var name: String
    
    @Field(key: "password")
    var password: String
    
    @Field(key: "login")
    var login: String
    
    init() { }
    
    init(id: UUID? = nil, name: String, password: String, login: String) {
        self.id = id
        self.name = name
        self.password = password
        self.login = login
    }
}

struct CreateUser: Migration {
    // Prepares the database for storing Galaxy models.
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema("users")
            .id()
            .field("name", .string)
            .field("password", .string)
            .field("login", .string)
            .create()
    }

    // Optionally reverts the changes made in the prepare method.
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema("users").delete()
    }
}

extension User {
    func toStringJSON() -> String {
        return  """
        {"id": "\(id!)", "name": "\(name)", "password": "\(password)", "login": "\(login)"
        """
    }
}

struct AuthorizationUser: Codable {
    let login: String
    let password: String
}
