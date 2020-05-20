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
    var unfilteredTasks: [Task] = []

    private var selectedTask: Task?
    private var searchResultTasks: [Task] = []
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
        initializeExpandedRows()

        unfilteredTasks = tasks
        tableView.tableHeaderView?.isHidden = true
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering {
            return searchResultTasks.count
        }

        return tasks.count
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "taskCell", for: indexPath) as! TaskCell

        let task: Task

        if isFiltering {
            task = searchResultTasks[indexPath.row]
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
            selectedTask = searchResultTasks[indexPath.row]
        } else {
            selectedTask = tasks[indexPath.row]
        }

        let expandedState           = expandedRows[indexPath.row]
        expandedRows[indexPath.row] = !expandedState

        tableView.reloadRows(at: [indexPath], with: .automatic)
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            tasks.remove(at: indexPath.row)
            expandedRows.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            updateUnfilteredTasks()
        }
    }

    // MARK: - Functions

    func filterContentForSearchText(_ searchText: String) {
        searchResultTasks = tasks.filter { (task: Task) -> Bool in
        return task.title.lowercased().contains(searchText.lowercased())
      }

      tableView.reloadData()
    }

    func updateUnfilteredTasks() {
        unfilteredTasks = tasks
    }

    func initializeExpandedRows() {
        expandedRows = tasks.map({ (_) -> Bool in
            return false
        })
    }

    func clearFilters() {
        tasks = unfilteredTasks

        initializeExpandedRows()

        tableView.tableHeaderView?.isHidden = true
        tableView.reloadData()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch (segue.destination, segue.identifier) {
        case (let vc as AddTaskViewController, _):
            vc.delegate = self
        case (let vc as CalendarViewController, _):
            vc.delegate = self
        default:
            print("Unknown segue")
        }
    }

    private func filterByStatus(_ status: Status) {
        tasks = tasks.filter { (task) -> Bool in
            return task.status == status
        }

        initializeExpandedRows()

        tableView.tableHeaderView?.isHidden = false

        tableView.reloadData()
    }

    private func filterByDate(_ date: Date) {
        tasks = tasks.filter({ (task) -> Bool in
            task.dueDate == date
        })

        initializeExpandedRows()

        let formatter = DateFormatter()
        formatter.timeStyle = .none
        formatter.dateStyle = .medium

        self.title = formatter.string(from: date)

        tableView.tableHeaderView?.isHidden = false

        tableView.reloadData()
    }

    // MARK: - IBActions

    @IBAction func addTask(_ sender: Any) {
        performSegue(withIdentifier: "addTaskSegue", sender: nil)
    }

    @IBAction func presentOptions(_ sender: Any) {
        let optionMenu = UIAlertController(title: nil, message: "Filter tasks by", preferredStyle: .actionSheet)

        let filterByDateAction = UIAlertAction(title: "Due date", style: .default) { [unowned self] (_) in
            self.performSegue(withIdentifier: "calendarSegue", sender: nil)
        }

        let filterByComplete = UIAlertAction(title: "Complete tasks", style: .default) { [unowned self] (_) in
            self.filterByStatus(.done)
        }

        let filterByPending = UIAlertAction(title: "Pending tasks", style: .default) { [unowned self] (_) in
            self.filterByStatus(.pending)
        }

        optionMenu.addAction(filterByDateAction)
        optionMenu.addAction(filterByComplete)
        optionMenu.addAction(filterByPending)

        self.present(optionMenu, animated: true, completion: nil)
    }

    @IBAction func clearFiltersButtonTapped(_ sender: Any) {
        clearFilters()
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
        updateUnfilteredTasks()
        clearFilters()
        tableView.reloadData()
    }
}

extension TaskListTableViewController: CalendarViewControllerDelegate {
    func calendarViewController(didFinishWith date: Date) {
        filterByDate(date)
    }
}
