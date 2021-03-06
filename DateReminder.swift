//
//  DateReminder.swift
//  Nothing
//
//  Created by Tomasz Szulc on 03/03/15.
//  Copyright (c) 2015 Tomasz Szulc. All rights reserved.
//

import Foundation
import CoreData

@objc(DateReminder)
class DateReminder: Reminder {

    @NSManaged var fireDate: NSDate!
    @NSManaged var repeatIntervalNumber: NSNumber!
    
    var repeatInterval: NSCalendarUnit {
        set { self.repeatIntervalNumber = NSNumber(unsignedLong: newValue.rawValue) }
        get { return NSCalendarUnit(rawValue: self.repeatIntervalNumber.unsignedLongValue) }
    }
}
