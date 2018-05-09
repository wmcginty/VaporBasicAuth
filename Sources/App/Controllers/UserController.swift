//
//  UserController.swift
//  App
//
//  Created by William McGinty on 5/8/18.
//

import Foundation
import Vapor
import Fluent
import FluentSQLite
import Crypto

class UserController: RouteCollection {
    
    func boot(router: Router) throws {
        let group = router.grouped("api", "users")
        group.post(User.self, at: "register", use: registerUserHandler)
    }
}

//MARK: Helper
private extension UserController {
    
    func registerUserHandler(_ request: Request, newUser: User) throws -> Future<HTTPResponseStatus> {
        return try User.query(on: request).filter(\.email == newUser.email).first().flatMap { existingUser in
            guard existingUser == nil else {
                throw Abort(.badRequest, reason: "a user with this email already exists" , identifier: nil)
            }
            
            let digest = try request.make(BCryptDigest.self)
            let hashedPassword = try digest.hash(newUser.password)
            let persistedUser = User(id: nil, email: newUser.email, password: hashedPassword)
            return persistedUser.save(on: request).transform(to: .created)
        }
    }
}
