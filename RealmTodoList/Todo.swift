//
//  Todo.swift
//  RealmTodoList
//
//  Created by SimpuMind on 9/4/17.
//  Copyright © 2017 SimpuMind. All rights reserved.
//

import Foundation
import RealmSwift

class Todo: Object {
    
    dynamic var createdAt = Date()
    dynamic var task = ""
    dynamic var isCompleted = false
}
