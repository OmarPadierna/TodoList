//
//  FirebaseSignInDelegate.swift
//  TodoList
//
//  Created by Omar Padierna on 2020-05-20.
//  Copyright © 2020 Omar Padierna. All rights reserved.
//

import Foundation

protocol FirebaseSignInDelegate: class {
    func signInSuccessful(with user: User)
    func signInFailed(with error: Error)
}
