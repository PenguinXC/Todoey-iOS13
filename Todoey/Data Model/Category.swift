//
//  Category.swift
//  Todoey
//
//  Created by VuNA on 22/5/25.
//  Copyright © 2025 App Brewery. All rights reserved.
//

import Foundation
import RealmSwift

// Category class is subclass of Realm's Object class, this makes it able to be stored in Realm database
class Category: Object {
    @objc dynamic var name: String = ""
    
    // Forward relationship
    // This relationship means that each Category can have multiple items
    let items = List<Item>()
}

