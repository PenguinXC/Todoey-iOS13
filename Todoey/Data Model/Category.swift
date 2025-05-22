//
//  Category.swift
//  Todoey
//
//  Created by VuNA on 22/5/25.
//  Copyright © 2025 App Brewery. All rights reserved.
//

import Foundation
import RealmSwift

class Category: Object {
    @objc dynamic var name: String = ""
    
    // forward relationship
    let items = List<Item>()
}

