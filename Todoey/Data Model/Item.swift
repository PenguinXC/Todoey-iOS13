//
//  Item.swift
//  Todoey
//
//  Created by VuNA on 22/5/25.
//  Copyright © 2025 App Brewery. All rights reserved.
//

import Foundation
import RealmSwift

class Item: Object {
    @objc dynamic var title: String = ""
    @objc dynamic var done: Bool = false
    @objc dynamic var dateCreated: Date?
    
    // This is inverse relationship that links each Item back to its parent Category
    // property name must match the property name in Category (forward relationship)
    var parentCategory = LinkingObjects(fromType: Category.self, property: "items")
}

