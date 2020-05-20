//
//  TaskCell.swift
//  TodoList
//
//  Created by Omar Padierna on 2020-05-19.
//  Copyright © 2020 Omar Padierna. All rights reserved.
//

import UIKit

protocol TaskCellDelegate: class {
    func statusIconPressed(for indexPath: IndexPath?)
    func editButtonPressed(for indexPath: IndexPath?)
}

class TaskCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel! 
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var statusButton: UIButton!

    @IBAction func statusButtonPressed(_ sender: Any) {
        delegate?.statusIconPressed(for: indexPath)
    }

    @IBAction func editButtonTapped(_ sender: Any) {
        delegate?.editButtonPressed(for: indexPath)
    }

    weak var delegate: TaskCellDelegate?
    var indexPath: IndexPath?
}
