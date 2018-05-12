//
//  AuthenticationContainer.swift
//  App
//
//  Created by William McGinty on 5/11/18.
//

import Foundation
import Vapor

struct AuthenticationContainer: Content {
    
    //MARK: Properties
    let accessToken: AccessToken.Token
    let refreshToken: RefreshToken.Token
    
    //MARK: Initializers
    init(accessToken: AccessToken, refreshToken: RefreshToken) {
        self.accessToken = accessToken.tokenString
        self.refreshToken = refreshToken.tokenString
    }
    
    //MARK: Codable
    private enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
    }
}

struct RefreshTokenContainer: Content {
    
    //MARK: Properties
    let refreshToken: RefreshToken.Token
    
    private enum CodingKeys: String, CodingKey {
        case refreshToken = "refresh_token"
    }
}
