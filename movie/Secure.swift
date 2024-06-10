//
//  Secure.swift
//  movie
//
//  Created by oscar perdana on 07/06/24.
//

import Foundation
import KeychainSwift
import CryptoKit

func saveCredentials(username: String, password: String) {
    let keychain = KeychainSwift()
    keychain.set(username, forKey: "username")
    keychain.set(password, forKey: "password")
}

func loadCredentials() -> (String, String)? {
    let keychain = KeychainSwift()
    if let username = keychain.get("username"), let password = keychain.get("password") {
        return (username, password)
    }
    return nil
}

extension String {
    func MD5() -> String {
        let inputData = Data(self.utf8)
        let hashed = Insecure.MD5.hash(data: inputData)
        let hashString = hashed.map { String(format: "%02hhx", $0) }.joined()
        return hashString
    }
}
