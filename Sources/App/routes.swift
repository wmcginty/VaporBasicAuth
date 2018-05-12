import Vapor
import Authentication
import Crypto

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    
    let todoController = TodoController()
    try todoController.boot(router: router)
    
    let userRouteController = UserController()
    try userRouteController.boot(router: router)
}
