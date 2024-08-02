//
//  DateRangeFilterViewController.swift
//  CashFlow
//
//  Created by Alex de la Fuente Martín on 27/6/24.
//

import UIKit
import HorizonCalendar

protocol DateRangeFilterViewControllerDelegate: AnyObject {
    func dateBeenSaved(firstDate: Date, secondDate: Date)
}

class DateRangeFilterViewController: UIViewController {
    
    public var calendarView: CalendarView!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var clearButton: UIButton!
    @IBOutlet var saveButton: UIButton!
    
    private var firstDay: Date?
    private var secondDay: Date?
    
    private var dateRangeToHighlight: ClosedRange<Date>?
    private var calendar: Calendar!
    private var startDate: Date!
    private var endDate: Date!
    
    public weak var delegate: DateRangeFilterViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        instantiateVars()
        
        setupButtons()
        setupCalendar()
    }
    
    private func setupCalendar() {
        calendarView = CalendarView(initialContent: makeContent(calendar: calendar, startDate: startDate, endDate: endDate))
        
        view.addSubview(calendarView)
        calendarView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            calendarView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            calendarView.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            calendarView.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 16),
            calendarView.bottomAnchor.constraint(equalTo: clearButton.topAnchor, constant: -8),
        ])
        
        setupCalendarTouchListener()
        self.calendarView.setContent(self.makeContent(calendar: self.calendar, startDate: self.startDate, endDate: self.endDate))
        self.calendarView.scroll(toMonthContaining: endDate, scrollPosition: .centered, animated: true)
    }
    
    private func setupCalendarTouchListener() {
        calendarView.multiDaySelectionDragHandler = { [weak self] day, state in
            guard let self = self else { return }
            self.clearButton.isEnabled = true
            self.saveButton.isEnabled = true
            let date = self.calendar.date(from: day.components)
            
            switch state {
            case .possible:
                return
            case .began:
                self.firstDay = date
                self.secondDay = date
            case .changed:
                self.secondDay = date
            case .ended:
                return
            case .cancelled:
                return
            case .failed:
                return
            @unknown default:
                return
            }
            
            guard let firstDay = self.firstDay, let secondDay = self.secondDay else { return }
            
            if firstDay < secondDay {
                self.dateRangeToHighlight = firstDay...secondDay
                self.dateLabel.text = "\(firstDay.formatted(date: .abbreviated, time: .omitted)) - \(secondDay.formatted(date: .abbreviated, time: .omitted))"
            } else if firstDay == secondDay {
                self.dateRangeToHighlight = firstDay...secondDay
                self.dateLabel.text = "\(firstDay.formatted(date: .abbreviated, time: .omitted))"
            } else {
                self.dateRangeToHighlight = secondDay...firstDay
                self.dateLabel.text = "\(secondDay.formatted(date: .abbreviated, time: .omitted)) - \(firstDay.formatted(date: .abbreviated, time: .omitted))"
            }
            self.calendarView.setContent(self.makeContent(calendar: self.calendar, startDate: self.startDate, endDate: self.endDate))
        }
    }
    
    private func setupButtons() {
        self.saveButton.isEnabled = false
        self.clearButton.isEnabled = false
    }
    
    private func instantiateVars() {
        calendar = Calendar.current
        
        startDate = Date()
        User.shared.transactions.forEach { transaction in
            if startDate > transaction.date {
                startDate = transaction.date
            }
        }
        endDate = startDate
        
        User.shared.transactions.forEach { transaction in
            if endDate < transaction.date {
                endDate = transaction.date
                endDate = calendar.date(byAdding: .hour, value: 2, to: endDate)
            }
        }
    }
    
    private func makeContent(calendar: Calendar, startDate: Date, endDate: Date) -> CalendarViewContent {
        var caldendarViewContent = CalendarViewContent(
            calendar: calendar,
            visibleDateRange: startDate...endDate,
            monthsLayout: .vertical(options: VerticalMonthsLayoutOptions(pinDaysOfWeekToTop: false, alwaysShowCompleteBoundaryMonths: false, scrollsToFirstMonthOnStatusBarTap: false)))
            .dayItemProvider { day in
                var dayHasTransaction = false
                User.shared.transactions.forEach { transaction in
                    if calendar.date(transaction.date, matchesComponents: day.components) {
                        dayHasTransaction = true
                    }
                }
                
                return DayLabel.calendarItemModel(
                    invariantViewProperties: .init(
                        font: UIFont.systemFont(ofSize: 18),
                        textColor: .label,
                        backgroundColor: .clear,
                        borderColor: dayHasTransaction ? .accent : .clear),
                    content: .init(day: day))
            }
            .interMonthSpacing(24)
            .verticalDayMargin(8)
            .horizontalDayMargin(8)
        
        if let dateRangeToHighlight = dateRangeToHighlight {
            caldendarViewContent = caldendarViewContent.dayRangeItemProvider(for: [dateRangeToHighlight]) { dayRangeLayoutContext in
                DayRangeIndicatorView.calendarItemModel(
                    invariantViewProperties: .init(),
                    content: .init(framesOfDaysToHighlight: dayRangeLayoutContext.daysAndFrames.map { $0.frame }))
            }
        }
        
        return caldendarViewContent
    }
    
    @IBAction func closeButtonTapped(_ sender: Any) {
        dismiss(animated: true)
    }
    
    @IBAction func clearButtonTapped(_ sender: Any) {
        dateRangeToHighlight = nil
        calendarView.setContent(makeContent(calendar: calendar, startDate: startDate, endDate: endDate), animated: true)
        clearButton.isEnabled = false
        self.saveButton.isEnabled = false
        self.dateLabel.text = "Long press and drag to select a range of days"
    }
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        if let firstDay = firstDay, let secondDay = secondDay {
            let firstDayToSave = firstDay < secondDay ? firstDay : secondDay
            let secondDayToSave = firstDay < secondDay ? secondDay : firstDay
            
            let adjustedFirstDay = calendar.date(byAdding: .hour, value: 2, to: firstDayToSave)!
            let adjustedSecondDay = calendar.date(byAdding: .hour, value: 26, to: secondDayToSave)!
            
            delegate?.dateBeenSaved(firstDate: adjustedFirstDay, secondDate: adjustedSecondDay)
            
            dismiss(animated: true)
        }
    }
}
