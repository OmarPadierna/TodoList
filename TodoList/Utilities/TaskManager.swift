//
//  TaskManager.swift
//  TodoList
//
//  Created by Omar Padierna on 2020-05-20.
//  Copyright © 2020 Omar Padierna. All rights reserved.
//

import Foundation
import Firebase
import GoogleSignIn

class TodoManager {
    private static var _shared: TodoManager?

    private static let initializeMessage = "Task Manager has not been initialized. Initialize with Taskmanager.initialize()"

    static var shared: TodoManager? {
        guard _shared != nil else {
            print(initializeMessage)
            return nil
        }

        return _shared
    }

    private init() {}

    private func handleGIDCallback(with url: URL) -> Bool {
        return GIDSignIn.sharedInstance().handle(url)
    }

    // MARK: - Public API

    ///Initialize Firebase and GoogleSignIn
    public static func initialize() {
        FirebaseApp.configure()
        GIDSignIn.sharedInstance()?.clientID = FirebaseApp.app()?.options.clientID
        _shared = TodoManager()
    }

    ///Handle GoogleSignIn deep link
    public static func handleGoogleSignInCallback(with url: URL) -> Bool {
        guard let shared = shared else {
            print(initializeMessage)
            return false
        }

        return shared.handleGIDCallback(with: url)
    }



}
