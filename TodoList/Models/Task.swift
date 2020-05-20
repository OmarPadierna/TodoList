//
//  Task.swift
//  TodoList
//
//  Created by Omar Padierna on 2020-05-19.
//  Copyright © 2020 Omar Padierna. All rights reserved.
//

import Foundation

enum Status: String {
    case pending = "pending"
    case done = "done"
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

    init(title: String, status: Status = .pending, description: String, dueDate: Date) {
        self.title = title
        self.status = status
        self.description = description
        self.dueDate = dueDate
    }

    init?(with dictionary: [String : Any]) {
        let dateFormatter = ISO8601DateFormatter()
        
        guard let statusString = dictionary["status"] as? String, let status = Status(rawValue: statusString) else {
            return nil
        }
        guard let title = dictionary["title"] as? String else {
            return nil
        }
        guard let description = dictionary["description"] as? String else {
            return nil
        }

        guard let dueDateString = dictionary["dueDate"] as? String, let dueDate = dateFormatter.date(from: dueDateString) else {
            return nil
        }

        guard let id = dictionary["id"] as? String else {
            return nil
        }

        self.status       = status
        self.title        = title
        self.description  = description
        self.dueDate      = dueDate
        self.id           = id
    }
}
