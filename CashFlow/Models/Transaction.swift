//
//  Transaction.swift
//  CashFlow
//
//  Created by Alex de la Fuente Martín on 25/6/24.
//

import Foundation
import FirebaseFirestoreInternal

struct Transaction {
    
    var id: UUID
    var description: String
    var money: Double
    var date: Date
    
    var transactionType: TransactionType
    var moneyType: MoneyType
    
    var location: GeoPoint
    
    var category: Category
    
    var formattedMoneyString: String {
        let moneyPrefix = (transactionType == .income) ? "+" : "-"
        return "\(moneyPrefix)\(String(format: "%.2f", money))"
        
    }
}

extension Transaction: Equatable {}

extension Transaction: Hashable {}
