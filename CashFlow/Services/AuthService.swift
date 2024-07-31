//
//  AuthService.swift
//  CashFlow
//
//  Created by Alex de la Fuente Martín on 19/6/24.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

class AuthService {
    
    public static let shared = AuthService()
    
    private init() {}
    
    
    /// A method to register the user
    /// - Parameters:
    ///   - userRequest: The users information (email, password, username)
    ///   - completion: A completion with two values...
    ///   - Bool: wasRegistered - Determines if the user was registered and saved in the database correctly
    ///   - Error?: An Optional error if firebase provides one
    public func registerUser(with userRequest: RegisterUserRequest, completion: @escaping (Bool, Error?) -> Void) {
        
        let username = userRequest.username
        let email = userRequest.email
        let password = userRequest.password
        
        let currency = Currency.euro
        let language = Language.english
        
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                completion(false, error)
                return
            }
            
            guard let resultUser = result?.user else {
                completion(false, nil)
                return
            }
            
            let db = Firestore.firestore()
            db.collection("users").document(resultUser.uid).setData([
                "username": username,
                "email": email.lowercased(),
                "currency": currency.description,
                "language": language.name,
                "birthDate": Date(),
                "phoneNumber": "",
                "address": "",
                "city": "",
                "zipCode": ""
            ]) { error in
                if let error = error {
                    completion(false, error)
                    return
                }
                
                resultUser.sendEmailVerification { error in
                    if let error = error {
                        completion(false, error)
                        return
                    }
                    do {
                        try? Auth.auth().signOut()
                    }
                    completion(true, nil)
                }
            }
        }
    }
    
    
    public func signIn( with userRequest: LoginUserRequest, completion: @escaping (Error?) -> Void) {
        let email = userRequest.email
        let password = userRequest.password
        
        Auth.auth().signIn(withEmail: email, password: password) {result, error in
            if let error = error {
                completion(error)
                return
            }else{
                completion(nil)
            }
        }
    }
    
    
    public func signOut(completion: @escaping (Error?) -> Void) {
        do {
            try Auth.auth().signOut()
            completion(nil)
        } catch let error {
            completion(error)
        }
    }
    
    
    public func forgotPassword(with email:String, completion: @escaping (Error?) -> Void) {
        Auth.auth().sendPasswordReset(withEmail: email) {error in
            completion(error)
        }
    }
    
    
    public func fetchUser(completion: @escaping (User?, Error?)-> Void) {
        guard let userUID = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        let document = db.collection("users").document(userUID)
        document.getDocument { snapshot, error in
            if let error = error {
                completion(nil, error)
                return
            }
            var transactions: [Transaction] = []
            
            if let snapshot = snapshot,
               let snapshotData = snapshot.data(),
               let username = snapshotData["username"] as? String,
               let email = snapshotData["email"] as? String,
               let currencyString = snapshotData["currency"] as? String, let currency = Currency(currencyString),
               let languageString = snapshotData["language"] as? String, let language = Language(languageString),
               let birthTimestamp = snapshotData["birthDate"] as? Timestamp,
               let phoneNumber = snapshotData["phoneNumber"] as? String,
               let address = snapshotData["address"] as? String,
               let city = snapshotData["city"] as? String,
               let zipCode = snapshotData["zipCode"] as? String {
                let birthDate = birthTimestamp.dateValue()
                
                document.collection("transactions").getDocuments { snapshot, error in
                    
                    if let snapshot = snapshot {
                        
                        if(snapshot.documents.isEmpty) {
                            let user = User(username: username, email: email.lowercased(), userUID: userUID, currency: currency, language: language, birthDate: birthDate, phoneNumber: phoneNumber, address: address, city: city, zipCode: zipCode, transactions: [])
                            completion(user, nil)
                        }
                        
                        snapshot.documents.forEach { documentSnapshot in
                            let snapshotData = documentSnapshot.data()
                            if let description = snapshotData["description"] as? String,
                            let money = snapshotData["money"] as? Double,
                            let dateTimestamp = snapshotData["date"] as? Timestamp,
                            let transactionTypeRawValue = snapshotData["transactionType"] as? String, let transactionType = TransactionType(rawValue: transactionTypeRawValue),
                            let moneyTypeRawValue = snapshotData["moneyType"] as? String, let moneyType = MoneyType(rawValue: moneyTypeRawValue),
                            let location = snapshotData["location"] as? GeoPoint,
                            let categoryRawValue = snapshotData["category"] as? String, let category = Category(rawValue: categoryRawValue){
                                let uuid = UUID(uuidString: documentSnapshot.documentID)
                                let date = dateTimestamp.dateValue()
                                let transaction = Transaction(id: uuid!, description: description, money: money, date: date, transactionType: transactionType, moneyType: moneyType, location: location, category: category)
                                transactions.append(transaction)
                                
                                let user = User(username: username, email: email.lowercased(), userUID: userUID, currency: currency, language: language, birthDate: birthDate, phoneNumber: phoneNumber, address: address, city: city, zipCode: zipCode, transactions: transactions.sorted(by: { $0.date > $1.date }))
                                completion(user, nil)
                            }
                            
                        }
                    }
                }
            }
        }
    }
    
    
    public func updateCurrency(newCurrency: Currency, completion: @escaping (Error?) -> Void) {
        guard let userUID = Auth.auth().currentUser?.uid else { return }
        
        let db = Firestore.firestore()
        db.collection("users").document(userUID).updateData([
            "currency": newCurrency.description
        ]) { error in
            if let error = error {
                completion(error)
                return
            }
            completion(nil)
        }
    }
    
    
    public func updateLanguage(newLanguage: Language, completion: @escaping (Error?) -> Void) {
        guard let userUID = Auth.auth().currentUser?.uid else { return }
        
        let db = Firestore.firestore()
        db.collection("users").document(userUID).updateData([
            "language": newLanguage.name
        ]) { error in
            if let error = error {
                completion(error)
                return
            }
            completion(nil)
        }
    }
    
    
    public func changePassword(currentPassword: String, newPassword: String, completion: @escaping (Error?) -> Void) {
        guard let user = Auth.auth().currentUser,
              let email = user.email else { return }
        
        let credential = EmailAuthProvider.credential(withEmail: email, password: currentPassword)
        
        user.reauthenticate(with: credential) { _, error in
            if let error = error {
                completion(error)
                return
            }
            
            user.updatePassword(to: newPassword) { error in
                if let error = error {
                    completion(error)
                    return
                }
                
                completion(nil)
            }
        }
    }
    
    
    public func updatePersonalInfo(user: User, completion: @escaping (Error?) -> Void) {
        guard let userUID = Auth.auth().currentUser?.uid else { return }
        
        let db = Firestore.firestore()
        db.collection("users").document(userUID).updateData([
            "username": user.username,
            "birthDate": user.birthDate,
            "phoneNumber": user.phoneNumber,
            "address": user.address,
            "city": user.city,
            "zipCode": user.zipCode
        ]) { error in
            if let error = error {
                completion(error)
                return
            }
            completion(nil)
        }
    }
    
    
    public func insertTransaction(transaction: Transaction, completion: @escaping (Error?) -> Void) {
        guard let userUID = Auth.auth().currentUser?.uid else { return }
        
        let db = Firestore.firestore()
        db.collection("users").document(userUID).collection("transactions").document(transaction.id.uuidString).setData([
            "description": transaction.description,
            "money": transaction.money,
            "date": transaction.date,
            "transactionType": transaction.transactionType.rawValue,
            "moneyType": transaction.moneyType.rawValue,
            "location": transaction.location,
            "category": transaction.category.rawValue
        ]) { error in
            if let error = error {
                completion(error)
                return
            }
            completion(nil)
        }
    }
    
    
    public func updateTransaction(transaction: Transaction, completion: @escaping (Error?) -> Void) {
        guard let userUID = Auth.auth().currentUser?.uid else { return }
        
        let db = Firestore.firestore()
        db.collection("users").document(userUID).collection("transactions").document(transaction.id.uuidString).updateData([
            "description": transaction.description,
            "money": transaction.money,
            "date": transaction.date,
            "transactionType": transaction.transactionType.rawValue,
            "moneyType": transaction.moneyType.rawValue,
            "location": transaction.location,
            "category": transaction.category.rawValue
        ]) { error in
            if let error = error {
                completion(error)
                return
            }
            completion(nil)
        }
    }
    
    
    public func deleteTransaction(transaction:Transaction, completion: @escaping (Error?) -> Void) {
        guard let userUID = Auth.auth().currentUser?.uid else { return }
        
        let db = Firestore.firestore()
        db.collection("users").document(userUID).collection("transactions").document(transaction.id.uuidString).delete { error in
            if let error = error {
                completion(error)
                return
            }
            completion(nil)
        }
        
        
    }
    
    
}


