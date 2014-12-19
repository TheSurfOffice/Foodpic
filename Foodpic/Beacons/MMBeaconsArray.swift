//
//  MMBeaconsArray.swift
//  Foodpic
//
//  Created by Olga Dalton on 17/08/14.
//  Copyright (c) 2014 Olga Dalton. All rights reserved.
//

import Foundation

class MMBeaconsArray: Printable {
    
    var items: [MMBeacon]
    
    // MARK: -
    // MARK: Initialize
    
    init(jsonDictionary: Dictionary<String, AnyObject>) {
        
        items = [MMBeacon]()
        
        if let beaconsArray = jsonDictionary["beacons"] as? NSArray {
        
            for beaconDict in beaconsArray {
                
                if let dict = beaconDict as? Dictionary<String, AnyObject> {
                    
                    var beacon = MMBeacon(data: dict)
                    items.append(beacon)
                    
                }
            }
        }
    }
    
    init() {
        items = [MMBeacon]()
    }
    
    // MARK: -
    // MARK: Find all actions in range
    
    func getActiveActions(forEntryAction: Bool) -> [MMBeaconAction] {
        
        var result = [MMBeaconAction]()
        
        for beacon in items {
            result += beacon.getActiveActions(forEntryAction)
        }
        
        return result
    }
    
    // MARK: -
    // MARK: Sort
    
    func sortByAverageDistance() {
        
        sort(&items, {(b1: MMBeacon, b2: MMBeacon) -> Bool in
            
            if !b1.distanceCalculated && b2.distanceCalculated {
                return true
            } else if b1.distanceCalculated && b2.distanceCalculated {
                return b1.averageDistance < b2.averageDistance
            } else {
                return false
            }
            
        });
    }
    
    // MARK: -
    // MARK: Beacon convinience getter
    
    func getBeacon(uuid: NSUUID, major: Int, minor: Int) -> MMBeacon? {
        
        for beacon in items {
            if beacon.uuid.isEqual(uuid)
                && beacon.major == major
                && beacon.minor == minor {
                    return beacon
            }
        }
        
        return nil
    }
    
    // MARK: -
    // MARK: Printable
    
    var description: String {
        
        var str = ""
            
        for beacon in items {
            str += beacon.description
            str += "\n"
        }
        
        return str
    }
}