//
//  GeoLocation.swift
//  Heads Up
//
//  Created by Chris Callaway on 4/11/15.
//  Copyright (c) 2015 Transcendence Productions. All rights reserved.
//

import UIKit

var locationMgr: GeoLocation = GeoLocation()

struct location{
    var user_lat = 0.0;
    var user_lng = 0.0;
    var dest_lat = 0.0;
    var dest_lng = 0.0;
}

class GeoLocation: NSObject {
    var user_lat = 0.0 as Double;
    var user_lng = 0.0 as Double;
    var dest_lat = 0.0 as Float;
    var dest_lng = 0.0 as Float;
}
