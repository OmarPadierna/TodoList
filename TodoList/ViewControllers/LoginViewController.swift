//
//  LoginViewController.swift
//  TodoList
//
//  Created by Omar Padierna on 2020-05-20.
//  Copyright © 2020 Omar Padierna. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    private let defaults = UserDefaults.standard
    private var user: User?
    private var tasks: [Task]?

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.setNavigationBarHidden(true, animated: animated)

        if let encodedUser = defaults.data(forKey: "User"),
            let savedUser = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(encodedUser) as? User {
            user = savedUser
            loginButton.isHidden = true
            loginButton.isEnabled = false
            activityIndicator.startAnimating()

            FireBaseManager.fetchTasks(for: savedUser, delegate: self)

        } else {
            activityIndicator.stopAnimating()
            loginButton.isHidden = false
            loginButton.isEnabled = true
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        navigationController?.setNavigationBarHidden(false, animated: animated)
    }


    @IBAction func googleSignInPressed(_ sender: Any) {
        FireBaseManager.signInWithGoogle(in: self, delegate: self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch (segue.destination, segue.identifier) {
        case (let vc as TaskListTableViewController, _):
            vc.tasks = tasks ?? []
            vc.user = user

            let backItem = UIBarButtonItem(title: "Logout", style: .plain, target: nil, action: nil)

            navigationItem.backBarButtonItem = backItem
        default:
            print("Unknown segue")
        }
    }
}

extension LoginViewController: FirebaseSignInDelegate {
    func signInSuccessful(with user: User) {
        do {
            let encodedUser = try NSKeyedArchiver.archivedData(withRootObject: user, requiringSecureCoding: false)
            defaults.set(encodedUser, forKey: "User")
            self.user = user

            loginButton.isHidden = true
            loginButton.isEnabled = false
            activityIndicator.startAnimating()

            FireBaseManager.fetchTasks(for: user, delegate: self)
        } catch {
            print(error)
        }
    }

    func signInFailed(with error: Error) {
        let alert = UIAlertController(title: "Failed Sign inn", message: "There was an error signing in. \(error.localizedDescription)", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)

        alert.addAction(okAction)

        present(alert, animated: true, completion: nil)
    }
}

extension LoginViewController: FirebaseTaskFetchDelegate {
    func fetchDidSucceed(with tasks: [Task]) {
        self.tasks = tasks
        performSegue(withIdentifier: "taskListSegue", sender: nil)
    }

    func fetchDidFail(with error: Error) {
        let alert = UIAlertController(title: "Error fetching tasks", message: "There was an error fetching tasks. \(error.localizedDescription)", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)

        alert.addAction(okAction)
        
        present(alert, animated: true, completion: nil)
    }
}
