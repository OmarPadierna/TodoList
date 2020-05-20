//
//  FirebaseTaskFetchDelegate.swift
//  TodoList
//
//  Created by Omar Padierna on 2020-05-20.
//  Copyright © 2020 Omar Padierna. All rights reserved.
//

import Foundation

protocol FirebaseTaskFetchDelegate: class {
    func fetchDidSucceed(with tasks: [Task])
    func fetchDidFail(with error: Error)
}
