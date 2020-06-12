import Vapor
import Fluent
import FluentPostgresDriver

// configures your application
public func configure(_ app: Application) throws {
    // uncomment to serve files from /Public folder
//     app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
    
    // Configure a PostgreSQL database
    if let url = Environment.get("DATABASE_URL") {
        try? app.databases.use( .postgres(url: URL(string: url)!), as: .psql)
    } else {
        app.databases.use( .postgres(hostname: "localhost", username: "vladislav", password: "", database: "filmsvotingv2")!, as: .psql)
    }
    
    // Configure migrations
    app.migrations.add(CreateRoom())
    app.migrations.add(CreateUser())
    try app.autoMigrate().wait()
    
    // register routes
    try routes(app)
}
