//
//  Category.swift
//  Todoey
//
//  Created by 송태환 on 2020/03/13.
//  Copyright © 2020 App Brewery. All rights reserved.
//

import Foundation
import RealmSwift

class Category: Object {
    @objc dynamic var name: String = ""
    // set type and init (same as [Todo]())
    // Forward relationship
    let items = List<Todo>()
}
