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

        """
    }

    // Configuring a controller

    let roomController = RoomController()
    let userController = UserController()
    let optionController = OptionController()
    
    app.get("allrooms", use: roomController.all)
    app.get("rooms", use: roomController.allWithoutValidation)
    app.get("rooms", "name", ":name", use: roomController.showUsingName)
    app.post("rooms", "id", use: roomController.showUsingId)
    app.post("rooms", use: roomController.create)
    //app.put("rooms", ":roomID", use: roomController.update)
    app.delete("rooms", ":roomID", use: roomController.delete)
    
    app.webSocket("rooms", "socket", onUpgrade: roomController.onUpgrade)
    
    app.get("users", use: userController.all)
    app.get("users", ":userID", use: userController.showUsingId)
    app.post("users", use: userController.create)
    app.post("users", "login", use: userController.showUsingLogin)
    app.put("users", ":userID", use: userController.update)
    app.delete("users", ":userID", use: userController.delete)
    
    app.get("options", use: optionController.all)
    app.get("options", ":optionID", use: optionController.showUsingId)
    app.post("options", "roomid", use: optionController.showUsingRoomID)
    app.post("options", use: optionController.create)
    app.put("options", ":optionID", use: optionController.update)
    app.delete("options", ":optionID", use: optionController.delete)
    app.delete("options", "room", ":roomID", use: optionController.deleteAllWithRoomID)
    
    app.webSocket("options", "socket", onUpgrade: optionController.onUpgrade)
}
