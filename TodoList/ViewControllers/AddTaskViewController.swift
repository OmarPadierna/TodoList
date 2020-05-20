//
//  AddTaskViewController.swift
//  TodoList
//
//  Created by Omar Padierna on 2020-05-19.
//  Copyright © 2020 Omar Padierna. All rights reserved.
//

import UIKit

protocol AddTaskViewControllerDelegate: class {
    func addTaskViewControllerDelegate(_ controller: AddTaskViewController, didFinishWith task: Task)
}

class AddTaskViewController: UIViewController {
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var dateLabel: UILabel!

    private var textViewPlaceHolder = "Add a nice description..."

    weak var delegate: AddTaskViewControllerDelegate?

    var taskDate: Date?

    override func viewDidLoad() {
        super.viewDidLoad()

        dateLabel.isUserInteractionEnabled = true
        let gestureRecognizer = UITapGestureRecognizer(target: self, action:#selector(dateLabelPressed))
        dateLabel.addGestureRecognizer(gestureRecognizer)

        descriptionTextView.delegate = self
        descriptionTextView.text = textViewPlaceHolder
        descriptionTextView.textColor = .systemGray2
    }

    @objc func dateLabelPressed() {
        performSegue(withIdentifier: "calendarViewSegue", sender: nil)
    }

    @IBAction func doneButtonTapped(_ sender: Any) {
        var description = ""

        guard let title = titleTextField.text, title.isEmpty == false else {
            titleTextField.attributedPlaceholder = NSAttributedString(string: "Please add a title", attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
            return
        }

        guard let date = taskDate else {
            //TODO: Display alert here.
            return
        }

        if descriptionTextView.text != textViewPlaceHolder {
            description = descriptionTextView.text
        }

        let newTask = Task(title: title, description: description, dueDate: date)
        
        delegate?.addTaskViewControllerDelegate(self, didFinishWith: newTask)

        navigationController?.popViewController(animated: true)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch (segue.destination, segue.identifier) {
        case (let vc as CalendarViewController, _):
            vc.delegate = self
        default:
            print("Unknown segue")
        }
    }
}

extension AddTaskViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == .some(.systemGray2) {
            textView.text = nil
            textView.textColor = .black
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = textViewPlaceHolder
            textView.textColor = .systemGray2
        }
    }
}

extension AddTaskViewController: CalendarViewControllerDelegate {
    func calendarViewController(didFinishWith date: Date) {
        let dateFormatter = DateFormatter()

        dateFormatter.timeStyle = .none
        dateFormatter.dateStyle = .medium

        dateLabel.text = dateFormatter.string(from: date)

        taskDate = date
    }
}

