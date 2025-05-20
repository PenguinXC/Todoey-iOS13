//
//  Data.swift
//  Todoey
//
//  Created by VuNA on 21/5/25.
//  Copyright © 2025 App Brewery. All rights reserved.
//

import Foundation
import RealmSwift

class Data: Object {
    // dynamic means that the property is observable and can be used with Realm
    @objc dynamic var name: String = ""
    @objc dynamic var age: Int = 0
}
