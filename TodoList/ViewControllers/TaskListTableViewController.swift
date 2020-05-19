//
//  TaskListTableViewController.swift
//  TodoList
//
//  Created by Omar Padierna on 2020-05-19.
//  Copyright © 2020 Omar Padierna. All rights reserved.
//

import UIKit

class TaskListTableViewController: UITableViewController {

    var tasks: [Task]         = []
    var filteredTasks: [Task] = []

    private let searchController = UISearchController(searchResultsController: nil)

    override func viewDidLoad() {
        super.viewDidLoad()

        //TODO: Remove this dummy data
        let task        = Task(title: "A random task",
                               description: "A random description",
                               dueDate: .init(timeIntervalSinceNow: 24.0*60.0*60.0))
        let anotherTask = Task(title: "Another task",
                               description: "Another random description",
                               dueDate: .init(timeIntervalSinceNow: 48.0*60.0*60.0))
        tasks.append(task)
        tasks.append(anotherTask)

    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "taskCell", for: indexPath) as! TaskCell

        cell.titleLabel.text       = tasks[indexPath.row].title
        cell.descriptionLabel.text = tasks[indexPath.row].description
        cell.dueDateLabel.text     = tasks[indexPath.row].dueDate.description

        return cell
    }

}
