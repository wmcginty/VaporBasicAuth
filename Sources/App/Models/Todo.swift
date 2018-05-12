//
//  Todo.swift
//  App
//
//  Created by William McGinty on 5/8/18.
//

import Vapor
import FluentSQLite

final class Todo: Parameter, Content,SQLiteModel, Migration {

    //MARK: Properties
    var id: Int?
    var title: String

    init(id: Int? = nil, title: String) {
        self.id = id
        self.title = title
    }
}
