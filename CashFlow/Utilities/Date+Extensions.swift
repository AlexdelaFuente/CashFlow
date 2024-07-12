//
//  Date+Extensions.swift
//  CashFlow
//
//  Created by Alex de la Fuente Martín on 12/7/24.
//

import Foundation

extension Date {
    
    func isToday() -> Bool {
        return Calendar.current.isDateInToday(self)
    }
    
    
    func isYesterday() -> Bool {
        return Calendar.current.isDateInYesterday(self)
    }
    
    
    func formattedString() -> String {
        if self.isToday() {
            return "Today"
        } else if self.isYesterday() {
            return "Yesterday"
        } else {
            let dateFormatter = DateFormatter()
            dateFormatter.timeStyle = .short
            dateFormatter.locale = Locale(identifier: "en_US_POSIX")

            if Calendar.current.isDate(self, equalTo: Date(), toGranularity: .year) {
                dateFormatter.dateFormat = "MMM d, HH:mm"
            } else {
                dateFormatter.dateFormat = "MMM d, yyyy, HH:mm"
            }
            
            return dateFormatter.string(from: self)
        }
    }
}
