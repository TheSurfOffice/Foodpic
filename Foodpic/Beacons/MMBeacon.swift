//
//  MMBeacon.swift
//  Foodpic
//
//  Created by Olga Dalton on 17/08/14.
//  Copyright (c) 2014 Olga Dalton. All rights reserved.
//

import Foundation

class MMBeacon: Equatable, Printable {
    
    var averageDistance = -1.0
    var rawDistance = -1.0
    
    let major = 0
    let minor = 0
    let uuid = NSUUID()
    
    weak var estimoteBeacon: ESTBeacon?
    
    var beaconActions: [MMBeaconAction]
    
    var distanceCalculated: Bool {
        return averageDistance != -1
    }
    
    let kAverageDistancesCount = 3
    let kSignificantDistanceDiff = 0.5
    
    var lastDistances: [Double]
    
    // MARK: -
    // MARK: Initialize
    
    init(data: Dictionary<String, AnyObject>) {
        
        //major = data["major"] as Int
        
        var majorNr = data["major"] as NSNumber
        major = majorNr.integerValue
        
        var minorNr = data["minor"] as NSNumber
        minor = minorNr.integerValue
        
        beaconActions = [MMBeaconAction]()
        lastDistances = [Double]()
        
        var uuidString = data["UUID"] as NSString
        uuid = NSUUID(UUIDString: uuidString)!
        
        var actionsArray = data["actions"] as NSArray
        
        for action:AnyObject in actionsArray {
            
            if let dictAction = action as? Dictionary<String, AnyObject> {
                var beaconAction = MMBeaconAction(data: dictAction)
                beaconAction.beacon = self
                beaconActions.append(beaconAction)
            }
                
        }
    }
    
    // MARK: -
    // MARK: Distance update
    
    func updateBeaconDistance(newDistance: Double) {
        rawDistance = newDistance
        
        lastDistances.append(newDistance)
        
        if lastDistances.count > kAverageDistancesCount {
            lastDistances.removeAtIndex(0)
        }
        
        let newAverageValue = (lastDistances as AnyObject).valueForKeyPath("@avg.self") as Double
        
        if averageDistance == -1.0
            || abs(averageDistance - newAverageValue) > kSignificantDistanceDiff {
                averageDistance = newAverageValue
        }
    }
    
    // MARK: -
    // MARK: Region convenience getter
    
    var region: ESTBeaconRegion {
        
        let identifier = "region" + uuid.UUIDString;
        
        var region: ESTBeaconRegion = ESTBeaconRegion(proximityUUID: uuid, major: CLBeaconMajorValue(self.major), minor: CLBeaconMinorValue(self.minor), identifier:  identifier)
        
        region.notifyOnEntry = true
        region.notifyOnExit = true
        region.notifyEntryStateOnDisplay = false
        
        return region
    }
    
    // MARK: -
    // MARK: Printable
    
    var description: String {
        var str = NSString(format: "Beacon (%d-%d) - distance: %.2f m", major, minor, averageDistance)
        return str
    }
    
    // MARK: -
    // MARK: Find all beacon
    
    func getActiveActions(forEntryAction: Bool) -> [MMBeaconAction] {
        
        var result = [MMBeaconAction]()
        
        for action in beaconActions {
            if action.isActive(forEntryAction) {
                result.append(action)
            }
        }
        
        return result
    }
    
}

// MARK: -
// MARK: Equatable

func ==(first: MMBeacon, second: MMBeacon) -> Bool {
    let equal = first.uuid.isEqual(second.uuid)
                && first.major == second.major
        && first.minor == second.minor
    
    return equal
}