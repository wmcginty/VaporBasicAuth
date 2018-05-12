//
//  UserController.swift
//  App
//
//  Created by William McGinty on 5/8/18.
//

import Foundation
import Vapor
import Fluent
import Crypto

class UserController: RouteCollection {
    
    func boot(router: Router) throws {
        let group = router.grouped("api", "users")
        group.post(User.self, at: "register", use: registerUserHandler)
        group.post(User.self, at: "login", use: loginUserHandler)
        group.post(RefreshTokenContainer.self, at: "refresh", use: refreshAccessTokenHandler)
    }
}

//MARK: Handlers
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
    
    func loginUserHandler(_ request: Request, user: User) throws -> Future<AuthenticationContainer> {
        return try User.query(on: request).filter(\.email == user.email).first().flatMap { existingUser in
            guard let existingUser = existingUser else {
                throw Abort(.badRequest, reason: "this user does not exist" , identifier: nil)
            }
            
            let digest = try request.make(BCryptDigest.self)
            guard try digest.verify(user.password, created: existingUser.password) else {
                throw Abort(.badRequest) /* authentication failure */
            }
            
            return try self.authenticationContainer(for: existingUser, on: request)
        }
    }
}

//MARK: Helper
private extension UserController {
    func authenticationContainer(for user: User, on connection: DatabaseConnectable) throws -> Future<AuthenticationContainer> {
        let accessToken = try AccessToken(userID: user.requireID()).save(on: connection)
        let refreshToken = try RefreshToken(userID: user.requireID()).save(on: connection)
        return map(to: AuthenticationContainer.self, accessToken, refreshToken) { access, refresh in
            return AuthenticationContainer(accessToken: access, refreshToken: refresh)
        }
    }
    
    func authenticationContainer(for refreshToken: RefreshToken.Token, on connection: DatabaseConnectable) throws -> Future<AuthenticationContainer> {
        return try existingUser(matchingTokenString: refreshToken, on: connection).flatMap { user in
            guard let user = user else { throw Abort(.notFound) }
            return try self.authenticationContainer(for: user, on: connection)
        }
    }
    
    func refreshAccessTokenHandler(_ request: Request, container: RefreshTokenContainer) throws -> Future<AuthenticationContainer> {
        return try self.authenticationContainer(for: container.refreshToken, on: request)
    }
    
    func existingUser(matchingTokenString tokenString: RefreshToken.Token, on connection: DatabaseConnectable) throws -> Future<User?> {
        return try RefreshToken.query(on: connection).filter(\.tokenString == tokenString).first().flatMap { token in
            guard let token = token else { throw Abort(.notFound /* token not found */) }
            return try User.query(on: connection).filter(\.id == token.userID).first()
        }
    }
}
