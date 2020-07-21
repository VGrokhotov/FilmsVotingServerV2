//
//  Option.swift
//  
//
//  Created by Владислав on 13.06.2020.
//

import Foundation
import Vapor
import Fluent
import FluentPostgresDriver

final class Option: Model, Content{
    
    // Name of the table or collection.
    static let schema = "options"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "content")
    var content: String
    
    @Field(key: "roomID")
    var roomID: UUID
    
    @Field(key: "vote")
    var vote: Int
    
    
    init() { }
    
    init(id: UUID? = nil, content: String, roomID: UUID, vote: Int = 0) {
        self.id = id
        self.content = content
        self.roomID = roomID
        self.vote = vote
    }
}

struct CreateOption: Migration {
    // Prepares the database for storing Galaxy models.
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema("options")
            .id()
            .field("content", .string)
            .field("roomID", .uuid)
            .field("vote", .int)
            .create()
    }

    // Optionally reverts the changes made in the prepare method.
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema("options").delete()
    }
}

extension Option {
    func toStringJSON() -> String {
        return  """
        {"id": "\(id!)", "content": "\(content)", "roomID": "\(roomID)", "vote": \(vote)}
        """
    }
}

struct OptionSelector: Codable {
    let roomID: UUID
}
