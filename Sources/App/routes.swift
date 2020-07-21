import Vapor
import Fluent
import FluentPostgresDriver

func routes(_ app: Application) throws {
    // Basic "It works" example
    app.get { req in
        return """
        It works!
        

        Users:
        
        *    User Model

                var id: UUID?
                var name: String
                var login: String
                var password: String


        Rooms:

        *    Room model

                var id: UUID?
                var name: String
                var password: String
                var creatorID: UUID


        Options:

        *    Option model
                
                var id: UUID?
                var content: String
                var vote: Int
                var roomID: UUID


        +--------+-----------------------+------------------------------------------+
        | GET    | /                     |                                          |
        +--------+-----------------------+------------------------------------------+
        | GET    | /allrooms             | Returns all rooms with all information   |
        +--------+-----------------------+------------------------------------------+
        | GET    | /rooms                | Returns all rooms with base information  |
        +--------+-----------------------+------------------------------------------+
        | GET    | /rooms/name/:name     | Returns room by its name                 |
        +--------+-----------------------+------------------------------------------+
        | POST   | /rooms/id             | Returns room by its ID                   |
        +--------+-----------------------+------------------------------------------+
        | POST   | /rooms                | Creates new room                         |
        +--------+-----------------------+------------------------------------------+
        | DELETE | /rooms/:roomID        | Deletes room by its ID                   |
        +--------+-----------------------+------------------------------------------+
        | GET    | /rooms/socket         | Connects to rooms websocket              |
        +--------+-----------------------+------------------------------------------+
        | GET    | /users                | Returns all users with all information   |
        +--------+-----------------------+------------------------------------------+
        | GET    | /users/:userID        | Returns user by its ID                   |
        +--------+-----------------------+------------------------------------------+
        | POST   | /users                | Creates new user                         |
        +--------+-----------------------+------------------------------------------+
        | POST   | /users/login          | Returns user by its login                |
        +--------+-----------------------+------------------------------------------+
        | PUT    | /users/:userID        | Updates user by its id                   |
        +--------+-----------------------+------------------------------------------+
        | DELETE | /users/:userID        | Deletes user by its ID                   |
        +--------+-----------------------+------------------------------------------+
        | GET    | /options              | Returns all options with all information |
        +--------+-----------------------+------------------------------------------+
        | GET    | /options/:optionID    | Returns option by its ID                 |
        +--------+-----------------------+------------------------------------------+
        | POST   | /options/roomid       | Returns all options with fixed roomID    |
        +--------+-----------------------+------------------------------------------+
        | POST   | /options              | Creates new option                       |
        +--------+-----------------------+------------------------------------------+
        | PUT    | /options/:optionID    | Updates option by its id                 |
        +--------+-----------------------+------------------------------------------+
        | DELETE | /options/:optionID    | Deletes option by its ID                 |
        +--------+-----------------------+------------------------------------------+
        | DELETE | /options/room/:roomID | Deletes all options by its roomID        |
        +--------+-----------------------+------------------------------------------+
        | GET    | /options/socket       | Connects to options websocket            |
        +--------+-----------------------+------------------------------------------+

        """
    }

    // Configuring a controller

    let roomController = RoomController()
    let userController = UserController()
    let optionController = OptionController()
    
    app.get("allrooms", use: roomController.all)
        .description("Returns all rooms with all information")
    app.get("rooms", use: roomController.allWithoutValidation)
        .description("Returns all rooms with base information")
    app.get("rooms", "name", ":name", use: roomController.showUsingName)
        .description("Returns room by its name")
    app.post("rooms", "id", use: roomController.showUsingId)
        .description("Returns room by its ID")
    app.post("rooms", use: roomController.create)
        .description("Creates new room")
    //app.put("rooms", ":roomID", use: roomController.update)
    app.delete("rooms", ":roomID", use: roomController.delete)
        .description("Deletes room by its ID")
    
    app.webSocket("rooms", "socket", onUpgrade: roomController.onUpgrade)
        .description("Connects to rooms websocket")
    
    app.get("users", use: userController.all)
        .description("Returns all users with all information")
    app.get("users", ":userID", use: userController.showUsingId)
        .description("Returns user by its ID")
    app.post("users", use: userController.create)
        .description("Creates new user")
    app.post("users", "login", use: userController.showUsingLogin)
        .description("Returns user by its login")
    app.put("users", ":userID", use: userController.update)
        .description("Updates user by its id")
    app.delete("users", ":userID", use: userController.delete)
        .description("Deletes user by its ID")
    
    app.get("options", use: optionController.all)
        .description("Returns all options with all information")
    app.get("options", ":optionID", use: optionController.showUsingId)
        .description("Returns option by its ID")
    app.post("options", "roomid", use: optionController.showUsingRoomID)
        .description("Returns all options with fixed roomID")
    app.post("options", use: optionController.create)
        .description("Creates new option")
    app.put("options", ":optionID", use: optionController.update)
        .description("Updates option by its id")
    app.delete("options", ":optionID", use: optionController.delete)
        .description("Deletes option by its ID")
    app.delete("options", "room", ":roomID", use: optionController.deleteAllWithRoomID)
        .description("Deletes all options by its roomID")
    
    app.webSocket("options", "socket", onUpgrade: optionController.onUpgrade)
        .description("Connects to options websocket")
}
