//
//  DetailViewController.swift
//  Heads Up
//
//  Created by Chris Callaway on 4/11/15.
//  Copyright (c) 2015 Transcendence Productions. All rights reserved.
//

import UIKit
import Foundation
import AVFoundation
import SpriteKit
import PromiseKit

class DetailViewController: UIViewController {

    @IBOutlet weak var detailDescriptionLabel: UILabel!
    //@IBOutlet weak var myDatePicker: UIDatePicker!
    @IBOutlet var destination: UITextField?
    @IBOutlet var timeOfArrival: UITextField?
    @IBOutlet var bufferTime: UITextField?
    @IBOutlet var alarmText: UITextField?
    @IBOutlet weak var alarmName: UITextField!
    @IBOutlet weak var useTolls: UISwitch!
    
    @IBOutlet weak var timeToArriveField: UITextField!
    
    @IBAction func mapButtonClicked(sender: AnyObject) {
        println("map clicked");
        UIApplication.sharedApplication().openURL(NSURL(string : directionsUrl())!)
//        performSegueWithIdentifier("mapView", sender: self)
    }
    
    var myDatePicker:UIDatePicker = UIDatePicker()
    
    var index: Int = Int();
    var audioPlayer = AVAudioPlayer()

    var detailItem: AnyObject? {
        didSet {
            // Update the view.
            self.configureView()
        }
    }
    

    func configureView() {
        // Update the user interface for the detail item.
        //println(self.detailItem);
        if let detail: AnyObject = self.detailItem {
            index = Int(detail as! NSNumber);
            if let label = self.detailDescriptionLabel {
                //label.text = detail.description
            }
        }
    }
    
    func datePickerChanged(myDatePicker:UIDatePicker) {
        var dateFormatter = NSDateFormatter()
        
        dateFormatter.dateStyle = NSDateFormatterStyle.FullStyle
        dateFormatter.timeStyle = NSDateFormatterStyle.FullStyle
        dateFormatter.dateFormat = "yyyy-MM-dd 'at' h:mm a" // superset of OP's format
        var strDate = dateFormatter.stringFromDate(myDatePicker.date)
        saveTimeOfArrival();
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        self.view.endEditing(true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.configureView()
        
        // set initial values
        alarmMgr.name[index] = "";
        
        if (alarmMgr.name[index] != nil){
            alarmName!.text = alarmMgr.name[index];
        }
        if (alarmMgr.destination[index] != nil){
            destination!.text = alarmMgr.destination[index];
        }
        if (alarmMgr.timeOfArrival[index] != nil && alarmMgr.name[index] != nil){
            var dateFormatter = NSDateFormatter();
            dateFormatter.dateFormat = "hh:mm a"
            var dateString = dateFormatter.stringFromDate(alarmMgr.timeOfArrival[index]!);
            timeToArriveField.text = dateString;
        }
        if (alarmMgr.bufferTime[index] != nil){
            let x : Int = alarmMgr.bufferTime[index]!
            var str = String(x)
            bufferTime!.text = str;
        }
        //alarmMgr.avoidTolls[index] = "true";
    
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func textFieldShouldReturn(textField: UITextField!) -> Bool{
        textField.resignFirstResponder();
        return true;
    }
    
    func directionsUrl() -> String{
        var url : String;
        if (alarmMgr.avoidTolls[self.index]! == "true"){
            url = "https://maps.google.com?saddr=Current+Location&daddr=\(formatAddressForWeb(destination!.text))&mode=driving&dirflg=t";
        } else{
            url = "https://maps.google.com?saddr=Current+Location&daddr=\(formatAddressForWeb(destination!.text))&mode=driving";
        }
        return url;
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    
    //Convert address string to be HTML safe
    func formatAddressForWeb(address : String) -> String{
        var addressHTML : String = "";
        if (destination!.text != ""){
            let toArraySpace = destination!.text.componentsSeparatedByString(" ")
            let addressPhaseOne = join("+", toArraySpace)
            let toArrayComma = addressPhaseOne.componentsSeparatedByString(",")
            addressHTML = join("", toArrayComma)
        }
        return addressHTML
    }
    
    func saveDestinationCoords(address : String) -> Promise<Bool> {
        return Promise { fulfill, reject in
            self.HTTPGetJSON("http://maps.googleapis.com/maps/api/geocode/json?address=\(address)&sensor=false") {
                (data: Dictionary<String, AnyObject>, error: String?) -> Void in
                if (error != nil){
                    println(error)
                } else {
                    if let check = data["status"] as? String{
                        if (check == "ZERO_RESULTS"){
                            println("invalid destination");
                            fulfill(false);
                        } else{
                            if let results = data["results"]![0] as? NSDictionary {
                                if let geometry = results["geometry"] as? NSDictionary {
                                    if let location = geometry["location"] as? NSDictionary {
                                        var haveLat = false;
                                        var haveLng = false;
                                        if let lat = location["lat"] as? Float{
                                            locationMgr.dest_lat = lat;
                                            haveLat = true;
                                        }
                                        if let lng = location["lng"] as? Float{
                                            locationMgr.dest_lng = lng;
                                            haveLng = true;
                                        }
                                        if (haveLat && haveLng){
                                            fulfill(true);
                                        } else{
                                            fulfill(false);
                                        }
                                    } else{
                                        fulfill(false);
                                    }
                                } else{
                                    fulfill(false);
                                }
                            } else{
                                fulfill(false);
                            }
                        }
                    }
                }
            }

        }
    }
    
    func getTraffic(Void) -> Promise<NSDictionary> {
        var url : String;
        if (alarmMgr.avoidTolls[self.index] == "true"){
            url = "https://maps.googleapis.com/maps/api/directions/json?origin=\(locationMgr.user_lat),\(locationMgr.user_lng)&destination=\(locationMgr.dest_lat),\(locationMgr.dest_lng)&avoid=tolls&mode=driving&duration_in_traffic=true&key=AIzaSyD0NCpm0dDaOZ46XDR82YXR0ReJHa8oOo8";
        } else{
            url = "https://maps.googleapis.com/maps/api/directions/json?origin=\(locationMgr.user_lat),\(locationMgr.user_lng)&destination=\(locationMgr.dest_lat),\(locationMgr.dest_lng)&mode=driving&duration_in_traffic=true&key=AIzaSyD0NCpm0dDaOZ46XDR82YXR0ReJHa8oOo8";
        }
        
        println("getting traffic at \(url)");
        return Promise { fulfill, reject in
            self.HTTPGetJSON(url) {
                (data: Dictionary<String, AnyObject>, error: String?) -> Void in
                if (error != nil){
                    println(error)
                } else {
                    println("data is here \(data)");
                    if let route = data["routes"]![0] as? NSDictionary {
                        println("route exists");
                        fulfill(route);
                    } else{
                        reject(NSError());
                    }
                }
            }
        }
    }
    
    func printTotalTimeDetails(totalTimeWithDelay : Int) -> Void{
        println("Total time with delay is \(totalTimeWithDelay) seconds");
        println("total seconds \(alarmMgr.total_time_seconds[self.index])");
        println("total delay \(alarmMgr.total_delay_time[self.index])");
        println("total buffer \(alarmMgr.bufferTime[self.index])");
    }
    
    func saveTraffic(route: NSDictionary) -> Void{
        println("about to save traffic");
        if let summary = route["legs"]![0] as? NSDictionary {
            println("savings traffic");
            // total delay in seconds
            if let duration = summary["duration"] as? NSDictionary! {
                println("has distance");
                if let totalTime = duration["value"] as! Int! {
                    println("received total time \(totalTime)");
                    alarmMgr.total_time_seconds[self.index] = totalTime;
                }
            }
            
            // total time in seconds
//            if let totalTimeSeconds = summary["totalTimeSeconds"] as? Int {
//                alarmMgr.total_time_seconds[self.index] = totalTimeSeconds;
//            }
            
            // calculate total time including traffic and time needed to get ready
            var totalTimeWithDelay = alarmMgr.total_time_seconds[self.index]! + alarmMgr.bufferTime[self.index]!;
            
            printTotalTimeDetails(totalTimeWithDelay);
            
            // time factoring
            var secondsChanged = totalTimeWithDelay;
            var minutesChanged = (totalTimeWithDelay) % 60;
            var hoursChanged = minutesChanged / 60;
            
            // turn minutes buffer into secnods
            var buffer = alarmMgr.bufferTime[self.index]! * 60;
            
            // seconds to subtract from time of arrival
            let negativeSeconds = -secondsChanged - buffer;
            println("seconds to subtract \(negativeSeconds)");
            
            //Get current time
            let date = alarmMgr.timeOfArrival[self.index]!
            var dateFormatter = NSDateFormatter()
            dateFormatter.dateStyle = NSDateFormatterStyle.FullStyle
            dateFormatter.timeStyle = NSDateFormatterStyle.FullStyle
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss" // superset of OP's format
            dateFormatter.timeZone = NSTimeZone(name: "GMT")
            //dateFormatter.locale =  NSLocale(localeIdentifier: "en_US_POSIX")
            let strDate = dateFormatter.stringFromDate(date)
            let newDate = dateFormatter.dateFromString(strDate)
            //date.timeZone = NSTimeZone.systemTimeZone()

            let calendar = NSCalendar.currentCalendar()
            let components = calendar.components(.CalendarUnitHour | .CalendarUnitMinute, fromDate: newDate!)
            
            // break down date into units
            let hour = components.hour - hoursChanged
            let minutes = components.minute - minutesChanged
            let seconds = components.second - secondsChanged;
            
            // print what time to arrive to console
            println("you want to get there at \(alarmMgr.timeOfArrival[index])");
            
            // subtract total time with traffic from time to arrive
            let finalCal = NSCalendar.currentCalendar()
            finalCal.timeZone = NSTimeZone(name: "GMT")!
        
            
            let finalDate = finalCal.dateByAddingUnit(.CalendarUnitSecond, value: negativeSeconds, toDate: newDate!, options: nil)
    
            // print time to leave in date format to console
            println("leave at \(finalDate)");
            
            // print time to leave in hours and minutes to console
            println("must leave at \(hour):\(minutes)");
            
            // save time to leave
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            dateFormatter.timeZone = NSTimeZone(name: "GMT")
            var dateString2 = dateFormatter.stringFromDate(finalDate!);
            var date2 = dateFormatter.dateFromString(dateString2);
                
            alarmMgr.timeCalculated[self.index] = date2;
        }
    }
    
    func saveFields() -> Void{
        alarmMgr.destination[index] = destination!.text;
        alarmMgr.bufferTime[index] = bufferTime!.text.toInt();
        alarmMgr.name[index] = alarmName!.text;
    }
    
    func updateAlarm() -> Void{
        let address = formatAddressForWeb(destination!.text);
        
        // save fields
        self.saveFields();
        
        // save destination coords
        saveDestinationCoords(address).then{ (valid: Bool) -> Void in
            if (valid){
                // request traffic api
                self.getTraffic().then {(route: NSDictionary) -> Void in
                    // if response is valid
                    self.saveTraffic(route);
                }
            }
        }
    }
    
    @IBAction func tollsChanged(sender: AnyObject) {
        if (useTolls.on){
            alarmMgr.avoidTolls[self.index]! = "true";
        } else{
            alarmMgr.avoidTolls[self.index]! = "false";
        }
    }
    
    func isValidAddress() -> Promise<Bool>{
        return Promise { fulfill, reject in
            let address = formatAddressForWeb(destination!.text);
            println("http://maps.googleapis.com/maps/api/geocode/json?address=\(address)&sensor=false")
            saveDestinationCoords(address).then{(valid: Bool) -> Void in
                if (valid){
                    self.HTTPGetJSON("http://maps.googleapis.com/maps/api/geocode/json?address=\(address)&sensor=false") {
                        (data: Dictionary<String, AnyObject>, error: String?) -> Void in
                        if (error != nil){
                            println("found error is nil");
                            fulfill(false);
                        } else {
                            println("about to get results");
                            if let results = data["results"]![0] as? NSDictionary {
                                if let geometry = results["geometry"] as? NSDictionary {
                                    if let location = geometry["location"] as? NSDictionary {
                                        println("fulfill");
                                        fulfill(true);
                                    } else{
                                        println("reject");
                                        fulfill(false);
                                    }
                                } else{
                                    println("reject");
                                    fulfill(false);
                                }
                            } else{
                                println("reject");
                                fulfill(false);
                            }
                        }
                    }
                } else{
                    println("failed to save dest coords");
                    fulfill(false);
                }
            }
        }
    }
    
    func printAlarmDetails(index: Int){
        println(alarmMgr.destination[index]);
        println(alarmMgr.timeOfArrival[index]);
        println(alarmMgr.bufferTime[index]);
    }
    
    @IBAction func addAlarm(sender : UIButton){
        
        self.isValidAddress().then { (valid: Bool) -> Void in
            println("valid \(valid)");
            if (valid){
                println("valid");
                self.updateAlarm();
                
                self.deactivateAlarm();
                
                //Check for traffic api loop
                alarmMgr.traffic_scheduler[self.index] = NSTimer.scheduledTimerWithTimeInterval(300.0, target: self, selector: Selector("updateAlarm"), userInfo: nil, repeats: true)
                
                //Check for alarm loop
                alarmMgr.alarm_scheduler[self.index] = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: Selector("checkAlarm"), userInfo: nil, repeats: true)
                
                self.view.endEditing(true);
                self.navigationController?.popViewControllerAnimated(true)
            } else {
                println("invalid");
            }
        }
        
        //let defaults = NSUserDefaults.standardUserDefaults()
        //defaults.setObject(alarmMgr.destination[index], forKey: "destination")
        //defaults.setObject("crap", forKey: "string")
    }
    
    func getCurrentTime() -> NSDate{
        let date = NSDate()
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components(.CalendarUnitHour | .CalendarUnitMinute, fromDate: date)
        let hour = components.hour
        let minutes = components.minute
        var dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = NSDateFormatterStyle.FullStyle
        dateFormatter.timeStyle = NSDateFormatterStyle.FullStyle
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss" // superset of OP's format
        dateFormatter.timeZone = NSTimeZone(name: "GMT")
        //dateFormatter.locale =  NSLocale(localeIdentifier: "en_US_POSIX")
        let strDate = dateFormatter.stringFromDate(date)
        
        var newDate = dateFormatter.dateFromString(strDate);
        return newDate!;
    }
    
    func deactivateAlarm() -> Void{
        // stop alarm loop
        if let alarmCheck = alarmMgr.alarm_scheduler[index]{
            alarmMgr.alarm_scheduler[index]!.invalidate()
        }
        // stop hitting the traffic api
        if let trafficCheck = alarmMgr.traffic_scheduler[index]{
            alarmMgr.traffic_scheduler[index]!.invalidate()
        }
    }
    
    func configurePushNotification() -> Void{
        // push notification setup
        var localNotification:UILocalNotification = UILocalNotification()
        localNotification.alertBody = "Alarm went off"
        localNotification.hasAction = true;
        localNotification.fireDate = NSDate(timeIntervalSinceNow: 10)
        localNotification.soundName = "alarm.mp3"
        
        // schedule push notification
        UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
    }
    
    func showAlertMessage() -> Void{
        // configure alert message
        var alertController = UIAlertController(title: "Time to go!", message: "Time to go!", preferredStyle: .Alert)
        var okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) {
            UIAlertAction in
            self.audioPlayer.stop()
        }
        alertController.addAction(okAction)
        UIApplication.sharedApplication().keyWindow?.rootViewController?.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func timeToGo() -> Void{
        deactivateAlarm();
        configurePushNotification();
        showAlertMessage();
        
        // configure alert sound
        var alertSound = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("alarm", ofType: "mp3")!)
        
        // Removed deprecated use of AVAudioSessionDelegate protocol
        AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, error: nil)
        AVAudioSession.sharedInstance().setActive(true, error: nil)
        
        var error:NSError?
        audioPlayer = AVAudioPlayer(contentsOfURL: alertSound, error: &error)
        audioPlayer.prepareToPlay()
        audioPlayer.numberOfLoops = -1
        audioPlayer.play()
    }
    
    func checkAlarm() {
        //Get current time
        let date = NSDate()
        let currentTime = getCurrentTime();
        
        // Date comparision to compare current date and end date.
        var dateComparisionResult:NSComparisonResult = currentTime.compare(alarmMgr.timeCalculated[index]!)
        println("now is \(currentTime) and time to leave is \(alarmMgr.timeCalculated[index]!)");
        
        switch (dateComparisionResult){
            // time to go
            case NSComparisonResult.OrderedDescending:
                timeToGo();
            break;
            case NSComparisonResult.OrderedAscending:
                println("not time to leave yet");
            break;
            case NSComparisonResult.OrderedSame:
                println("exact match");
            break;
            default:
            break;
        }
    }
    
    // Datepicker UI
    @IBAction func timeToArrive(sender: UITextField) {
        
        myDatePicker.datePickerMode = UIDatePickerMode.Time

        setTimeOfArrivalUI();
        
        //Create the view
        let inputView = UIView(frame: CGRectMake(0, 0, self.view.frame.width, 240))
        inputView.addSubview(myDatePicker) // add date picker to UIView
        
        // add done button
        let doneButton = UIButton(frame: CGRectMake((self.view.frame.size.width/2) - (-100), 0, 100, 50))
        doneButton.setTitle("Done", forState: UIControlState.Normal)
        doneButton.setTitle("Done", forState: UIControlState.Highlighted)
        doneButton.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        doneButton.setTitleColor(UIColor.grayColor(), forState: UIControlState.Highlighted)
        
        inputView.addSubview(doneButton) // add Button to UIView
        
        doneButton.addTarget(self, action: "doneButton:", forControlEvents: UIControlEvents.TouchUpInside) // set button click event
        
        sender.inputView = inputView
        myDatePicker.addTarget(self, action: Selector("datePickerChanged:"), forControlEvents: UIControlEvents.ValueChanged)
        
        datePickerValueChanged(myDatePicker) // Set the date on start.
    }
    
    func setTimeOfArrivalUI() -> Void{
        myDatePicker.addTarget(self, action: Selector("datePickerChanged:"), forControlEvents: UIControlEvents.ValueChanged)
        var dateFormatter = NSDateFormatter();
        dateFormatter.dateFormat = "hh:mm a"
        dateFormatter.timeZone = NSTimeZone(name: "GMT")
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        var dateString = dateFormatter.stringFromDate(myDatePicker.date);
        println("date string is \(dateString)");
        
        if (alarmMgr.timeOfArrival[index] != nil){
//            myDatePicker.timeZone = NSTimeZone.localTimeZone()
            println("setting date \(dateString)");
            
            //myDatePicker.setDate(alarmMgr.timeOfArrival[index]!, animated: true);
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            dateFormatter.timeZone = NSTimeZone(name: "GMT")
            var dateString2 = dateFormatter.stringFromDate(myDatePicker.date);
            var date2 = dateFormatter.dateFromString(dateString);
            alarmMgr.timeOfArrival[index] = date2
            println("about to save date \(dateString)");
            println("saving date \(alarmMgr.timeOfArrival[index]!)");
        }
    }
    
    func saveTimeOfArrival() -> Void{
        // save time of arrival
//        if let item = alarmMgr.timeOfArrival[index] {
//            println("saving date \(myDatePicker.date)");
//            alarmMgr.timeOfArrival[index] = myDatePicker.date
//            println("time to get there is \(alarmMgr.timeOfArrival[index])");
//        }
    }
    
    func populateDateField(date : NSDate){
        println("populating date text field");
        var dateFormatter = NSDateFormatter();
        dateFormatter.dateFormat = "hh:mm a"
        dateFormatter.timeZone = NSTimeZone.localTimeZone()
        var dateString = dateFormatter.stringFromDate(myDatePicker.date);
        println("populated with \(dateString)");
        timeToArriveField.text = dateString;
    }
    
    @IBAction func endedAddingDate(sender: UITextField) {
        println("ended adding date");
        setTimeOfArrivalUI();
        saveTimeOfArrival();
        populateDateField(alarmMgr.timeOfArrival[index]!);
    }
    
    func printTotalAlarms() -> Void{
        var totalAlarms = count(alarmMgr.time);
        println("alarm index is \(index)");
        println("total alarms \(totalAlarms)");
    }
    
    // datepicker opened, apply styling format
    func datePickerValueChanged(sender:UIDatePicker) {
        var dateFormatter = NSDateFormatter()
        var strDate = dateFormatter.stringFromDate(myDatePicker.date)
        dateFormatter.dateStyle = NSDateFormatterStyle.FullStyle
        dateFormatter.timeStyle = NSDateFormatterStyle.FullStyle
        dateFormatter.dateFormat = "yyyy-MM-dd 'at' h:mm a" // superset of OP's format
        println("datepicker changed");
    }
    
    func doneButton(sender:UIButton)
    {
        self.view.endEditing(true)
    }

}

