//
//  Category.swift
//  itShop
//
//  Created by Raša on 11/02/2020.
//  Copyright © 2020 Rasa. All rights reserved.
//

import Foundation

`struct Items: Codable {
    let items: [Category]
}

struct Category: Codable {
    let Id: Int
    let Name: String
    let Description: String
    let ChildsExist: Bool
    let ImageUrl: String
    let ChildCategories: Array<Category>
}

class Category2 {
    var id: Int
    
    init(a: Category) {
        self.id = a.Id
    }
}

items: {[{let Id: Int
    let Name: String
    let Description: String
    let ChildsExist: Bool
    let ImageUrl: String
    let ChildCategories: Array<Category>},
{let Id: Int
    let Name: String
    let Description: String
    let ChildsExist: Bool
    let ImageUrl: String
    let ChildCategories: Array<Category>},
{let Id: Int
    let Name: String
    let Description: String
    let ChildsExist: Bool
    let ImageUrl: String
    let ChildCategories: Array<Category>}
]}
