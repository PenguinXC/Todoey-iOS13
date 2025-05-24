//
//  AppDelegate.swift
//  Destini
//
//  Created by Philipp Muellauer on 01/09/2015.
//  Copyright (c) 2015 London App Brewery. All rights reserved.
//

import UIKit
import RealmSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    let userDefaults = UserDefaults.standard
    
    var window: UIWindow?
    
    // Updated with lazy initialization to ensure encryption is set up properly
    static var config: Realm.Configuration = {
        let userDefaults = UserDefaults.standard
        var key: Foundation.Data
        
        // Try to retrieve existing key from UserDefaults
        if let keyHexInUserDefaults = userDefaults.string(forKey: "realmEncryptionKey"),
           let keyBinary = Foundation.Data(hexString: keyHexInUserDefaults) {
            debugPrint("Using existing encryption key from UserDefaults")
            debugPrint("Existing encryption key: \(keyHexInUserDefaults)")
            key = keyBinary
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
            debugPrint("New encryption key: \(hexKey)")
        }
        
        // Create and return configuration with encryption key
        return Realm.Configuration(encryptionKey: key)
    }()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        debugPrint("didFinishLaunchingWithOptions")
        debugPrint("Path to the app document directory: \(NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last as String? ?? "Could not find document directory")")
        
        // Print contents of the document directory
        let fileManager = FileManager.default
        let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last!
        do {
            let contents = try fileManager.contentsOfDirectory(atPath: documentDirectory)
            print("Contents of the document directory: \(contents)")
        } catch {
            print("Error while enumerating files \(documentDirectory): \(error.localizedDescription)")
        }

        // Print the path to the Realm file
        debugPrint("Realm file path: \(Realm.Configuration.defaultConfiguration.fileURL!)")
        // "Realm file path: file:///Users/vuna/Library/Developer/CoreSimulator/Devices/B25FD894-26DD-467E-A9B2-0BD44E97C99B/data/Containers/Data/Application/D20F63B9-38D6-4258-86DD-46307DD97007/Documents/default.realm"
        
        // Test the configuration (using the already initialized config from static property)
        do {
            _ = try Realm(configuration: AppDelegate.config)
            debugPrint("Successfully opened encrypted Realm")
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
