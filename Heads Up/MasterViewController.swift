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
import AVFoundation

class CustomTableViewCell: UITableViewCell {

    @IBOutlet weak var alarmSwitch: UISwitch!
    
    @IBAction func alarmSwitchChanged(sender: AnyObject) {
        
        if (alarmSwitch.on){
            var text = alarmMgr.time[0];
            println("ON");
        } else{
            println("OFF");
        }
    }
    
//    alarmSwitch.setOn(false, animated:true)
    
}

class MasterViewController: UITableViewController, CLLocationManagerDelegate {
    
    var objects = [AnyObject]()
    
    var latitude: Float = Float();
    var longitude: Float = Float();
    let locationManager = CLLocationManager()

    var audioPlayer = AVAudioPlayer()
    //@IBOutlet weak var alarmSwitch: UISwitch!

    override func awakeFromNib() {
        super.awakeFromNib()
        tableView.delegate = self
        tableView.dataSource = self
        //let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! UITableViewCell
        //let name = alarmMgr.time[indexPath.row]
//        if (name != ""){
//            if let nameLabel = cell.viewWithTag(100) as? UILabel {
//                nameLabel.text = alarmMgr.name[indexPath.row];
//            }
//        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        
        if (objects.count > 1){
            self.navigationItem.leftBarButtonItem = self.editButtonItem()
            self.navigationItem.leftBarButtonItem?.tintColor = UIColor.whiteColor()
        }

        let addButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "insertNewObject:")
        addButton.tintColor = UIColor.whiteColor()
        self.navigationItem.rightBarButtonItem = addButton
        
        //Find user location
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        
        //set top bar color
        navigationController!.navigationBar.barTintColor = UIColor(red:  251/255.0, green: 138/255.0, blue: 16/255.0, alpha: 100.0/100.0)
        //set top bar text color
        navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        self.navigationController!.navigationBar.tintColor = UIColor.whiteColor();
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        println("appeared");
        self.tableView.reloadData()
        if (objects.count > 1){
            self.navigationItem.leftBarButtonItem = self.editButtonItem()
            self.navigationItem.leftBarButtonItem?.tintColor = UIColor.whiteColor()
        }
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
        objects.insert("", atIndex: 0)
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
        alarmMgr.name.append(nil);
        
        if (objects.count >= 1){
            self.navigationItem.leftBarButtonItem = self.editButtonItem()
            self.navigationItem.leftBarButtonItem?.tintColor = UIColor.whiteColor()
            removeEmptyTableText();
        } else{
            addEmptyTableText()
        }

    }

    // MARK: - Segues

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail" {
            println("show detail");
            if let indexPath = self.tableView.indexPathForSelectedRow() {
                let object = objects[indexPath.row] as! String
                (segue.destinationViewController as! DetailViewController).detailItem = indexPath.row
            }
        }
    }
    
    func addEmptyTableText(){
        let textView = UITextView(frame: CGRectMake(35.0, 30.0, 300.0, 30.0))
        textView.textAlignment = NSTextAlignment.Center
        textView.textColor = UIColor.grayColor()
        textView.text = "There is no alarm";
        self.view.addSubview(textView)
    }
    
    func removeEmptyTableText(){
        for textView in view.subviews {
            if textView is UITextView {
                textView.removeFromSuperview()
            }
        }
    }

    // MARK: - Table View

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (objects.count == 0){
            println("empty table");
            addEmptyTableText();
        }
        return objects.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! UITableViewCell

        let object = objects[indexPath.row] as! String
        cell.textLabel!.text = object
        //if (alarmMgr.timeOfArrival[indexPath.row] != nil){
        //if let route = data["route"]! as? NSDictionary {

        if let myArray: Array = alarmMgr.timeOfArrival as? Array {
            if myArray.count > 0 { // <- HERE
                println("array is not empty");
                if let element: NSDate = alarmMgr.timeOfArrival[indexPath.row] as? NSDate! {
                    var dateFormatter = NSDateFormatter();
                    dateFormatter.dateFormat = "hh:mm"
                    var dateString = dateFormatter.stringFromDate(alarmMgr.timeOfArrival[indexPath.row]!);
                    
                    if let label = cell.viewWithTag(100) as? UILabel {
                        label.text = dateString
                    }
                    
                    var dateFormatter2 = NSDateFormatter();
                    dateFormatter2.dateFormat = "a"
                    var dateString2 = dateFormatter2.stringFromDate(alarmMgr.timeOfArrival[indexPath.row]!);
                    
                    if let label2 = cell.viewWithTag(101) as? UILabel {
                        label2.text = dateString2
                    }
                    
                    if let nameField = cell.viewWithTag(102) as? UILabel {
                        if let alarmManager = alarmMgr as? AnyObject {
                            if let alarmArr = alarmMgr.name[indexPath.row]! as? String{
                             
                                    nameField.text = alarmArr;
                                
                            }
                        }
                    }
                    
//                    cell.textLabel!.text = dateString;
//                    cell.detailTextLabel?.text = "new";
                }
            }
        } else{
            println("no time set");
        }
        
//        if let alarm = alarmMgr as? Alarm{
//            if let array = alarmMgr.timeOfArrival as! Array?{
//                println((indexPath.row));
//                var count = alarmMgr.timeOfArrival.count;
//                if (indexPath.row <= count){
//                    if let time = alarmMgr.timeOfArrival[indexPath.row]{
//                        println("has time");
//                    }
//                }
//            }
//            println("has alarm");
//        } else{
//            println("no time yet");
//        }
            //if (date != nil){
//                var dateFormatter = NSDateFormatter();
//                dateFormatter.dateFormat = "hh:mm"
//                var dateString = dateFormatter.stringFromDate(date);
//                cell.textLabel!.text = dateString;
//                cell.detailTextLabel?.text = "new";
            //}
//        } else{
//            cell.textLabel!.text = "No Time Set";
//            cell.detailTextLabel?.text = "";
//        }
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
            
            if ((alarmMgr.name[indexPath.row]) != nil){
                alarmMgr.name.removeAtIndex(indexPath.row)
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
            
            if (objects.count < 1){
                self.navigationItem.leftBarButtonItem = nil
                self.navigationItem.leftBarButtonItem?.tintColor = nil
            }
            
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }


}

