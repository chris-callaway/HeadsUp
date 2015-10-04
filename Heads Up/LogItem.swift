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
    @NSManaged var alarm_scheduler: NSTimer
    @NSManaged var traffic_scheduler: NSTimer
    @NSManaged var total_delay_time: Int
    @NSManaged var total_time_seconds: Int
    @NSManaged var avoidTolls: String
    @NSManaged var destination: String
    @NSManaged var timeOfArrival: NSDate
    @NSManaged var bufferTime: Int
    @NSManaged var timeCalculated: NSDate
    
    class func createInManagedObjectContext(moc: NSManagedObjectContext, alarm: Alarm, indexPath: Int) -> [LogItem] {
        var objects = [LogItem]();
        for (var i = 0; i < count(alarmMgr.name); i++){
            let newItem = NSEntityDescription.insertNewObjectForEntityForName("LogItem", inManagedObjectContext: moc) as! LogItem
            
            // set name
            newItem.setValue(alarm.name[i], forKey: "name");
            println("db - name is \(newItem.name)");
            
            // set alarm scheduler
//            newItem.setValue(alarm.alarm_scheduler[i], forKey: "alarm_scheduler");
//            println("db - alarm scheduler is \(newItem.alarm_scheduler)");
//            
//            // set traffic scheduler
//            newItem.setValue(alarm.traffic_scheduler[i], forKey: "traffic_scheduler");
//            println("db - traffic scheduler is \(newItem.traffic_scheduler)");
            
            // set total time seconds
//            newItem.setValue(alarm.total_delay_time[i], forKey: "total_delay_time");
//            println("db - total time seconds is \(newItem.total_delay_time)");
            
            // set avoid tolls
            newItem.setValue(alarm.avoidTolls[i], forKey: "avoidTolls");
            println("db - avoid tolls is \(newItem.avoidTolls)");
            
            // set destination
//            newItem.setValue(alarm.destination[i], forKey: "destination");
//            println("db - destination is \(newItem.destination)");
            
            // set time of arrival
            newItem.setValue(alarm.timeOfArrival[i], forKey: "timeOfArrival");
            println("db - time of arrival is \(newItem.timeOfArrival)");
            
            // set buffer time
            newItem.setValue(alarm.bufferTime[i], forKey: "bufferTime");
            println("db - buffer time is \(newItem.bufferTime)");
            
            // set time calculated
            newItem.setValue(alarm.timeCalculated[i], forKey: "timeCalculated");
            println("db - time calculated is \(newItem.timeCalculated)");

            
            objects.append(newItem);
        }
//        newItem.name = (alarm.name[indexPath]! as? String)!
        return objects
    }
}
