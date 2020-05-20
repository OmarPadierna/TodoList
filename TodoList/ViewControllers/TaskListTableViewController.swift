//
//  TaskListTableViewController.swift
//  TodoList
//
//  Created by Omar Padierna on 2020-05-19.
//  Copyright © 2020 Omar Padierna. All rights reserved.
//

import UIKit

class TaskListTableViewController: UITableViewController {
    private let searchController = UISearchController(searchResultsController: nil)

    var tasks: [Task] = []

    private var selectedTask: Task?

    private var filteredTasks: [Task] = []
    private var expandedRows: [Bool]  = []
    private var isSearchBarEmpty: Bool {
      return searchController.searchBar.text?.isEmpty ?? true
    }
    private var isFiltering: Bool {
      return searchController.isActive && !isSearchBarEmpty
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        searchController.searchResultsUpdater                 = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder                = "Search Tasks"
        navigationItem.searchController                       = searchController
        definesPresentationContext                            = true

        //Initialize expandedRows array. Used to keep track of expanded/collapsed state in row
        expandedRows = tasks.map({ (_) -> Bool in
            return false
        })

    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering {
            return filteredTasks.count
        }

        return tasks.count
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "taskCell", for: indexPath) as! TaskCell

        let task: Task

        if isFiltering {
            task = filteredTasks[indexPath.row]
        } else {
            task = tasks[indexPath.row]
        }

        cell.titleLabel.text       = task.title
        cell.descriptionLabel.text = expandedRows[indexPath.row] ? task.description : ""

        return cell
    }

    // MARK: - Table view delegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        if isFiltering {
            selectedTask = filteredTasks[indexPath.row]
        } else {
            selectedTask = tasks[indexPath.row]
        }

        let expandedState = expandedRows[indexPath.row]
        expandedRows[indexPath.row] = !expandedState

        tableView.reloadRows(at: [indexPath], with: .automatic)
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            tasks.remove(at: indexPath.row)
            expandedRows.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }

    // MARK: - Functions

    func filterContentForSearchText(_ searchText: String) {
        filteredTasks = tasks.filter { (task: Task) -> Bool in
        return task.title.lowercased().contains(searchText.lowercased())
      }

      tableView.reloadData()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch (segue.destination, segue.identifier) {
        case (let vc as AddTaskViewController, _):
            vc.delegate = self
        default:
            print("Unknown segue")
        }
    }

    // MARK: - IBActions

    @IBAction func addTask(_ sender: Any) {
        performSegue(withIdentifier: "addTaskSegue", sender: nil)
    }

}

extension TaskListTableViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
       let searchBar = searchController.searchBar
        filterContentForSearchText(searchBar.text!)
    }
}

extension TaskListTableViewController: AddTaskViewControllerDelegate {
    func addTaskViewControllerDelegate(_ controller: AddTaskViewController, didFinishWith task: Task) {

        tasks.append(task)
        expandedRows.append(false)

        tableView.reloadData()
    }

}
