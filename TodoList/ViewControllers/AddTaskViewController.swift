//
//  AddTaskViewController.swift
//  TodoList
//
//  Created by Omar Padierna on 2020-05-19.
//  Copyright © 2020 Omar Padierna. All rights reserved.
//

import UIKit

class AddTaskViewController: UIViewController {
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var dateLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        dateLabel.isUserInteractionEnabled = true

        let gestureRecognizer = UITapGestureRecognizer(target: self, action:#selector(dateLabelPressed))
        dateLabel.addGestureRecognizer(gestureRecognizer)
    }

    @objc func dateLabelPressed() {
        performSegue(withIdentifier: "calendarViewSegue", sender: nil)
    }

}

