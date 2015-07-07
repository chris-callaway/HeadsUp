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
    
    //Fields
    var name = [];
    var destination = [];
    var timeOfArrival = [];
    var bufferTime = [];
}

class Alarm: NSObject {
    var time = [String?]()
    var name = [String?]()
    var alarm_scheduler = [NSTimer?]()
    var traffic_scheduler = [NSTimer?]()
    var hour = 0 as Int;
    var min = 0 as Int;
    var time_setting = " " as String;
    var total_delay_time = [Int?]()
    var total_time_seconds = [Int?]()
    
    //Fields
    var destination = [String?]()
    var timeOfArrival = [NSDate?]()
    var bufferTime = [Int?]()
//    var timeCalculated = [NSDate?]()

    var timeCalculated = [NSDate?]()
}

