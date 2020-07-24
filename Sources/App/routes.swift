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


        +--------+-------------------+------------------------------------------+
        | GET    | /                 |                                          |
        +--------+-------------------+------------------------------------------+
        | GET    | /allrooms         | Returns all rooms with all information   |
        +--------+-------------------+------------------------------------------+
        | GET    | /rooms            | Returns all rooms with base information  |
        +--------+-------------------+------------------------------------------+
        | GET    | /rooms/name/:name | Returns room by its name                 |
        +--------+-------------------+------------------------------------------+
        | POST   | /rooms/id         | Returns room by its ID                   |
        +--------+-------------------+------------------------------------------+
        | POST   | /rooms            | Creates new room                         |
        +--------+-------------------+------------------------------------------+
        | DELETE | /rooms            | Deletes room by its ID                   |
        +--------+-------------------+------------------------------------------+
        | GET    | /users            | Returns all users with all information   |
        +--------+-------------------+------------------------------------------+
        | POST   | /users            | Creates new user                         |
        +--------+-------------------+------------------------------------------+
        | POST   | /users/login      | Returns user by its login                |
        +--------+-------------------+------------------------------------------+
        | DELETE | /users            | Deletes user by its ID                   |
        +--------+-------------------+------------------------------------------+
        | GET    | /options          | Returns all options with all information |
        +--------+-------------------+------------------------------------------+
        | POST   | /options/roomid   | Returns all options with fixed roomID    |
        +--------+-------------------+------------------------------------------+
        | POST   | /options          | Creates new option                       |
        +--------+-------------------+------------------------------------------+
        | PUT    | /options          | Updates option by its id                 |
        +--------+-------------------+------------------------------------------+
        | DELETE | /options          | Deletes option by its ID                 |
        +--------+-------------------+------------------------------------------+
        | DELETE | /options/room     | Deletes all options by its roomID        |
        +--------+-------------------+------------------------------------------+
        | GET    | /socket           | Connects to websocket                    |
        +--------+-------------------+------------------------------------------+

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
    app.delete("rooms", use: roomController.delete)
        .description("Deletes room by its ID")
    
    app.get("users", use: userController.all)
        .description("Returns all users with all information")
//    app.get("users", ":userID", use: userController.showUsingId)
//        .description("Returns user by its ID")
    app.post("users", use: userController.create)
        .description("Creates new user")
    app.post("users", "login", use: userController.showUsingLogin)
        .description("Returns user by its login")
//    app.put("users", ":userID", use: userController.update)
//        .description("Updates user by its id")
    app.delete("users", use: userController.delete)
        .description("Deletes user by its ID")
    
    app.get("options", use: optionController.all)
        .description("Returns all options with all information")
//    app.get("options", ":optionID", use: optionController.showUsingId)
//        .description("Returns option by its ID")
    app.post("options", "roomid", use: optionController.showUsingRoomID)
        .description("Returns all options with fixed roomID")
    app.post("options", use: optionController.create)
        .description("Creates new option")
    app.put("options", use: optionController.update)
        .description("Updates option by its id")
    app.delete("options", use: optionController.delete)
        .description("Deletes option by its ID")
    app.delete("options", "room", use: optionController.deleteAllWithRoomID)
        .description("Deletes all options by its roomID")
    
    
    app.webSocket("socket", onUpgrade: SocketController.shared.onUpgrade).description("Connects to websocket")
}
