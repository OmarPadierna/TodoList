//
//  Task.swift
//  TodoList
//
//  Created by Omar Padierna on 2020-05-19.
//  Copyright © 2020 Omar Padierna. All rights reserved.
//

import Foundation

enum Status {
    case pending
    case done
}

///A task that represents something that the user has to do
struct Task {
    ///The status of the task
    var status: Status = .pending
    ///The title of the task
    let title: String
    ///A description on the task
    let description: String
    ///The due date for the task
    var dueDate: Date
}
