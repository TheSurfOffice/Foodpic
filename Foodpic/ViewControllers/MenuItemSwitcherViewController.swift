//
//  MenuItemSwitcherViewController.swift
//  Foodpic
//
//  Created by Leif Gensert on 10/12/14.
//  Copyright (c) 2014 Olga Dalton. All rights reserved.
//

import UiKit

class MenuItemSwitcherViewController : UIViewController {

    var restaurant = "mumbai"
    var menuItems = [MenuItem]()
    var currentItem = 0

    @IBOutlet weak var mainImage: UIImageView!
    @IBOutlet weak var translation: UILabel!
    @IBOutlet weak var originalName: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        loadMenuItems()
        addResources(currentItem)
        addSwiping()
    }

    func loadMenuItems() {
        menuItems = [MenuItem]()

        let filePath = NSBundle.mainBundle().pathForResource(restaurant, ofType: "json")
        let jsonData = NSData(contentsOfFile: filePath!, options: .DataReadingMappedIfSafe, error: nil)

        let jsonObj: AnyObject? = NSJSONSerialization.JSONObjectWithData(jsonData!, options: .AllowFragments, error: nil)

        if let jsonDict = jsonObj as? [String: AnyObject] {
                if let itemsArray = jsonDict["items"] as? NSArray {
                    for item in itemsArray {
                        if let dict = item as? [String: AnyObject] {
                            self.menuItems.append(MenuItem(data: dict))
                    }
                }
            }
        }
    }

    func rightSwiped() {
        if currentItem > 0 {
            currentItem -= 1
            addResources(currentItem)
        }
    }

    func leftSwiped(){
        if currentItem < menuItems.count - 1 {
            currentItem += 1
            addResources(currentItem)
        }
    }

    func addResources(currentItem: Int) {
        let initialItem = menuItems[currentItem]
        let imageFilePath = NSBundle.mainBundle().pathForResource("\(restaurant)_\(initialItem.image)", ofType: "")
        let imageContent = NSData(contentsOfFile: imageFilePath!)!
        mainImage.image = UIImage(data: imageContent)
        translation.text = initialItem.translations["en"]
        originalName.text = initialItem.name
    }

    func addSwiping() {
        let swipeRight = UISwipeGestureRecognizer(target: self, action: Selector("rightSwiped"))
        swipeRight.direction = UISwipeGestureRecognizerDirection.Right
        self.view.addGestureRecognizer(swipeRight)

        let swipeLeft = UISwipeGestureRecognizer(target: self, action: Selector("leftSwiped"))
        swipeLeft.direction = UISwipeGestureRecognizerDirection.Left
        self.view.addGestureRecognizer(swipeLeft)
    }

}
