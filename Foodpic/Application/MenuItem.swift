//
//  MenuItem.swift
//  Foodpic
//
//  Created by Leif Gensert on 10/12/14.
//  Copyright (c) 2014 Olga Dalton. All rights reserved.
//

class MenuItem {
    var name: String
    var price: Int
    var image: String
    var translations: [String: String]
    
    init(name: String, price: Int, image: String, translations: [String: String]) {
        self.name = name
        self.price = price
        self.image = image
        self.translations = translations
    }
    
    convenience init(data: [String: AnyObject]) {
        self.init(
            name: data["name"] as String!,
            price: data["price"] as Int!,
            image: data["image"] as String!,
            translations: data["translations"] as [String: String]!
        )
    }
}
