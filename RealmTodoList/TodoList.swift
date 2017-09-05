//
//  TodoList.swift
//  RealmTodoList
//
//  Created by SimpuMind on 9/4/17.
//  Copyright © 2017 SimpuMind. All rights reserved.
//

import Foundation
import RealmSwift

class TaskList: Object {
    
    dynamic var name = ""
    dynamic var createdAt = Date()
    let tasks = List<Todo>()
}
