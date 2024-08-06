//
//  Category.swift
//  CashFlow
//
//  Created by Alex de la Fuente Martín on 31/7/24.
//

import UIKit

enum Category: String {
    case general, entertainment, shopping, groceries, restaurants, salary, transportation, traveling, healthcare
    
    var title: String {
        switch self {
        case .general:
            return "General"
        case .entertainment:
            return "Entertainment"
        case .shopping:
            return "Shopping"
        case .groceries:
            return "Groceries"
        case .salary:
            return "Salary"
        case .transportation:
            return "Transportation"
        case .traveling:
            return "Traveling"
        case .healthcare:
            return "Healthcare"
        case .restaurants:
            return "Restaurants"
        }
    }
    
    var image: UIImage {
        switch self {
        case .general:
            return UIImage(systemName: SFSymbols.general)!
        case .entertainment:
            return UIImage(systemName: SFSymbols.gamecontroller)!
        case .shopping:
            return UIImage(systemName: SFSymbols.cart)!
        case .groceries:
            return UIImage(systemName: SFSymbols.groceries)!
        case .salary:
            return UIImage(systemName: SFSymbols.banknote)!
        case .transportation:
            return UIImage(systemName: SFSymbols.car)!
        case .traveling:
            return UIImage(systemName: SFSymbols.airplane)!
        case .healthcare:
            return UIImage(systemName: SFSymbols.healthcare)!
        case .restaurants:
            return UIImage(systemName: SFSymbols.forkKnife)!
        }
    }
    
    var color: UIColor {
            switch self {
            case .general:
                return UIColor.systemGray
            case .entertainment:
                return UIColor.systemPurple
            case .shopping:
                return UIColor.systemBlue
            case .groceries:
                return UIColor.systemMint
            case .salary:
                return UIColor.accent
            case .transportation:
                return UIColor.systemOrange
            case .traveling:
                return UIColor.systemTeal
            case .healthcare:
                return UIColor.systemRed
            case .restaurants:
                return UIColor.systemPink
            }
        }
}

