//
//  User.swift
//  TodoList
//
//  Created by Omar Padierna on 2020-05-20.
//  Copyright © 2020 Omar Padierna. All rights reserved.
//

import Foundation

class User: NSObject, NSCoding {
    var name: String
    var email: String

    init(name: String, email: String) {
        self.name = name
        self.email = email
    }

    enum CodingKeys: String, CodingKey {
        case name = "name"
        case email = "email"
    }

    func encode(with coder: NSCoder) {
        coder.encode(name, forKey: CodingKeys.name.rawValue)
        coder.encode(email, forKey: CodingKeys.email.rawValue)
    }

    required init?(coder: NSCoder) {
        if let name = coder.decodeObject(forKey: CodingKeys.name.rawValue) as? String,
            let email = coder.decodeObject(forKey: CodingKeys.email.rawValue) as? String {
            self.name = name
            self.email = email
        } else {
            return nil
        }
    }
}
