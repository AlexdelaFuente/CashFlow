//
//  DayLabel.swift
//  CashFlow
//
//  Created by Alex de la Fuente Martín on 27/6/24.
//

import HorizonCalendar

struct DayLabel: CalendarItemViewRepresentable {
    
    /// Properties that are set once when we initialize the view.
    struct InvariantViewProperties: Hashable {
        let font: UIFont
        let textColor: UIColor
        let backgroundColor: UIColor
        let borderColor: UIColor
    }
    
    /// Properties that will vary depending on the particular date being displayed.
    struct Content: Equatable {
        let day: DayComponents
    }
    
    static func makeView(
        withInvariantViewProperties invariantViewProperties: InvariantViewProperties)
    -> UILabel
    {
        let label = UILabel()
        
        label.backgroundColor = invariantViewProperties.backgroundColor
        label.font = invariantViewProperties.font
        label.textColor = invariantViewProperties.textColor
        label.layer.borderColor = invariantViewProperties.borderColor.cgColor
        label.layer.borderWidth = 2
        label.textAlignment = .center
        label.clipsToBounds = true
        label.layer.cornerRadius = 12
        
        return label
    }
    
    static func setContent(_ content: Content, on view: UILabel) {
        view.text = "\(content.day.day)"
    }
    
}
