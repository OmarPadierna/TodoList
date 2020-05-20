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
    var user: User?

    private var selectedTask: Task?
    private var indexPathForSelectedTask: IndexPath?
    private var searchResultTasks: [Task] = []
    private var expandedRows: [Bool]  = []
    private var isSearchBarEmpty: Bool {
      return searchController.searchBar.text?.isEmpty ?? true
    }
    private var isSearching: Bool {
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

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if self.isMovingFromParent {
            if let user = user {
                let defaults = UserDefaults.standard
                defaults.removeObject(forKey: "User")
                FireBaseManager.signOut(user, delegate: self)
            }
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearching {
            return searchResultTasks.count
        }

        return tasks.count
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "taskCell", for: indexPath) as! TaskCell

        let task: Task

        if isSearching {
            task = searchResultTasks[indexPath.row]
        } else {
            task = tasks[indexPath.row]
        }

        cell.titleLabel.text       = task.title
        cell.descriptionLabel.text = expandedRows[indexPath.row] ? task.description : ""
        cell.delegate = self
        cell.indexPath = indexPath

        switch task.status {
        case .pending:
            cell.statusButton.setImage(UIImage(systemName: "circle"), for: .normal)
        case .done:
            cell.statusButton.setImage(UIImage(systemName: "checkmark.circle"), for: .normal)
        }

        return cell
    }

    // MARK: - Table view delegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        if isSearching {
            selectedTask = searchResultTasks[indexPath.row]
        } else {
            selectedTask = tasks[indexPath.row]
        }

        let expandedState           = expandedRows[indexPath.row]
        expandedRows[indexPath.row] = !expandedState

        tableView.reloadRows(at: [indexPath], with: .automatic)
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {

        guard isSearching == false else {
            return
        }

        if editingStyle == .delete {
            let task = tasks[indexPath.row]

            tasks.remove(at: indexPath.row)
            expandedRows.remove(at: indexPath.row)

            tableView.deleteRows(at: [indexPath], with: .fade)
            
            updateUnfilteredTasks()

            if let user = user {
                FireBaseManager.remove(task, for: user)
            }
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
            vc.selectedTask = selectedTask
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

    //We're dealing with 3 types of filtering: by status, by date and when searching. To preserve the task status when the user taps the cell button it is necessary to iterate through all the arrays (unfilteredTasks, tasks, and searchResultTasks) and update the task if it happens to exist in said array. In future iterations this whole controller could be refactored to move this logic out of here (And simplify it).
    private func update(_ task: Task, at indexPath: IndexPath) {
        let updateGroup = DispatchGroup()

        updateGroup.enter()
        tasks = tasks.map { (arrayTask) -> Task in
            if arrayTask.id == task.id {
                return task
            }

            return arrayTask
        }

        searchResultTasks = searchResultTasks.map { (arrayTask) -> Task in
            if arrayTask.id == task.id {
                return task
            }

            return arrayTask
        }

        unfilteredTasks = unfilteredTasks.map { (arrayTask) -> Task in
            if arrayTask.id == task.id {
                return task
            }

            return arrayTask
        }
        updateGroup.leave()

        updateGroup.notify(queue: .main) { [unowned self] in
            if let user = self.user {
                FireBaseManager.update(task, for: user)
            }

            self.tableView.reloadRows(at: [indexPath], with: .none)
        }
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

    func addTaskViewControllerDelegate(_ controller: AddTaskViewController, didUpdate task: Task) {
        guard let indexPath = indexPathForSelectedTask else {
            return
        }

        update(task, at: indexPath)
    }

    func addTaskViewControllerDelegate(_ controller: AddTaskViewController, didFinishWith task: Task) {

        if let user = user {
            FireBaseManager.save(task, for: user)
        }

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

extension TaskListTableViewController: TaskCellDelegate {
    func editButtonPressed(for indexPath: IndexPath?) {
        guard let indexPath = indexPath else {
            return
        }
        indexPathForSelectedTask = indexPath

        if isSearching {
            selectedTask = searchResultTasks[indexPath.row]
        } else {
            selectedTask = tasks[indexPath.row]
        }

        performSegue(withIdentifier: "addTaskSegue", sender: nil)
    }

    func statusIconPressed(for indexPath: IndexPath?) {
        guard let indexPath = indexPath else {
            return
        }
        var task: Task

        if isSearching {
            task = searchResultTasks[indexPath.row]
        } else {
            task = tasks[indexPath.row]
        }

        let oldStatus = task.status

        if oldStatus == .pending {
            task.status = .done
        } else {
            task.status = .pending
        }

        update(task, at: indexPath)
    }
}

extension TaskListTableViewController: FirebaseSignOutDelegate {
    func signOutDidFail(with error: Error) {
        //TODO: Display alert
        print(error)
    }
}
