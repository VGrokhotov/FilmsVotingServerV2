//
//  Room.swift
//  App
//
//  Created by Владислав on 26.03.2020.
//

import Foundation
import Vapor
import Fluent
import FluentPostgresDriver

final class Room: Model, Content{
    
    // Name of the table or collection.
    static let schema = "rooms"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "name")
    var name: String
    
    @Field(key: "password")
    var password: String
    
    @Field(key: "creatorID")
    var creatorID: UUID
    
    @Field(key: "isVotingAvailable")
    var isVotingAvailable: Bool
    
    @Field(key: "users")
    var users: [UUID]
    
    init() { }
    
    init(id: UUID? = nil, name: String, password: String, creatorID: UUID, isVotingAvailable: Bool = false, users: [UUID] = []) {
        self.id = id
        self.name = name
        self.password = password
        self.creatorID = creatorID
        self.isVotingAvailable = isVotingAvailable
        self.users = users
    }
}

struct CreateRoom: Migration {
    // Prepares the database for storing Galaxy models.
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema("rooms")
            .id()
            .field("name", .string)
            .field("password", .string)
            .field("creatorID", .uuid)
            .field("isVotingAvailable", .bool)
            .field("users", .array(of: .uuid))
            .create()
    }

    // Optionally reverts the changes made in the prepare method.
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema("rooms").delete()
    }
}

extension Room {
    func toStringJSON() -> String {
        return  """
        {"id": "\(id!)", "name": "\(name)", "password": "\(password)", "creatorID": "\(creatorID)", "isVotingAvailable": \(isVotingAvailable), "users": \(users)}
        """
    }
    
    func toNotVerifiedRoomStringJSON() -> String {
        return  """
        {"id": "\(id!)", "name": "\(name)"}
        """
    }
}

// MARK: TODO по хорошему нужно гетом отправлять только индификаторы и имя 

struct NotVerifiedRoom: Content {
    let id: UUID?
    let name: String
}

struct AuthorizationRoom: Codable {
    let id: UUID?
    let password: String
}
