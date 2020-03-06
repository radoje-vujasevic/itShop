//
//  Item.swift
//  itShop
//
//  Created by Raša on 12/02/2020.
//  Copyright © 2020 Rasa. All rights reserved.
//

import Foundation
import UIKit

struct ItemCodable: Codable {
    let Id: Int
    let Name: String
    let Description: String
    let Price: Int
    let MainImage: URL
    let ImageUrls: Array<URL>?
}

class Item{
    let id: Int
    let name: String
    let description: String
    let price: Int
    let mainImageURL: URL
    let mainImage: UIImage?
    let imagesURLs:Array<URL>?
    let images: Array<UIImage>?
    
    init(item: ItemCodable, image: UIImage){
        self.id = item.Id
        self.name = item.Name
        self.description = item.Description
        self.price = item.Price
        self.mainImageURL = item.MainImage
        self.mainImage = image
        self.imagesURLs = item.ImageUrls
        self.images = nil
    }
    
    init(item: ItemCodable, images: Array<UIImage>){
        self.id = item.Id
        self.name = item.Name
        self.description = item.Description
        self.price = item.Price
        self.mainImageURL = item.MainImage
        self.mainImage = nil
        self.imagesURLs = item.ImageUrls
        self.images = images
    }
}


