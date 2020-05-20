//
//  FirebaseManager.swift
//  TodoList
//
//  Created by Omar Padierna on 2020-05-20.
//  Copyright © 2020 Omar Padierna. All rights reserved.
//

import Foundation
import Firebase
import FirebaseAuth
import GoogleSignIn

class FireBaseManager: NSObject {

    weak var signInDelegate: FirebaseSignInDelegate?

    private var dataBase = Firestore.firestore()

    private static var _shared: FireBaseManager?

    private static let initializeMessage = "Task Manager has not been initialized. Initialize with Taskmanager.initializeManager()"

    static var shared: FireBaseManager? {
        guard _shared != nil else {
            print(initializeMessage)
            return nil
        }

        return _shared
    }

    private override init() {}

    // MARK: - Private API
    private func handleGIDCallback(with url: URL) -> Bool {
        return GIDSignIn.sharedInstance().handle(url)
    }

    private func signInWithGoogle(in viewController: UIViewController) {
        GIDSignIn.sharedInstance()?.presentingViewController = viewController
        GIDSignIn.sharedInstance()?.delegate = self
        GIDSignIn.sharedInstance().signIn()
    }

    private func save(_ task: Task, for user: User) {
        var taskDocumentRef: DocumentReference? = nil
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withFullDate, .withFullTime]

        taskDocumentRef = dataBase.collection("users").document(user.email).collection("tasks").document(task.id)

        taskDocumentRef?.setData([
            "id" : task.id,
            "dueDate" : dateFormatter.string(from: task.dueDate),
            "description" : task.description,
            "status" : task.status.rawValue,
            "title" : task.title 
        ])
    }

    private func remove(_ task: Task, for user: User) {
        var taskDocumentRef: DocumentReference? = nil

        taskDocumentRef = dataBase.collection("users").document(user.email).collection("tasks").document(task.id)
        taskDocumentRef?.delete()
    }

    private func update(_ task: Task, for user: User) {
        //Firebase does have an update function, but for speed purposes the task will be overwritten for now
        save(task, for: user)
    }

    private func save(_ user: User) {
        var userDocumentRef: DocumentReference? = nil
        userDocumentRef = dataBase.collection("users").document(user.email)

        userDocumentRef?.setData([
            "email" : user.email,
            "name" : user.name
        ])
    }

    private func fetchTasks(for user: User, completion: @escaping([Task]?, Error?) -> Void ) {
        var taskCollectionRef: CollectionReference? = nil
        let dateFormater = ISO8601DateFormatter()
        dateFormater.formatOptions = [.withFullTime, .withFullTime]

        taskCollectionRef = dataBase.collection("users").document(user.email).collection("tasks")

        taskCollectionRef?.getDocuments(completion: { (querySnapshot, error) in
            if let error = error {
                completion(nil, error)
            } else {
                var tasks: [Task] = []
                for document in querySnapshot!.documents {
                    let resultDictionary = document.data()
                    if let task = Task(with: resultDictionary) {
                        tasks.append(task)
                    } else {
                        completion(nil, FirebaseDecodingError.decodingError)
                    }
                }

                completion(tasks, nil)
            }
        })
    }

    private func signOut(_ user: User, completion: @escaping(Error?) -> Void) {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
        } catch let signOutError {
            completion(signOutError)
        }
    }

    // MARK: - Public API

    ///Initialize Firebase and GoogleSignIn
    public static func initializeManager() {
        FirebaseApp.configure()
        GIDSignIn.sharedInstance()?.clientID = FirebaseApp.app()?.options.clientID
        _shared = FireBaseManager()
    }

    ///Handle GoogleSignIn deep link
    public static func handleGoogleSignInCallback(with url: URL) -> Bool {
        guard let shared = shared else {
            print(initializeMessage)
            return false
        }

        return shared.handleGIDCallback(with: url)
    }

    ///Sign in with Google
    public static func signInWithGoogle(in viewController: UIViewController, delegate: FirebaseSignInDelegate) {
        shared?.signInWithGoogle(in: viewController)
        shared?.signInDelegate = delegate
    }

    ///Fetch user's tasks
    public static func fetchTasks(for user: User, delegate: FirebaseTaskFetchDelegate) {
        shared?.fetchTasks(for: user, completion: { [unowned delegate] (tasks, error) in
            if let error = error {
                delegate.fetchDidFail(with: error)
            } else {
                delegate.fetchDidSucceed(with: tasks!)
            }
        })
    }

    ///Save individual tasks per user
    public static func save(_ task: Task, for user: User) {
        shared?.save(task, for: user)
    }

    ///Save user in database
    public static func save(_ user: User) {
        shared?.save(user)
    }

    ///Update specific task for specific user
    public static func update(_ task: Task, for user: User) {
        shared?.update(task, for: user)
    }

    ///Remove individual task for user
    public static func remove(_ task: Task, for user: User) {
        shared?.remove(task, for: user)
    }

    ///Sign out user
    public static func signOut(_ user: User, delegate: FirebaseSignOutDelegate) {
        shared?.signOut(user, completion: { [unowned delegate] (error) in
            if let error = error {
                delegate.signOutDidFail(with: error)
            }
        })
    }
    
}

// MARK: - Extensions

extension FireBaseManager: GIDSignInDelegate {
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            signInDelegate?.signInFailed(with: error)
            return
        }

        guard let auth = user.authentication else { return }

        let credentials = GoogleAuthProvider.credential(withIDToken: auth.idToken, accessToken: auth.accessToken)

        Auth.auth().signIn(with: credentials) { [unowned self] (authResult, error) in
            guard error == nil else {
                self.signInDelegate?.signInFailed(with: error!)
                return
            }

            if let authResult = authResult,
                let name = authResult.user.displayName,
                let email = authResult.user.email{

                let user = User(name: name, email: email)

                self.signInDelegate?.signInSuccessful(with: user)
            }
        }
    }
}
