//
//  LogItem.swift
//  Heads Up
//
//  Created by Chris on 9/25/15.
//  Copyright (c) 2015 Gazellia. All rights reserved.
//

import Foundation
import CoreData

//
@objc(LogItem)

class LogItem: NSManagedObject {

    @NSManaged var time: Array<String>
    @NSManaged var name: String
    @NSManaged var alarm_scheduler: Array<NSTimer>
    @NSManaged var traffic_scheduler: Array<NSTimer>
    @NSManaged var total_delay_time: Array<Int>
    @NSManaged var total_time_seconds: Array<Int>
    @NSManaged var avoidTolls: Array<String>
    @NSManaged var destination: Array<String>
    @NSManaged var timeOfArrival: Array<NSDate>
    @NSManaged var bufferTime: Array<Int>
    @NSManaged var timeCalculated: Array<NSDate>
    
    class func createInManagedObjectContext(moc: NSManagedObjectContext, alarm: Alarm, indexPath: Int) -> [LogItem] {
        var objects = [LogItem]();
        for (var i = 0; i < count(alarmMgr.name); i++){
            let newItem = NSEntityDescription.insertNewObjectForEntityForName("LogItem", inManagedObjectContext: moc) as! LogItem
            newItem.name = (alarm.name[i]! as? String)!
            println("name is \(newItem.name)");
            objects.append(newItem);
        }
//        newItem.name = (alarm.name[indexPath]! as? String)!
        return objects
    }
}
