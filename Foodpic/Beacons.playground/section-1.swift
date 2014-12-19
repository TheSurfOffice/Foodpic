// Playground - noun: a place where people can play

import Foundation

let urlPath = "https://dl.dropboxusercontent.com/u/6253/mumbai.json"
let url = NSURL(string: urlPath)

let jsonData = NSData(contentsOfURL: url!, options: .DataReadingMappedIfSafe, error: nil)

let jsonObj: AnyObject? = NSJSONSerialization.JSONObjectWithData(jsonData!, options: .AllowFragments, error: nil)

if let jsonDict = jsonObj as? [String: AnyObject] {
    let name: String = jsonDict["name"] as String!
    let items:[AnyObject] = jsonDict["items"] as [AnyObject]!
    
    for item in items {
        if let itemDict = item as? [String: AnyObject] {
            let itemName = itemDict["name"] as String!
            let price = itemDict["price"] as Int!
            let translations:[String: String] = itemDict["translations"] as [String: String]!
        }
    }
}



//let name = jsonDict["name"] as? String
//
//let myArray = jsonDict["items"] as? NSArray

