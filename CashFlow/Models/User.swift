//
//  User.swift
//  CashFlow
//
//  Created by Alex de la Fuente Martín on 20/6/24.
//

import Foundation

struct User {
    
    static var shared = User(username: "", email: "", userUID: "", currency: .euro, birthDate: Date(), phoneNumber: "", address: "", city: "", zipCode: "", transactions: [])
    
    var username: String
    var email: String
    var userUID: String
    
    var currency: Currency
    
    var birthDate: Date
    var phoneNumber: String
    var address: String
    var city: String
    var zipCode: String
    
    var transactions: [Transaction]
    
    
}

extension User: Equatable { }
