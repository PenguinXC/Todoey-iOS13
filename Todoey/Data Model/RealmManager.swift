//
//  RealmManager.swift
//  Todoey
//
//  Created on 23/5/25.
//  Copyright © 2025 App Brewery. All rights reserved.
//

import Foundation
import RealmSwift

class RealmManager {
    
    // Singleton instance
    static let shared = RealmManager()
    
    // Private initializer to enforce singleton pattern
    private init() {}
    
    // MARK: - Configuration
    
    // Shared Realm configuration with encryption
    static var configuration: Realm.Configuration = {
        let userDefaults = UserDefaults.standard
        var key: Foundation.Data
        
        // Try to retrieve existing key from UserDefaults
        if let keyInUserDefaults = userDefaults.string(forKey: "realmEncryptionKey"),
           let binaryKey = Foundation.Data(hexString: keyInUserDefaults) {
            debugPrint("Using existing encryption key from UserDefaults")
            key = binaryKey
        } else {
            // Generate new key if none exists
            debugPrint("Generating new encryption key")
            key = Foundation.Data(count: 64)
            let status = key.withUnsafeMutableBytes { pointer in
                guard let baseAddress = pointer.baseAddress else {
                    fatalError("Failed to obtain base address")
                }
                return SecRandomCopyBytes(kSecRandomDefault, 64, baseAddress)
            }
            
            if status != errSecSuccess {
                fatalError("Failed to generate random bytes: \(status)")
            }
            
            // Save key to UserDefaults
            let hexKey = key.map { String(format: "%02hhx", $0) }.joined()
            userDefaults.set(hexKey, forKey: "realmEncryptionKey")
            debugPrint("Saved new encryption key to UserDefaults")
        }
        
        // Create and return configuration with encryption key
        return Realm.Configuration(encryptionKey: key)
    }()
    
    // MARK: - Realm Instance
    
    // Get a Realm instance with the shared configuration
    static func getRealm() -> Realm {
        do {
            let realm = try Realm(configuration: configuration)
            return realm
        } catch {
            fatalError("Failed to open Realm: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Database Operations
    
    // Save an object to Realm
    func save<T: Object>(_ object: T) {
        do {
            let realm = try Realm(configuration: RealmManager.configuration)
            try realm.write {
                realm.add(object)
            }
        } catch {
            print("Error saving object to Realm: \(error.localizedDescription)")
        }
    }
    
    // Fetch all objects of a certain type
    func fetchAll<T: Object>(_ type: T.Type) -> Results<T>? {
        do {
            let realm = try Realm(configuration: RealmManager.configuration)
            return realm.objects(type)
        } catch {
            print("Error fetching objects from Realm: \(error.localizedDescription)")
            return nil
        }
    }
    
    // Delete an object from Realm
    func delete<T: Object>(_ object: T) {
        do {
            let realm = try Realm(configuration: RealmManager.configuration)
            try realm.write {
                realm.delete(object)
            }
        } catch {
            print("Error deleting object from Realm: \(error.localizedDescription)")
        }
    }
    
    // Update an object in Realm with a transaction block
    func update(_ block: @escaping (Realm) -> Void) {
        do {
            let realm = try Realm(configuration: RealmManager.configuration)
            try realm.write {
                block(realm)
            }
        } catch {
            print("Error updating Realm: \(error.localizedDescription)")
        }
    }
}

// Extension to add hex string conversion if it doesn't exist elsewhere
extension Foundation.Data {
    init?(hexString: String) {
        let len = hexString.count / 2
        var data = Foundation.Data(capacity: len)
        for i in 0..<len {
            let j = hexString.index(hexString.startIndex, offsetBy: i*2)
            let k = hexString.index(j, offsetBy: 2)
            let bytes = hexString[j..<k]
            if let num = UInt8(bytes, radix: 16) {
                data.append(num)
            } else {
                return nil
            }
        }
        self = data
    }
}