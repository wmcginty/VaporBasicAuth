import Vapor
import Authentication
import Crypto

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    
    let todoController = TodoController()
    let basicAuthMiddleware = User.basicAuthMiddleware(using: BCrypt)
    let guardAuthMiddleware = User.guardAuthMiddleware()
    let basicAuthGroup = router.grouped([basicAuthMiddleware, guardAuthMiddleware])
    router.get("todos", use: todoController.index)
    basicAuthGroup.post("todos", use: todoController.create)
    basicAuthGroup.delete("todos", Todo.parameter, use: todoController.delete)
    
    let userRouteController = UserController()
    try userRouteController.boot(router: router)
}
