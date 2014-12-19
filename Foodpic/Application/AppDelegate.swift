//
//  AppDelegate.swift
//  Foodpic
//
//  Created by Olga Dalton on 17/08/14.
//  Copyright (c) 2014 Olga Dalton. All rights reserved.
//

import UIKit
import CoreLocation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
                            
    var window: UIWindow?
    var manager: CLLocationManager = CLLocationManager()

    func application(application: UIApplication!, didFinishLaunchingWithOptions launchOptions: NSDictionary!) -> Bool {
        if(manager.respondsToSelector("requestAlwaysAuthorization")) {
            manager.requestAlwaysAuthorization()
            manager.startUpdatingLocation()
        }
        
        manager.pausesLocationUpdatesAutomatically = false
        
        if(application.respondsToSelector("registerUserNotificationSettings:")) {
            application.registerUserNotificationSettings(
                UIUserNotificationSettings(
                    forTypes: UIUserNotificationType.Alert | UIUserNotificationType.Sound,
                    categories: nil
                )
            )
        }
        
        MMBeaconManager.sharedInstance.start()
        
        return true
    }

    func applicationWillResignActive(application: UIApplication!) {}

    func applicationDidEnterBackground(application: UIApplication!) {
        MMBeaconManager.sharedInstance.startForegroundMode()
    }

    func applicationWillEnterForeground(application: UIApplication!) {
        MMBeaconManager.sharedInstance.startForegroundMode()
    }

    func applicationDidBecomeActive(application: UIApplication!) {}

    func applicationWillTerminate(application: UIApplication!) {}

}

