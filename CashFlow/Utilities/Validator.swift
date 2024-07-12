//
//  Validator.swift
//  CashFlow
//
//  Created by Alex de la Fuente Martín on 19/6/24.
//

import Foundation

class Validator {
    
    static func isValidEmail(for email: String) -> Bool {
        let email = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.{1}[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    
    static func isValidUsername(for username: String) -> Bool {
        let username = username.trimmingCharacters(in: .whitespacesAndNewlines)
        let usernameRegEx = "[\\w\\s]{4,16}"
        let usernamePred = NSPredicate(format: "SELF MATCHES %@", usernameRegEx)
        return usernamePred.evaluate(with: username)
    }
    
    
    static func isPasswordValid(for password: String) -> Bool {
        let password = password.trimmingCharacters(in: .whitespacesAndNewlines)
        let passwordRegEx = "^(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9])(?=.*[$@$#!%*?&]).{6,32}$"
        let passwordPred = NSPredicate(format: "SELF MATCHES %@", passwordRegEx)
        return passwordPred.evaluate(with: password)
    }
    
    
    static func isValidPhoneNumber(for phoneNumber: String) -> Bool {
        let phoneNumber = phoneNumber.trimmingCharacters(in: .whitespacesAndNewlines)
        let phoneNumberRegEx = "^[0-9]{9}$"
        let phoneNumberPred = NSPredicate(format: "SELF MATCHES %@", phoneNumberRegEx)
        return phoneNumberPred.evaluate(with: phoneNumber)
    }
    
    
    static func isValidZipCode(for zipCode: String) -> Bool {
            let zipCode = zipCode.trimmingCharacters(in: .whitespacesAndNewlines)
            let zipCodeRegEx = "^[0-9]{5}$"
            let zipCodePred = NSPredicate(format: "SELF MATCHES %@", zipCodeRegEx)
            return zipCodePred.evaluate(with: zipCode)
    }
    
    
    static func isValidDescription(for description: String) -> Bool {
        let description = description.trimmingCharacters(in: .whitespacesAndNewlines)
        let descriptionRegEx = "[\\w\\s]{2,20}"
        let descriptionPred = NSPredicate(format: "SELF MATCHES %@", descriptionRegEx)
        return descriptionPred.evaluate(with: description)
    }
    
}
