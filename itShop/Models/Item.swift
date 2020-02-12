//
//  Item.swift
//  itShop
//
//  Created by Raša on 12/02/2020.
//  Copyright © 2020 Rasa. All rights reserved.
//

import Foundation

struct Item: Codable {
    let Id: Int
    let Name: String
    let MainImage: URL
    let Description: String
    let Price: Int
    let ImageUrls: Array<URL>?
}
