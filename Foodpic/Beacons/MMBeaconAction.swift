//
//  MMBeaconAction.swift
//  Foodpic
//
//  Created by Olga Dalton on 17/08/14.
//  Copyright (c) 2014 Olga Dalton. All rights reserved.
//

import Foundation

class MMBeaconAction: Equatable, Printable {
    
    weak var beacon: MMBeacon?
    var meters: Float = 0.0
    var entryAction: String = ""
    var exitAction: String = ""
    var entryObject: String = ""
    var actionID: Int = 0
    
    // MARK: -
    // MARK: Initialize
    
    init(data: Dictionary<String, AnyObject>) {
        
        entryAction = data["entryAction"] as NSString
        exitAction = data["exitAction"] as NSString
        entryObject = data["entryObject"] as NSString
        
        var idNr = data["id"] as NSNumber
        actionID = idNr.integerValue
        
        var rangeNr = data["meters"] as NSNumber
        meters = rangeNr.floatValue
    }
    
    // MARK: -
    // MARK: Active check
    
    func isActive(forEntryAction: Bool) -> Bool {
        let extra: Float = forEntryAction ? 0.0 : 1.0;
        return beacon?.averageDistance <= Double(meters + extra);
    }
    
    var description: String {
        return "Entry action \(entryAction) and exit action \(exitAction) and object \(entryObject)"
    }
}

// MARK: -
// MARK: Equatable

func ==(left: MMBeaconAction, right: MMBeaconAction) -> Bool {
    let equal: Bool = (left.actionID == right.actionID
        && left.beacon == right.beacon);
    
    return equal;
}

func !=(left: MMBeaconAction, right: MMBeaconAction) -> Bool {
    return !(left == right)
}