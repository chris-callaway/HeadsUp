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
    @IBOutlet var alarmName: UITextField?
    @IBOutlet weak var timeToArriveField: UITextField!
    
    @IBAction func mapButtonClicked(sender: AnyObject) {
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
        //alarmMgr.time.append(dateFormatter.stringFromDate(myDatePicker.date));
        var item = alarmMgr.timeOfArrival[index];
        if (item != nil){
            //alarmMgr.timeOfArrival[index] = dateFormatter.stringFromDate(myDatePicker.date);
            alarmMgr.timeOfArrival[index] = myDatePicker.date
        }
        //alarmMgr.time[index] = dateFormatter.stringFromDate(myDatePicker.date);
        println("total alarms");
        println(count(alarmMgr.time));
        
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
//        if (alarmMgr.timeOfArrival[index] != nil){
//            myDatePicker.setDate(alarmMgr.timeOfArrival[index]!, animated: true);
//        }
        if (alarmMgr.bufferTime[index] != nil){
            let x : Int = alarmMgr.bufferTime[index]!
            var str = String(x)
            bufferTime!.text = str;
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
//        let defaults = NSUserDefaults.standardUserDefaults()
//        if let name = defaults.stringForKey("destination")
//        {
//            println("destination \(name)")
//        }
    }
    
    func textFieldShouldReturn(textField: UITextField!) -> Bool{
        textField.resignFirstResponder();
        return true;
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
        let toArraySpace = destination!.text.componentsSeparatedByString(" ")
        let addressPhaseOne = join("+", toArraySpace)
        let toArrayComma = addressPhaseOne.componentsSeparatedByString(",")
        let addressHTML = join("", toArrayComma)
        return addressHTML
    }
    
    func saveDestinationCoords(address : String) -> Promise<Void> {
        return Promise { fulfill, reject in
            self.HTTPGetJSON("http://maps.googleapis.com/maps/api/geocode/json?address=\(address)&sensor=false") {
                (data: Dictionary<String, AnyObject>, error: String?) -> Void in
                if (error != nil){
                    println(error)
                } else {
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
                                    fulfill();
                                } else{
                                    reject(NSError());
                                }
                            }
                        }
                    }
                }
            }

        }
    }
    
    func getTraffic(Void) -> Promise<NSDictionary> {
        return Promise { fulfill, reject in
            self.HTTPGetJSON("https://api.tomtom.com/lbs/services/route/3/\(locationMgr.user_lat),\(locationMgr.user_lng):\(locationMgr.dest_lat),\(locationMgr.dest_lng)/Quickest/json?avoidTraffic=true&includeTraffic=true&language=en&day=today&key=6havbcb5nqy2upzc449gj7j6") {
                (data: Dictionary<String, AnyObject>, error: String?) -> Void in
                if (error != nil){
                    println(error)
                } else {
                    if let route = data["route"]! as? NSDictionary {
                        fulfill(route);
                    } else{
                        reject(NSError());
                    }
                }
            }
        }
    }
    
    func saveTraffic(route: NSDictionary) -> Void{
        if let summary = route["summary"] as? NSDictionary {
            
            // total delay in seconds
            if let totalDelaySeconds = summary["totalDelaySeconds"] as! Int! {
                println("delay exists");
                alarmMgr.total_delay_time[self.index] = totalDelaySeconds;
            }
            
            // total time in seconds
            if let totalTimeSeconds = summary["totalTimeSeconds"] as? Int {
                alarmMgr.total_time_seconds[self.index] = totalTimeSeconds;
            }
            
            // calculate total time including traffic and time needed to get ready
            var totalTimeWithDelay = alarmMgr.total_delay_time[self.index]! + alarmMgr.total_time_seconds[self.index]! + alarmMgr.bufferTime[self.index]!;
            
            println("Total time with delay is \(totalTimeWithDelay) seconds");
            println("total seconds \(alarmMgr.total_time_seconds[self.index])");
            println("total delay \(alarmMgr.total_delay_time[self.index])");
            println("total buffer \(alarmMgr.bufferTime[self.index])");
            
            // time factoring
            var secondsChanged = totalTimeWithDelay;
            var minutesChanged = (totalTimeWithDelay) % 60;
            var hoursChanged = minutesChanged / 60;
            
            // turn minutes buffer into secnods
            var buffer = alarmMgr.bufferTime[self.index]! * 60;
            
            // seconds to subtract from time of arrival
            let negativeSeconds = -secondsChanged - buffer;
            
            //Get current time
            let date = alarmMgr.timeOfArrival[self.index]!
            let calendar = NSCalendar.currentCalendar()
            let components = calendar.components(.CalendarUnitHour | .CalendarUnitMinute, fromDate: date)
            
            // break down date into units
            let hour = components.hour - hoursChanged
            let minutes = components.minute - minutesChanged
            let seconds = components.second - secondsChanged;
            
            // print what time to arrive to console
            println("you want to get there at \(date)");
            
            // subtract total time with traffic from time to arrive
            let finalCal = NSCalendar.currentCalendar()
            let finalDate = finalCal.dateByAddingUnit(.CalendarUnitSecond, value: negativeSeconds, toDate: date, options: nil)
            
            // print time to leave in date format to console
            println("leave at \(finalDate)");
            
            // print time to leave in hours and minutes to console
            println("must leave at \(hour):\(minutes)");
            
            // save time to leave
            alarmMgr.timeCalculated[self.index] = finalDate;
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
        saveDestinationCoords(address).then{
            // request traffic api
            self.getTraffic().then {(route: NSDictionary) -> Void in
                // if response is valid
                self.saveTraffic(route);
            }
        }
    }
    
    func isValidAddress(address : String){
        
    }
    
    func printAlarmDetails(index: Int){
        println(alarmMgr.destination[index]);
        println(alarmMgr.timeOfArrival[index]);
        println(alarmMgr.bufferTime[index]);
    }
    
    @IBAction func addAlarm(sender : UIButton){
        
        updateAlarm();
        
        //Check for traffic loop
        alarmMgr.traffic_scheduler[index] = NSTimer.scheduledTimerWithTimeInterval(300.0, target: self, selector: Selector("updateAlarm"), userInfo: nil, repeats: true)
        
        //Check for alarms loop
        alarmMgr.alarm_scheduler[index] = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: Selector("checkAlarm"), userInfo: nil, repeats: true)
        
        self.view.endEditing(true);
        self.navigationController?.popViewControllerAnimated(true)
        
        //let defaults = NSUserDefaults.standardUserDefaults()
        //defaults.setObject(alarmMgr.destination[index], forKey: "destination")
        //defaults.setObject("crap", forKey: "string")
    }
    
    func getCurrentTime() -> String{
        let date = NSDate()
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components(.CalendarUnitHour | .CalendarUnitMinute, fromDate: date)
        let hour = components.hour
        let minutes = components.minute
        var dateFormatter = NSDateFormatter()
        
        dateFormatter.dateStyle = NSDateFormatterStyle.FullStyle
        dateFormatter.timeStyle = NSDateFormatterStyle.FullStyle
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss" // superset of OP's format
        
        var strDate = dateFormatter.stringFromDate(date);
        return strDate;
    }
    
    func deactivateAlarm() -> Void{
        alarmMgr.alarm_scheduler[index]!.invalidate()
        alarmMgr.traffic_scheduler[index]!.invalidate()
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
        var dateComparisionResult:NSComparisonResult = date.compare(alarmMgr.timeCalculated[index]!)
        println("now is \(date) and time to leave is \(alarmMgr.timeCalculated[index]!)");
        
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
        if (alarmMgr.timeOfArrival[index] != nil){
            myDatePicker.setDate(alarmMgr.timeOfArrival[index]!, animated: true);
        }
    }
    
    func saveTimeOfArrival() -> Void{
        // save time of arrival
        if let item = alarmMgr.timeOfArrival[index] {
            alarmMgr.timeOfArrival[index] = myDatePicker.date
        }
    }
    
    func populateDateField(date : NSDate){
        var dateFormatter = NSDateFormatter();
        dateFormatter.dateFormat = "hh:mm a"
        var dateString = dateFormatter.stringFromDate(date);
        timeToArriveField.text = dateString;
    }
    
    @IBAction func endedAddingDate(sender: UITextField) {
        setTimeOfArrivalUI();
        saveTimeOfArrival();
        populateDateField(alarmMgr.timeOfArrival[index]!);
    }
    
    func printTotalAlarms() -> Void{
        var totalAlarms = count(alarmMgr.time);
        println("alarm index is \(index)");
        println("total alarms \(totalAlarms)");
    }
    
    func datePickerValueChanged(sender:UIDatePicker) {
        var dateFormatter = NSDateFormatter()
        var strDate = dateFormatter.stringFromDate(myDatePicker.date)
        dateFormatter.dateStyle = NSDateFormatterStyle.FullStyle
        dateFormatter.timeStyle = NSDateFormatterStyle.FullStyle
        dateFormatter.dateFormat = "yyyy-MM-dd 'at' h:mm a" // superset of OP's format
    }
    
    func doneButton(sender:UIButton)
    {
        self.view.endEditing(true)
    }

}

