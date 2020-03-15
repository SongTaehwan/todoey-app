//
//  Todo.swift
//  Todoey
//
//  Created by 송태환 on 2020/03/13.
//  Copyright © 2020 App Brewery. All rights reserved.
//

import Foundation
import RealmSwift

class Todo: Object {
    @objc dynamic var title: String = ""
    @objc dynamic var done: Bool = false
    @objc dynamic var createdAt: Date?
    // Inverse or Reverse relationship (type, counterpart proterty)
    var parentCategory = LinkingObjects(fromType: Category.self, property: "items")
}
