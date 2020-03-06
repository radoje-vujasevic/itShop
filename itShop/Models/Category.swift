//
//  Category.swift
//  itShop
//
//  Created by Raša on 11/02/2020.
//  Copyright © 2020 Rasa. All rights reserved.
//

import Foundation
import UIKit

struct CategoryCodable: Codable {
    let Id: Int
    let Name: String
    let Description: String
    let ChildsExist: Bool
    let ImageUrl: URL
    let ChildCategories: Array<CategoryCodable>
}

class Category{
    let id: Int
    let name: String
    let description: String
    let childsExist:Bool
    let imageURL: URL
    let childCategories: Array<CategoryCodable>
    var image: UIImage?
    
    init (category: CategoryCodable, image: UIImage){
        self.id = category.Id
        self.name = category.Name
        self.description = category.Description
        self.childsExist = category.ChildsExist
        self.imageURL = category.ImageUrl
        self.childCategories = category.ChildCategories
        self.image = image
    }
}
