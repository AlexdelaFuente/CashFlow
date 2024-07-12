//
//  Currency.swift
//  CashFlow
//
//  Created by Alex de la Fuente Martín on 24/6/24.
//

import Foundation

enum Currency {
    case euro, dollar
    
    var symbol: String {
        switch self {
        case .euro:
            return "€"
        case .dollar:
            return "$"
        }
    }
    
    var description: String {
        switch self {
        case .euro:
            return "Euro"
        case .dollar:
            return "Dollar"
        }
    }
    
    init?(_ string: String) {
        switch string {
        case "Euro":
            self = .euro
        case "Dollar":
            self = .dollar
        default:
            return nil
        }
    }
    
}
