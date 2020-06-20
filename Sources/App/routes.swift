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


        *    Requests:

                GET /users   - all users
                GET /users/login/<user_login>  - get user with String login user_login
                GET /users/<user_id> - get user with UUID id user_id

                POST /users - create user

                PUT /users/<user_id> - update user with UUID id user_id
                You can only update user_name and user_password

                DELETE /users/<user_id> - delete user with UUID id user_id


        Rooms:

        *    Room model

                var id: UUID?
                var name: String
                var password: String
                var creatorID: UUID
                var isVotingAvailable: Bool
                var users: [UUID]

        *    Requests:

                GET /rooms   - all rooms
                GET /rooms/name/<room_name>  - get room with String name room_name
                GET /rooms/<room_id> - get room with UUID id room_id

                POST /rooms - create room

                PUT /rooms/<room_id> - update room with UUID id room_id
                You can not update room_password, room_name and room_creatorID

                DELETE /rooms/<room_id> - delete room with UUID id room_id


        Options:

        *    Option model
                
                var id: UUID?
                var content: String
                var vote: Int
                var roomID: UUID

         *   Requests:

                GET /options   - all options
                GET /options/room/<room_id>  - get all options with room id room_id
                GET /options/<option_id> - get option with UUID id option_id

                POST /options - create option

                PUT /options/<option_id> - update option with UUID id option_id
                You can only update option_vote

                DELETE /options/<option_id> - delete option with UUID id options_id
                DELETE /options/room/<room_id> - delete all options with UUID id room_id
        """
    }

    // Configuring a controller

    let roomController = RoomController()
    let userController = UserController()
    let optionController = OptionController()
    
    app.get("allrooms", use: roomController.all)
    app.get("rooms", use: roomController.allWithoutValidation)
    app.get("rooms", "name", ":name", use: roomController.showUsingName)
    app.get("rooms", ":roomID", use: roomController.showUsingId)
    app.post("rooms", use: roomController.create)
    app.put("rooms", ":roomID", use: roomController.update)
    app.delete("rooms", ":roomID", use: roomController.delete)
    
    app.webSocket("rooms", "socket", onUpgrade: roomController.onUpgrade)
    
    app.get("users", use: userController.all)
    app.get("users", ":userID", use: userController.showUsingId)
    app.post("users", use: userController.create)
    app.post("users", "login", use: userController.showUsingLogin)
    app.put("users", ":userID", use: userController.update)
    app.delete("users", ":userID", use: userController.delete)
    
    app.get("options", use: optionController.all)
    app.get("options", "room", ":roomID", use: optionController.showUsingRoomID)
    app.get("options", ":optionID", use: optionController.showUsingId)
    app.post("options", use: optionController.create)
    app.put("options", ":optionID", use: optionController.update)
    app.delete("options", ":optionID", use: optionController.delete)
    app.delete("options", "room", ":roomID", use: optionController.deleteAllWithRoomID)
    
    app.webSocket("options", "socket", onUpgrade: optionController.onUpgrade)
}
