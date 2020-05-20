//
//  DecodingError.swift
//  TodoList
//
//  Created by Omar Padierna on 2020-05-20.
//  Copyright © 2020 Omar Padierna. All rights reserved.
//

import Foundation

enum FirebaseDecodingError: Error {
    case decodingError
}

extension FirebaseDecodingError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .decodingError:
            let description = NSLocalizedString("decodingError", value: "There was a problem decoding this model", comment: "Decoding Error from firebase")
            return description
        }
    }
}
