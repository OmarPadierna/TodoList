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

struct Task {
    var status: Status = .pending
    //Note: Making the title variable will result in a different id for the task. This will cause bugs if future features require tasks to be modifiable, since id's are meant to be unique.
    var title: String {
        didSet {
            id = id + title
        }
    }

    var description: String

    var dueDate: Date

    private(set) var id: String = {
        return String(Int.random(in: 0...10000000))
    }()
}
