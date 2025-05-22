//
//  AppDelegate.swift
//  Destini
//
//  Created by Philipp Muellauer on 01/09/2015.
//  Copyright (c) 2015 London App Brewery. All rights reserved.
//

import UIKit
import CoreData
import RealmSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    let userDefaults = UserDefaults.standard
    
    var window: UIWindow?
    
    // Updated with lazy initialization to ensure encryption is set up properly
    static var config: Realm.Configuration = {
        let userDefaults = UserDefaults.standard
        var key = Foundation.Data(count: 64)
        
        // Try to retrieve existing key from UserDefaults
        if let keyInUserDefaults = userDefaults.string(forKey: "realmEncryptionKey"),
           let binaryKey = Foundation.Data(hexString: keyInUserDefaults) {
            print("Using existing encryption key from UserDefaults")
            key = binaryKey
        } else {
            // Generate new key if none exists
            print("Generating new encryption key")
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
            print("Saved new encryption key to UserDefaults")
        }
        
        // Create and return configuration with encryption key
        return Realm.Configuration(encryptionKey: key)
    }()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        debugPrint("didFinishLaunchingWithOptions")
        debugPrint("Path to the app document directory: \(NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last as String? ?? "Could not find document directory")")
        // iPhone: "/var/mobile/Containers/Data/Application/01922EA9-9114-4059-BD65-8985BAB4914F/Documents"
        // My Mac (Designed for iPad): "/Users/vuna/Library/Containers/290517DA-0064-46C4-8B76-843694654D14/Data/Documents"
        // Print contents of the document directory
        let fileManager = FileManager.default
        let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last!
        do {
            let contents = try fileManager.contentsOfDirectory(atPath: documentDirectory)
            print("Contents of the document directory: \(contents)")
        } catch {
            print("Error while enumerating files \(documentDirectory): \(error.localizedDescription)")
        }

        var key = Foundation.Data(count: 64)
        // Check if the key exists in the user.defaults
        if let keyInUserDefaults = userDefaults.string(forKey: "realmEncryptionKey") {
            debugPrint("Key exists in user defaults: \(keyInUserDefaults)")
            // Convert keyInUserDefaults from hex String to Foundation.Data
            if let binaryKey = Foundation.Data(hexString: keyInUserDefaults) {
                debugPrint("Key in Foundation.Data: \(binaryKey)")
                key = binaryKey
            }
        } else {
            debugPrint("Key does not exist in user defaults")
            // Generate a random encryption key
            key = Foundation.Data(count: 64)
            let status = key.withUnsafeMutableBytes { (pointer: UnsafeMutableRawBufferPointer) in
                guard let baseAddress = pointer.baseAddress else {
                    fatalError("Failed to obtain base address")
                }
                return SecRandomCopyBytes(kSecRandomDefault, 64, baseAddress)
            }
            
            if status != errSecSuccess {
                fatalError("Failed to generate random bytes: \(status)")
            }
            
            let hexKey = key.map { String(format: "%02hhx", $0) }.joined()
            userDefaults.set(hexKey, forKey: "realmEncryptionKey")
            // Print the encryption key in hexadecimal format
            debugPrint("Encryption key in hex: \(hexKey)")
            debugPrint("Encryption key in B64: \(key.base64EncodedString())")
        }
        
        // Initialize Realm
        // Add the encryption key to the config and open the realm
        let config = Realm.Configuration(encryptionKey: key)
        AppDelegate.config = config
        
        // Print the path to the Realm file
        debugPrint("Realm file path: \(Realm.Configuration.defaultConfiguration.fileURL!)")
        
        do{
            let realm = try Realm(configuration: config)
        } catch {
            print("Error initializing Realm, \(error)")
        }
        
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        debugPrint("applicationDidEnterBackground")
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        debugPrint("applicationWillTerminate")
        debugPrint("When the application is in the background, and iOS needs resources, it will call this method to terminate the current app.")
        
        self.saveContext()
    }
    
    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "DataModel")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    // Core Data path:
    // /Users/vuna/Library/Developer/Xcode/DerivedData/Todoey-furobhpizqiwzyfoauncztntfqgo/Build/Intermediates.noindex/Todoey.build/Debug-iphonesimulator/Todoey.build/DerivedSources/CoreDataGenerated/DataModel
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}

// Extension to add hex string conversion
// This extension adds a method to convert a hex string to Foundation.Data
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
