//
//  MasterViewController.swift
//  Heads Up
//
//  Created by Chris Callaway on 4/11/15.
//  Copyright (c) 2015 Transcendence Productions. All rights reserved.
//

import UIKit
import CoreLocation
import Foundation

class MasterViewController: UITableViewController, CLLocationManagerDelegate {

    var objects = [AnyObject]()
    
    var latitude: Float = Float();
    var longitude: Float = Float();
    let locationManager = CLLocationManager()


    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        self.navigationItem.leftBarButtonItem = self.editButtonItem()

        let addButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "insertNewObject:")
        self.navigationItem.rightBarButtonItem = addButton
        
        //Find user location
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        CLGeocoder().reverseGeocodeLocation(manager.location, completionHandler: {(placemarks, error)->Void in
            
            if (error != nil) {
                println("Reverse geocoder failed with error" + error.localizedDescription)
                return
            }
            
            var locValue:CLLocationCoordinate2D = manager.location.coordinate
            locationMgr.user_lat = locValue.latitude
            locationMgr.user_lng = locValue.longitude
            
        })
    }
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        println("Error while updating location " + error.localizedDescription)
    }
    
    func HTTPsendRequest(request: NSMutableURLRequest,
        callback: (String, String?) -> Void) {
            let task = NSURLSession.sharedSession().dataTaskWithRequest(
                request,
                completionHandler: {
                    data, response, error in
                    if error != nil {
                        callback("", error.localizedDescription)
                    } else {
                        callback(
                            NSString(data: data, encoding: NSUTF8StringEncoding)! as String,
                            nil
                        )
                    }
            })
            
            task.resume()
    }
    
    // you have to add a completion block to your asyncronous request
    func httpPost(link:String,completion: ((data: NSData?) -> Void)) {
        if let requestUrl = NSURL(string: link){
            let request = NSMutableURLRequest(URL: requestUrl)
            request.HTTPMethod = "POST"
            let postString = "user=test&pass=test3"
            request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
            NSURLSession.sharedSession().dataTaskWithRequest(request) { (data, response, error) in
                completion(data: NSData(data: data))
                if let error = error {
                    println("error=\(error)")
                    return
                }
                
                }.resume()
        }
    }
    
    func httpGet(url: String, callback: (String, String?) -> Void) {
        var request = NSMutableURLRequest(URL: NSURL(string: url)!)
        HTTPsendRequest(request, callback: callback)
    }
    
    func JSONParseDict(jsonString:String) -> Dictionary<String, AnyObject> {
        var e: NSError?
        let data: NSData = jsonString.dataUsingEncoding(NSUTF8StringEncoding)!
        var jsonObj = NSJSONSerialization.JSONObjectWithData(
            data,
            options: NSJSONReadingOptions(0),
            error: &e) as! Dictionary<String, AnyObject>
        if (e != nil) {
            return Dictionary<String, AnyObject>()
        } else {
            return jsonObj
        }
    }
    
    func HTTPGetJSON(
        url: String,
        callback: (Dictionary<String, AnyObject>, String?) -> Void) {
            var request = NSMutableURLRequest(URL: NSURL(string: url)!)
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            HTTPsendRequest(request) {
                (data: String, error: String?) -> Void in
                if (error != nil){
                    callback(Dictionary<String, AnyObject>(), error)
                } else {
                    var jsonObj = self.JSONParseDict(data)
                    callback(jsonObj, nil)
                }
            }
    }

//    func checkAlarm() {
//        //Get current time
//        let date = NSDate()
//        let calendar = NSCalendar.currentCalendar()
//        let components = calendar.components(.CalendarUnitHour | .CalendarUnitMinute, fromDate: date)
//        let hour = components.hour
//        let minutes = components.minute
//        
//        var dateFormatter = NSDateFormatter()
//        
//        dateFormatter.dateStyle = NSDateFormatterStyle.FullStyle
//        dateFormatter.timeStyle = NSDateFormatterStyle.FullStyle
//        dateFormatter.dateFormat = "yyyy-MM-dd 'at' h:mm a" // superset of OP's format
//        
//        var strDate = dateFormatter.stringFromDate(date)
//        
//        println("current date is \(strDate) current alarm is \(alarmMgr.time[0]");
//        if (strDate == alarmMgr.time[0]){
//            println("match");
//            timer.invalidate()
//            
//            //Notification
//            var localNotification:UILocalNotification = UILocalNotification()
//            //localNotification.alertAction = "Alarm went off"
//            localNotification.hasAction = true;
//            localNotification.alertBody = "Alarm went off"
//            localNotification.fireDate = NSDate(timeIntervalSinceNow: 5)
//            localNotification.soundName = UILocalNotificationDefaultSoundName
//            localNotification.category = "invite"
//            UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
//        }
//    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func insertNewObject(sender: AnyObject) {
        objects.insert("New Alarm", atIndex: 0)
        let indexPath = NSIndexPath(forRow: 0, inSection: 0)
        //objects.insert(indexPath, atIndex: 0)
        self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        
        alarmMgr.time.append(nil);
        alarmMgr.alarm_scheduler.append(NSTimer());
        alarmMgr.traffic_scheduler.append(NSTimer());
        alarmMgr.destination.append(nil);
        alarmMgr.timeOfArrival.append(NSDate());
        alarmMgr.timeCalculated.append(NSDate());
        alarmMgr.bufferTime.append(nil);
        alarmMgr.total_delay_time.append(nil);
        alarmMgr.total_time_seconds.append(nil);

    }

    // MARK: - Segues

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow() {
                let object = objects[indexPath.row] as! String
                (segue.destinationViewController as! DetailViewController).detailItem = indexPath.row
            }
        }
    }

    // MARK: - Table View

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objects.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! UITableViewCell

        let object = objects[indexPath.row] as! String
        cell.textLabel!.text = object
        return cell
    }

    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            objects.removeAtIndex(indexPath.row)

            if ((alarmMgr.time[indexPath.row]) != nil){
                alarmMgr.time.removeAtIndex(indexPath.row)
            }
            
            if ((alarmMgr.alarm_scheduler[indexPath.row]) != nil){
                alarmMgr.alarm_scheduler[indexPath.row]!.invalidate()
                alarmMgr.alarm_scheduler.removeAtIndex(indexPath.row)
            }
           
            if ((alarmMgr.traffic_scheduler[indexPath.row]) != nil){
                alarmMgr.traffic_scheduler[indexPath.row]!.invalidate()
            }
            
            if ((alarmMgr.traffic_scheduler[indexPath.row]) != nil){
                alarmMgr.traffic_scheduler.removeAtIndex(indexPath.row)
            }
            
            if ((alarmMgr.destination[indexPath.row]) != nil){
                alarmMgr.destination.removeAtIndex(indexPath.row)
            }

            if ((alarmMgr.timeOfArrival[indexPath.row]) != nil){
                alarmMgr.timeOfArrival.removeAtIndex(indexPath.row)
            }
            
            
            if ((alarmMgr.timeCalculated[indexPath.row]) != nil){
                alarmMgr.timeCalculated.removeAtIndex(indexPath.row)
            }
            
            if ((alarmMgr.bufferTime[indexPath.row]) != nil){
                alarmMgr.bufferTime.removeAtIndex(indexPath.row)
            }
        
            println("Removed alarm");
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }


}

