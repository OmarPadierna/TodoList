//
//  CalendarViewController.swift
//  TodoList
//
//  Created by Omar Padierna on 2020-05-19.
//  Copyright © 2020 Omar Padierna. All rights reserved.
//

import UIKit
import JTAppleCalendar

class CalendarViewController: UIViewController {
    @IBOutlet weak var yearLabel: UILabel!
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var calendarView: JTAppleCalendarView!

    override func viewDidLoad() {
        super.viewDidLoad()

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
    }

    func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        guard let cell = cell as? DateCell else { return }

        cell.selectedView.isHidden = true
    }

    func calendar(_ calendar: JTAppleCalendarView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        //TODO: Check if this force unwrapping is safe.
        let date = visibleDates.monthDates.first!.date
        let formatter = DateFormatter()

        formatter.dateFormat = "yyyy"
        yearLabel.text = formatter.string(from: date)

        formatter.dateFormat = "MMMM"
        monthLabel.text = formatter.string(from: date)
    }
}
