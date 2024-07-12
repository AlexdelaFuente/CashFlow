//
//  Language.swift
//  CashFlow
//
//  Created by Alex de la Fuente Martín on 24/6/24.
//

import Foundation

enum Language {
    case english, spanish
    
    var name: String {
        switch self {
            
        case .english:
            "English"
        case .spanish:
            "Español"
        }
    }
    
    
    init?(_ string: String) {
        switch string {
        case "English":
            self = .english
        case "Español":
            self = .spanish
        default:
            return nil
        }
    }
    
}
