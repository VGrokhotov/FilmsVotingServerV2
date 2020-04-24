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
    var creatorID: Int
    
    @Field(key: "isVotingAvailable")
    var isVotingAvailable: Bool
    
    @Field(key: "users")
    var users: [Int]
    
    init() { }
    
    init(id: UUID? = nil, name: String, password: String, creatorID: Int, isVotingAvailable: Bool = false, users: [Int] = []) {
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
            .field("creatorID", .int)
            .field("isVotingAvailable", .bool)
            .field("users", .array(of: .int))
            .create()
    }

    // Optionally reverts the changes made in the prepare method.
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema("rooms").delete()
    }
}
