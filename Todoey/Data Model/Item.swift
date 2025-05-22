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
    
    // The relationship to the Category object
    // parentCategory is defining inverse relationship to the items property in Category
    // property name must match the property name in Category (forward relationship)
    var parentCategory = LinkingObjects(fromType: Category.self, property: "items")
}

