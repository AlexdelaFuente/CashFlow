//
//  Encryptor.swift
//  CashFlow
//
//  Created by Alex de la Fuente Martín on 2/8/24.
//

import Foundation
import CryptoSwift


class Encryptor {
    
    static let key = generateKey(password: "Csh24Flw", salt: "flwcsh")

    
    private static func generateKey(password: String, salt: String) -> [UInt8]? {
        let passwordBytes = Array(password.utf8)
        let saltBytes = Array(salt.utf8)
        do {
            let key = try PKCS5.PBKDF2(
                password: passwordBytes,
                salt: saltBytes,
                iterations: 4096,
                keyLength: 32, // AES-256
                variant: .sha2(.sha256)
            ).calculate()
            return key
        } catch {
            print("Error generating key: \(error)")
            return nil
        }
    }
    
    
    static func encryptData(data: String) -> String? {
        do {
            let iv: Array<UInt8> = [56, 97, 164, 29, 134, 203, 22, 68, 225, 3, 8, 239, 65, 121, 106, 247]
            let aes = try AES(key: key!, blockMode: CBC(iv: iv), padding: .pkcs7)
            let ciphertext = try aes.encrypt(Array(data.utf8))
            let encryptedData = Data(ciphertext).base64EncodedString()
            return encryptedData
        } catch {
            print("Error encrypting: \(error)")
            return nil
        }
    }
    
    
    static func decryptData(encryptedData: String) -> String? {
        do {
            guard let data = Data(base64Encoded: encryptedData) else { return nil }
            let iv: Array<UInt8> = [56, 97, 164, 29, 134, 203, 22, 68, 225, 3, 8, 239, 65, 121, 106, 247]
            let aes = try AES(key: key!, blockMode: CBC(iv: iv), padding: .pkcs7)
            let decrypted = try aes.decrypt(data.bytes)
            return String(bytes: decrypted, encoding: .utf8)
        } catch {
            print("Error decrypting: \(error)")
            return nil
        }
    }
}
