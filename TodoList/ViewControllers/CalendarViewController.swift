//
//  CalendarViewController.swift
//  TodoList
//
//  Created by Omar Padierna on 2020-05-19.
//  Copyright © 2020 Omar Padierna. All rights reserved.
//

import UIKit
import JTAppleCalendar

protocol CalendarViewControllerDelegate: class {
    func calendarViewController(didFinishWith date: Date)
}

class CalendarViewController: UIViewController {
    @IBOutlet weak var yearLabel: UILabel!
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var calendarView: JTAppleCalendarView!
    @IBOutlet weak var doneButton: UIButton!

    weak var delegate: CalendarViewControllerDelegate?

    var cancelEnabled: Bool?

    private var selectedDate: Date? {
        didSet {
            if selectedDate == nil {
                doneButton.isEnabled = false
            } else {
                doneButton.isEnabled = true
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        doneButton.isEnabled = false

        calendarView.visibleDates { (visibleDates) in
            let date = visibleDates.monthDates.first!.date
            let formatter = DateFormatter()

            formatter.dateFormat = "yyyy"
            self.yearLabel.text = formatter.string(from: date)

            formatter.dateFormat = "MMMM"
            self.monthLabel.text = formatter.string(from: date)
        }
    }

    func configureCell(view: JTAppleCell?, cellState: CellState) {
        guard let cell = view as? DateCell  else { return }
        cell.dateLabel.text = cellState.text
        if cellState.isSelected && cellState.dateBelongsTo == .thisMonth {
            cell.selectedView.isHidden = false
        } else {
            cell.selectedView.isHidden = true
        }
        handleCellTextColor(cell: cell, cellState: cellState)
    }

    func handleCellTextColor(cell: DateCell, cellState: CellState) {
        if cellState.dateBelongsTo == .thisMonth {
            cell.dateLabel.textColor = UIColor.black
        } else {
            cell.dateLabel.textColor = UIColor.gray
        }
    }

    @IBAction func didTapDoneButton(_ sender: Any) {
        guard let selectedDate = selectedDate else {
            return
        }

        delegate?.calendarViewController(didFinishWith: selectedDate)
        self.dismiss(animated: true, completion: nil)
    }

}

extension CalendarViewController: JTAppleCalendarViewDataSource {
    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy MM dd"
        let startDate = Date()
        let endDate = Date(timeInterval: 31536000, since: Date())
        return ConfigurationParameters(startDate: startDate, endDate: endDate)
    }
}

extension CalendarViewController: JTAppleCalendarViewDelegate {
    func calendar(_ calendar: JTAppleCalendarView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTAppleCell {

        let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: "dateCell", for: indexPath) as! DateCell
        self.calendar(calendar, willDisplay: cell, forItemAt: date, cellState: cellState, indexPath: indexPath)
        return cell

    }

    func calendar(_ calendar: JTAppleCalendarView, willDisplay cell: JTAppleCell, forItemAt date: Date, cellState: CellState, indexPath: IndexPath) {
        configureCell(view: cell, cellState: cellState)
    }

    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        guard let cell = cell as? DateCell else { return }

        if cellState.dateBelongsTo == .thisMonth {
            cell.selectedView.isHidden = false
        }

        selectedDate = date
    }

    func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        guard let cell = cell as? DateCell else { return }

        cell.selectedView.isHidden = true
    }

    func calendar(_ calendar: JTAppleCalendarView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        
        let date = visibleDates.monthDates.first!.date
        let formatter = DateFormatter()

        formatter.dateFormat = "yyyy"
        yearLabel.text = formatter.string(from: date)

        formatter.dateFormat = "MMMM"
        monthLabel.text = formatter.string(from: date)
    }
}
