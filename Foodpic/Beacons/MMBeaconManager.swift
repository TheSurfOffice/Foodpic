//
//  MMBeaconManager.swift
//  Foodpic
//
//  Created by Olga Dalton on 17/08/14.
//  Copyright (c) 2014 Olga Dalton. All rights reserved.
//

import Foundation
import UIKit

protocol MMBeaconManagerDelegate {
    func actionsEntered(manager: MMBeaconManager, actions: [MMBeaconAction])
    func actionsExited(manager: MMBeaconManager, actions: [MMBeaconAction])
    func locationInfoUpdated(manager: MMBeaconManager, beacons: MMBeaconsArray)
}

private let _SingletonASharedInstance = MMBeaconManager()

// MARK: -
// MARK: Actions constants

enum SupportedActions: String {

    case ShowMenu = "ShowMenu"
    case HideMenu = "HideMenu"
}

class MMBeaconManager : NSObject, ESTBeaconManagerDelegate {
    
    let beaconManager: ESTBeaconManager
    var beacons: MMBeaconsArray
    var activeBeacons: MMBeaconsArray
    var rangingRegions = [ESTBeaconRegion]()
    var activeActionsDictionary = [String: [MMBeaconAction]]()
    var exitActionsDictionary = [String: [MMBeaconAction]]()
    
    class var sharedInstance : MMBeaconManager {
        return _SingletonASharedInstance
    }
    
    // MARK: -
    // MARK: Initialize
    
    override init() {
    
        beaconManager = ESTBeaconManager()
        
        let filePath = NSBundle.mainBundle().pathForResource("beacons", ofType: "json")
        let jsonData = NSData(contentsOfFile: filePath!, options: .DataReadingMappedIfSafe, error: nil)
        
        let jsonObj: AnyObject? = NSJSONSerialization.JSONObjectWithData(jsonData!, options: .AllowFragments, error: nil)
        
        if let jsonDict = jsonObj as? Dictionary<String, AnyObject> {
            
            beacons = MMBeaconsArray(jsonDictionary: jsonDict)
        }
        else {
            beacons = MMBeaconsArray()
        }
        
        activeBeacons = MMBeaconsArray()
        
        super.init()
        
        beaconManager.avoidUnknownStateBeacons = true
        beaconManager.delegate = self
    }
    
    // MARK: -
    // MARK: Start monitoring
    
    func start() {
        
        if self.deviceSettingsAreCorrect() {
            for beacon in beacons.items {
                var region = beacon.region
                beaconManager.startMonitoringForRegion(region)
                activeActionsDictionary[region.identifier] = [MMBeaconAction]()
                exitActionsDictionary[region.identifier] = [MMBeaconAction]()
            }
            
            self.startRanging()
        }
        
    }
    
    // MARK: -
    // MARK: Beacons ranging
    
    func startRanging() {
        for beacon in beacons.items {
            var region = beacon.region
            beaconManager.startRangingBeaconsInRegion(region)
            rangingRegions.append(region)
        }
    }
    
    // MARK: -
    // MARK: Check device settings
    
    func deviceSettingsAreCorrect() -> Bool {
    
        var errorMessage = ""
        
        if !CLLocationManager.locationServicesEnabled()
            || (CLLocationManager.authorizationStatus() == CLAuthorizationStatus.Denied) {
                
                errorMessage += "Location services are turned off! Please turn them on!\n"
        }
        
        if !CLLocationManager.isRangingAvailable() {
            errorMessage += "Ranging not available!\n"
        }
        
        if !CLLocationManager.isMonitoringAvailableForClass(CLBeaconRegion) {
            errorMessage += "Beacons ranging not supported!\n"
        }
        
        let errorLen = countElements(errorMessage)
        
        if errorLen > 0 {
            self.showErrorMessage(errorMessage)
        }
        
        return errorLen == 0
    }
    
    // MARK: -
    // MARK: Background handling
    
    func startForegroundMode() {
        if self.deviceSettingsAreCorrect() {
            self.startRanging()
        }
    }
    
    // MARK: -
    // MARK: Error alert
    
    func showErrorMessage(message: String) {
        
        var alert = UIAlertView(title: message, message: nil, delegate: nil, cancelButtonTitle: "Ok")
        alert.show()
    }
    
    var delegate: MMBeaconManagerDelegate?
    
    // MARK: -
    // MARK: ESTBeaconManager callbacks
    
    func beaconManager(manager: ESTBeaconManager!, didEnterRegion region: ESTBeaconRegion!) {
        if UIApplication.sharedApplication().applicationState == .Active {
            beaconManager.startRangingBeaconsInRegion(region)
        }
    }
    
    func beaconManager(manager: ESTBeaconManager!, monitoringDidFailForRegion region: ESTBeaconRegion!, withError error: NSError!) {
        self.showErrorMessage(error.localizedDescription)
    }
    
    func beaconManager(manager: ESTBeaconManager!, rangingBeaconsDidFailForRegion region: ESTBeaconRegion!, withError error: NSError!) {
        self.showErrorMessage(error.localizedDescription)
    }
    
    func beaconManager(manager: ESTBeaconManager!, didDetermineState state: CLRegionState, forRegion region: ESTBeaconRegion!) {
        
//        if state == .Inside {
//            
//            if UIApplication.sharedApplication().applicationState == .Active {
//                beaconManager.startRangingBeaconsInRegion(region)
//            }
//            
//        } else if state == .Outside {
//            beaconManager.stopRangingBeaconsInRegion(region)
//        }
        
    }
    
    
    
    func beaconManager(manager: ESTBeaconManager!, didRangeBeacons estimoteBeacons: [AnyObject]!, inRegion region: ESTBeaconRegion!) {
        
        NSLog("Did range beacons %@ in region %@", estimoteBeacons, region)
        
        for estBeacon in estimoteBeacons as [ESTBeacon] {
            
            if estBeacon.distance.intValue != -1 {
                
                let beacon = beacons.getBeacon(estBeacon.proximityUUID, major: estBeacon.major.integerValue, minor: estBeacon.minor.integerValue);
                
                if let mmBeacon = beacon {
                    
                    if let found = find(activeBeacons.items, mmBeacon) {
                        activeBeacons.items.removeAtIndex(found)
                    }
                    
                    mmBeacon.estimoteBeacon = estBeacon;
                    mmBeacon.updateBeaconDistance(estBeacon.distance.doubleValue)
                    activeBeacons.items.append(mmBeacon)
                }
                
            }
        }
        
        activeBeacons.sortByAverageDistance()
        
        NSLog("Active beacons %@", activeBeacons.description)
        
        if activeBeacons.items.count > 0 {
            
            let firstBeacon = activeBeacons.items[0] as MMBeacon
            
            if firstBeacon.distanceCalculated {
                
                delegate?.locationInfoUpdated(self, beacons: activeBeacons)
                
                var activeActions = activeActionsDictionary[region.identifier]!
                var activeExitActions = exitActionsDictionary[region.identifier]!
                var currentEntryBeaconsActions = activeBeacons.getActiveActions(true)
                var currentExitBeaconsActions = activeBeacons.getActiveActions(false)
                
                var enteredActions = self.distinct(currentEntryBeaconsActions, otherArray: activeActions)
                var exitedActions = self.distinct(activeExitActions, otherArray: currentExitBeaconsActions)
                
                delegate?.actionsEntered(self, actions: enteredActions)
                delegate?.actionsExited(self, actions: exitedActions)
                
                activeActionsDictionary[region.identifier] = currentEntryBeaconsActions
                exitActionsDictionary[region.identifier] = currentExitBeaconsActions
            }
        }
    }
    
    func distinct<T:Equatable>(firstArray: [T], otherArray: [T]) -> [T] {
        
        var missingObjects = [T]()
        
        for object in firstArray {
            if !contains(otherArray, object) {
                missingObjects.append(object)
            }
        }
        return missingObjects
        
    }
}