//
//  ViewController.swift
//  Foodpic
//
//  Created by Olga Dalton on 17/08/14.
//  Copyright (c) 2014 Olga Dalton. All rights reserved.
//

import UIKit

class ViewController: UIViewController, MMBeaconManagerDelegate {

    // MARK: -
    // MARK: View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        MMBeaconManager.sharedInstance.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }

    // MARK: -
    // MARK: MMBeaconManagerDelegate

    func actionsEntered(manager: MMBeaconManager, actions: [MMBeaconAction]) {
        enteredActions(actions)
    }

    func actionsExited(manager: MMBeaconManager, actions: [MMBeaconAction]) {
        exitedActions(actions)
    }

    func locationInfoUpdated(manager: MMBeaconManager, beacons: MMBeaconsArray) { }

    // MARK: -
    // MARK: Actions Handling

    func enteredActions(actions: [MMBeaconAction]) {

        for action in actions {
            performAction(action.entryAction, actionObject: action)
        }
    }

    func exitedActions(actions: [MMBeaconAction]) {

        for action in actions {
            performAction(action.exitAction, actionObject: action)
        }
    }

    func performAction(actionName: String, actionObject: MMBeaconAction) {
        var action = SupportedActions(rawValue: actionName)

        if let foundAction = action {
            switch foundAction {
                case .ShowMenu:
                    showMenu(actionObject.entryObject)
                default:
                    hideModalController()
            }
        }

    }

    // MARK: -
    // MARK: Modal Controllers

    func hideModalController() {
        if self.presentedViewController != nil {
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }

    func showMenu(restaurant: String) {
        notification(restaurant)
        
        if self.presentedViewController == nil {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewControllerWithIdentifier("MenuItemSwitcher") as MenuItemSwitcherViewController
            vc.restaurant = restaurant
            var navController = UINavigationController(rootViewController: vc)
            self.presentViewController(navController, animated: true, completion: nil)
        }
    }
    
    func notification(restaurant: String) {
        var localNotification:UILocalNotification = UILocalNotification()
        localNotification.alertAction = restaurant
        localNotification.alertBody = "See \(restaurant)'s menu with pictures"
        UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
    }
}

