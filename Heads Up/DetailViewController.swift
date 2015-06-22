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

class DetailViewController: UIViewController {

    @IBOutlet weak var detailDescriptionLabel: UILabel!
    @IBOutlet weak var myDatePicker: UIDatePicker!
    @IBOutlet var destination: UITextField?
    @IBOutlet var timeOfArrival: UITextField?
    @IBOutlet var bufferTime: UITextField?
    @IBOutlet var alarmText: UITextField?
    
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
        println("index is \(index)");
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
        myDatePicker.datePickerMode = UIDatePickerMode.Time // 4- use time only
        myDatePicker.addTarget(self, action: Selector("datePickerChanged:"), forControlEvents: UIControlEvents.ValueChanged)
        
        if (alarmMgr.destination[index] != nil){
            destination!.text = alarmMgr.destination[index];
        }
        if (alarmMgr.timeOfArrival[index] != nil){
            myDatePicker.setDate(alarmMgr.timeOfArrival[index]!, animated: true);
        }
        if (alarmMgr.bufferTime[index] != nil){
            let x : Int = alarmMgr.bufferTime[index]!
            var str = String(x)
            bufferTime!.text = str;
        }
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
    
    func getTraffic(){
        
        //Convert address string to be HTML safe
        let toArraySpace = destination!.text.componentsSeparatedByString(" ")
        let addressPhaseOne = join("+", toArraySpace)
        let toArrayComma = addressPhaseOne.componentsSeparatedByString(",")
        let addressHTML = join("", toArrayComma)
        println("http://maps.googleapis.com/maps/api/geocode/json?address=\(addressHTML)&sensor=false");
        self.HTTPGetJSON("http://maps.googleapis.com/maps/api/geocode/json?address=\(addressHTML)&sensor=false") {
            (data: Dictionary<String, AnyObject>, error: String?) -> Void in
            if (error != nil){
                println(error)
            } else {
                if let results = data["results"]![0] as? NSDictionary {
                    if let geometry = results["geometry"] as? NSDictionary {
                        if let location = geometry["location"] as? NSDictionary {
                            if let lat = location["lat"] as? Float{
                                locationMgr.dest_lat = lat;
                                println("lat is \(lat)");
                            }
                            if let lng = location["lng"] as? Float{
                                locationMgr.dest_lng = lng;
                                println("lng is \(lng)");
                            }
                            
                            println("https://api.tomtom.com/lbs/services/route/3/\(locationMgr.user_lat),\(locationMgr.user_lng):\(locationMgr.dest_lat),\(locationMgr.dest_lng)/Quickest/json?avoidTraffic=true&includeTraffic=true&language=en&day=today&key=6havbcb5nqy2upzc449gj7j6");
                            
                            //Get traffic results for destination
                            self.HTTPGetJSON("https://api.tomtom.com/lbs/services/route/3/\(locationMgr.user_lat),\(locationMgr.user_lng):\(locationMgr.dest_lat),\(locationMgr.dest_lng)/Quickest/json?avoidTraffic=true&includeTraffic=true&language=en&day=today&key=6havbcb5nqy2upzc449gj7j6") {
                                (data: Dictionary<String, AnyObject>, error: String?) -> Void in
                                if (error != nil){
                                    println(error)
                                } else {
                                    println("inside");
                                    if let route = data["route"]! as? NSDictionary {
                                        println("found route");
                                        if let summary = route["summary"] as? NSDictionary {
                                            println("summary");
                                            if let totalDelaySeconds = summary["totalDelaySeconds"] as! Int! {
                                                alarmMgr.total_delay_time[self.index] = totalDelaySeconds;
                                            }
                                            if let totalTimeSeconds = summary["totalTimeSeconds"] as? Int {
                                                alarmMgr.total_time_seconds[self.index] = totalTimeSeconds;
                                            }
                                            var totalTimeWithDelay = alarmMgr.total_delay_time[self.index]! + alarmMgr.total_time_seconds[self.index]! + alarmMgr.bufferTime[self.index]!;
                                            println("Total time with delay is \(totalTimeWithDelay) seconds");
                                            //self.delayTime!.text = String(total_delay_time);
                                            
                                            println("total seconds \(alarmMgr.total_time_seconds[self.index])");
                                            println("total delay \(alarmMgr.total_delay_time[self.index])");
                                            println("total buffer \(alarmMgr.bufferTime[self.index])");
                                            
                                            var secondsChanged = totalTimeWithDelay;
                                            var minutesChanged = (totalTimeWithDelay) % 60;
                                            var hoursChanged = minutesChanged / 60;
                                            let negativeSeconds = -secondsChanged;
                                            
                                            //Get current time
                                            let date = alarmMgr.timeOfArrival[self.index]!
                                            let calendar = NSCalendar.currentCalendar()
                                            let components = calendar.components(.CalendarUnitHour | .CalendarUnitMinute, fromDate: date)
                                            println("you want to get there at \(date)");
                                            let hour = components.hour - hoursChanged
                                            let minutes = components.minute - minutesChanged
                                            let seconds = components.second - secondsChanged;
                                            
                                            //subtract 15 minutes
                                            let finalCal = NSCalendar.currentCalendar()
                                            let finalDate = finalCal.dateByAddingUnit(.CalendarUnitSecond, value: negativeSeconds, toDate: date, options: nil)
                                            
                                            println("leave at \(finalDate)");
                        
                                            println("must leave at \(hour):\(minutes)");
                                            
                                            var dateFormatter = NSDateFormatter()
                                            
//                                            dateFormatter.dateStyle = NSDateFormatterStyle.FullStyle
//                                            dateFormatter.timeStyle = NSDateFormatterStyle.FullStyle
                                            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss" // superset of OP's format
                                            
                                            
//                                            var dateString = "2014-07-15" // change to your date format
//                                            
//                                            var dateFormatter = NSDateFormatter()
//                                            dateFormatter.dateFormat = "yyyy-MM-dd"
//                                            
//                                            var date = dateFormatter.dateFromString(dateString)
//                                            
                                            
                                            //let cal = NSCalendar(calendarIdentifier: NSGregorianCalendar)
                                            let cal = NSCalendar.currentCalendar()
                                            let newDate = calendar.startOfDayForDate(date)
                                            alarmMgr.timeCalculated[self.index] = finalDate;
                                            
                                        }
                                    }
                                }
                            }
                        }
                        
                    }
                }
            }
        }
        
        //var goOff = alarmMgr.total_time_seconds[self.index]! + alarmMgr.total_delay_time[self.index]! + alarmMgr.bufferTime[self.index]!;
        
    }
    
    @IBAction func addAlarm(sender : UIButton){
        println(locationMgr.user_lat);
        println(locationMgr.user_lng);
        alarmMgr.destination[index] = destination!.text;
        alarmMgr.bufferTime[index] = bufferTime!.text.toInt();
        
        getTraffic();
        //vars
        //println(alarmMgr.destination[index]);
        //println(alarmMgr.timeOfArrival[index]);
        //println(alarmMgr.bufferTime[index]);
        
        //alarmText!.text = alarmMgr.time[index]!;
        
        //Check for traffic
        alarmMgr.traffic_scheduler[index] = NSTimer.scheduledTimerWithTimeInterval(10.0, target: self, selector: Selector("getTraffic"), userInfo: nil, repeats: true)
        
        //Check for alarms
        alarmMgr.alarm_scheduler[index] = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: Selector("checkAlarm"), userInfo: nil, repeats: true)
        
        self.view.endEditing(true);
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func checkAlarm() {
        //Get current time
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
    
        var todayDate = dateFormatter.dateFromString(strDate as String)
        println(todayDate);
        //println("Time planned \(alarmMgr.timeOfArrival[index]!)");
        println("Time calculated \(alarmMgr.timeCalculated[index]!)");
        //println("current date is \(strDate) current alarm is \(alarmMgr.time[index])");
         //if (strDate != ""){
         
        
        // Date comparision to compare current date and end date.
        var dateComparisionResult:NSComparisonResult = date.compare(alarmMgr.timeCalculated[index]!)
        println("date is \(date) and time calculated is \(alarmMgr.timeCalculated[index]!)");
        if dateComparisionResult == NSComparisonResult.OrderedDescending
        {
            println("greater than");
            alarmMgr.alarm_scheduler[index]!.invalidate()
            alarmMgr.traffic_scheduler[index]!.invalidate()
            
            //Notification
            var localNotification:UILocalNotification = UILocalNotification()
            localNotification.alertBody = "Alarm went off"
            localNotification.fireDate = NSDate(timeIntervalSinceNow: 10)
            //localNotification.soundName = UILocalNotificationDefaultSoundName
            localNotification.soundName = "alarm.mp3"
            UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
            
            func stopPlayer(){
                audioPlayer.stop()
            }
            
            var alertMsg = "Time to go!"
            var alert: UIAlertView!
            alert = UIAlertView(title: "", message: alertMsg, delegate: nil, cancelButtonTitle: "OK")
            sleep(5)
            //alert.show()
            
            var uiAlert = UIAlertController(title: "Time to go!", message: "Message", preferredStyle: UIAlertControllerStyle.Alert)
            self.presentViewController(uiAlert, animated: true, completion: nil)
            
            uiAlert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { action in
                self.audioPlayer.stop()
            }))
            
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
        else if dateComparisionResult == NSComparisonResult.OrderedAscending
        {
            println("less than");

        }
        else if dateComparisionResult == NSComparisonResult.OrderedSame
        {
            println("same");
        }
        
         //if (newDate == alarmMgr.timeCalculated[index]!){
//            println("match");
//            alarmMgr.alarm_scheduler[index]!.invalidate()
//            alarmMgr.traffic_scheduler[index]!.invalidate()
//            
//            //Notification
//            var localNotification:UILocalNotification = UILocalNotification()
//            localNotification.alertBody = "Alarm went off"
//            localNotification.fireDate = NSDate(timeIntervalSinceNow: 0)
//            localNotification.soundName = UILocalNotificationDefaultSoundName
//            //localNotification.soundName = "who_are_you.mp3"
//            UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
//
//            var alertMsg = "Time to go!"
//            var alert: UIAlertView!
//            alert = UIAlertView(title: "", message: alertMsg, delegate: nil, cancelButtonTitle: "OK")
//            alert.show()

        //}
    }

}

