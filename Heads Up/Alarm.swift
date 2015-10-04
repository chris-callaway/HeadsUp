//
//  Alarm.swift
//  Heads Up
//
//  Created by Chris Callaway on 4/11/15.
//  Copyright (c) 2015 Transcendence Productions. All rights reserved.
//

import UIKit

var alarmMgr: Alarm = Alarm()

struct alarm{
    var hour = 0;
    var min = 0;
    var time_setting = "";
    var time = [];
    var alarm_scheduler = [];
    var traffic_scheduler = [];
    var total_delay_time = [];
    var total_time_seconds = [];
    var timeCalculated = [];
    var avoidTolls = [];
    
    //Fields
    var name = [];
    var destination = [];
    var timeOfArrival = [];
    var bufferTime = [];
}

class Alarm: NSCoder {
    
    var time = [String?]()
    var name = [String]()
    var alarm_scheduler = [NSTimer]()
    var traffic_scheduler = [NSTimer]()
    var hour = 0 as Int;
    var min = 0 as Int;
    var time_setting = " " as String;
    var total_delay_time = [Int]()
    var total_time_seconds = [Int]()
    var avoidTolls = [String]()
    
    //Fields
    var destination = [String]()
    var timeOfArrival = [NSDate]()
    var bufferTime = [Int]()
//    var timeCalculated = [NSDate?]()

    var timeCalculated = [NSDate]()

    required init(coder aDecoder: NSCoder) {
        var alarm = aDecoder.decodeObjectForKey("alarmMgr") as! Alarm
        println("init alarm \(alarm)");
    }
    
    override init() {
        //name = [""]
        super.init()
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(alarmMgr, forKey: "alarmMgr")
    }
    
    required init(name:[String?]) {
        //self.name = name
        super.init()
    }


    func saveAlarms(alarms: Alarm) {
        let defaults = NSUserDefaults.standardUserDefaults()
        
        // save names
        let names = NSKeyedArchiver.archivedDataWithRootObject(alarmMgr.name)
        println("names saved as \(alarmMgr.name)");
        defaults.setObject(names, forKey: "name")
        
//        // save alarm scheduler
//        let alarmScheduler = NSKeyedArchiver.archivedDataWithRootObject(alarmMgr.alarm_scheduler)
//        println("alarm scheduler saved as \(alarmMgr.alarm_scheduler)");
//        defaults.setObject(alarmScheduler, forKey: "alarm_scheduler")
//        
//        // save traffic scheduler
//        let trafficScheduler = NSKeyedArchiver.archivedDataWithRootObject(alarmMgr.traffic_scheduler)
//        println("traffic scheduler saved as \(alarmMgr.traffic_scheduler)");
//        defaults.setObject(trafficScheduler, forKey: "traffic_scheduler")
        
        // save total delay time
        let totalDelayTime = NSKeyedArchiver.archivedDataWithRootObject(alarmMgr.total_delay_time)
        println("total_delay_time saved as \(alarmMgr.total_delay_time)");
        defaults.setObject(totalDelayTime, forKey: "total_delay_time")
        
        // save total time seconds
        let totalTimeSeconds = NSKeyedArchiver.archivedDataWithRootObject(alarmMgr.total_time_seconds)
        println("total_time_seconds saved as \(alarmMgr.total_time_seconds)");
        defaults.setObject(totalTimeSeconds, forKey: "total_time_seconds")
        
        // save avoid tolls
        let avoidTolls = NSKeyedArchiver.archivedDataWithRootObject(alarmMgr.avoidTolls)
        println("avoidTolls saved as \(alarmMgr.avoidTolls)");
        defaults.setObject(avoidTolls, forKey: "avoidTolls")
        
        // save destination
        let destination = NSKeyedArchiver.archivedDataWithRootObject(alarmMgr.destination)
        println("destination saved as \(alarmMgr.destination)");
        defaults.setObject(destination, forKey: "destination")
        
        // save time of arrival
        let timeOfArrival = NSKeyedArchiver.archivedDataWithRootObject(alarmMgr.timeOfArrival)
        println("timeOfArrival saved as \(alarmMgr.timeOfArrival)");
        defaults.setObject(timeOfArrival, forKey: "timeOfArrival")
        
        // save buffer time
        let bufferTime = NSKeyedArchiver.archivedDataWithRootObject(alarmMgr.bufferTime)
        println("bufferTime saved as \(alarmMgr.bufferTime)");
        defaults.setObject(bufferTime, forKey: "bufferTime")
        
        // save time calculated
        let timeCalculated = NSKeyedArchiver.archivedDataWithRootObject(alarmMgr.timeCalculated)
        println("timeCalculated saved as \(alarmMgr.timeCalculated)");
        defaults.setObject(timeCalculated, forKey: "timeCalculated")
        
        // final sync
        defaults.synchronize()
    }
    
    func retrievedName() -> [String] {
        if let unarchivedObject = NSUserDefaults.standardUserDefaults().objectForKey("name") as? NSData {
            return NSKeyedUnarchiver.unarchiveObjectWithData(unarchivedObject) as! [String]
        }
        return [String()]
    }
    
    func retrievedAlarmScheduler() -> [NSTimer] {
        if let unarchivedObject = NSUserDefaults.standardUserDefaults().objectForKey("alarm_scheduler") as? NSData {
            return NSKeyedUnarchiver.unarchiveObjectWithData(unarchivedObject) as! [NSTimer]
        }
        return [NSTimer()]
    }
    
    func retrievedTrafficScheduler() -> [NSTimer] {
        if let unarchivedObject = NSUserDefaults.standardUserDefaults().objectForKey("traffic_scheduler") as? NSData {
            return NSKeyedUnarchiver.unarchiveObjectWithData(unarchivedObject) as! [NSTimer]
        }
        return [NSTimer()]
    }
    
    func retrievedTotalDelayTime() -> [Int] {
        if let unarchivedObject = NSUserDefaults.standardUserDefaults().objectForKey("total_delay_time") as? NSData {
            return NSKeyedUnarchiver.unarchiveObjectWithData(unarchivedObject) as! [Int]
        }
        return [Int()]
    }
    
    func retrievedTotalTimeSeconds() -> [Int] {
        if let unarchivedObject = NSUserDefaults.standardUserDefaults().objectForKey("total_time_seconds") as? NSData {
            return NSKeyedUnarchiver.unarchiveObjectWithData(unarchivedObject) as! [Int]
        }
        return [Int()]
    }
    
    func retrievedAvoidTolls() -> [String] {
        if let unarchivedObject = NSUserDefaults.standardUserDefaults().objectForKey("avoidTolls") as? NSData {
            return NSKeyedUnarchiver.unarchiveObjectWithData(unarchivedObject) as! [String]
        }
        return [String()]
    }
    
    func retrievedDestination() -> [String] {
        if let unarchivedObject = NSUserDefaults.standardUserDefaults().objectForKey("destination") as? NSData {
            return NSKeyedUnarchiver.unarchiveObjectWithData(unarchivedObject) as! [String]
        }
        return [String()]
    }
    
    func retrievedTimeofArrival() -> [NSDate] {
        if let unarchivedObject = NSUserDefaults.standardUserDefaults().objectForKey("timeOfArrival") as? NSData {
            return NSKeyedUnarchiver.unarchiveObjectWithData(unarchivedObject) as! [NSDate]
        }
        return [NSDate()]
    }
    
    func retrievedBufferTime() -> [Int] {
        if let unarchivedObject = NSUserDefaults.standardUserDefaults().objectForKey("bufferTime") as? NSData {
            return NSKeyedUnarchiver.unarchiveObjectWithData(unarchivedObject) as! [Int]
        }
        return [Int()]
    }
    
    func retrievedTimeCalculated() -> [NSDate] {
        if let unarchivedObject = NSUserDefaults.standardUserDefaults().objectForKey("timeCalculated") as? NSData {
            return NSKeyedUnarchiver.unarchiveObjectWithData(unarchivedObject) as! [NSDate]
        }
        return [NSDate()]
    }
    
    func retrievedObject() -> [AnyObject] {
        if let unarchivedObject = NSUserDefaults.standardUserDefaults().objectForKey("object") as? NSData {
            return (NSKeyedUnarchiver.unarchiveObjectWithData(unarchivedObject)! as? [AnyObject])!
        }
        return [AnyObject]()
    }
    
}

