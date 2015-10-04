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
import CoreData

class CustomTableViewCell: UITableViewCell {

    var index: Int?
    
    @IBOutlet weak var alarmSwitch: UISwitch!
    
    @IBAction func alarmSwitchChanged(sender: AnyObject) {
        
        let defaults = NSUserDefaults.standardUserDefaults()
        
//        var btnPos: CGPoint = sender.convertPoint(CGPointZero, toView: sender.tableView)
//        //var indexPath: NSIndexPath = sender.tableView.indexPathForRowAtPoint(btnPos)!
//        println(btnPos);
        
//        var view = sender.superview
//        let pointInTable: CGPoint = sender.convertPoint(sender.bounds.origin, toView: self.superview)
//        let cellIndexPath = view.indexPathForRowAtPoint(pointInTable)
//    
//        
//        //var view = sender.superview
//        var table: UITableView = cell.superview as! UITableView
//        let textFieldIndexPath = table.indexPathForCell(cell)
//        
//        println(textFieldIndexPath);
        if (alarmSwitch.on){
            //var text = alarmMgr.time[0];
            
            // save avoid tolls
            let avoidTolls = NSKeyedArchiver.archivedDataWithRootObject(alarmMgr.avoidTolls)
            println("avoidTolls saved as \(alarmMgr.avoidTolls)");
            defaults.setObject("ON", forKey: "avoidTolls")
            
            println("ON");
            //            alarmMgr.alarm_scheduler[0]!.invalidate()
            //            alarmMgr.traffic_scheduler[0]!.invalidate()
        } else{
            // save avoid tolls
            let avoidTolls = NSKeyedArchiver.archivedDataWithRootObject(alarmMgr.avoidTolls)
            println("avoidTolls saved as \(alarmMgr.avoidTolls)");
            defaults.setObject("OFF", forKey: "avoidTolls")
            println("OFF");
        }

    }
    
//    alarmSwitch.setOn(false, animated:true)
    
}

class MasterViewController: UITableViewController, CLLocationManagerDelegate {
    
    let defaults = NSUserDefaults.standardUserDefaults()
    
    var objects = alarmMgr.retrievedObject() as! [AnyObject]
    
    func saveObject(object: [AnyObject]) {
        // save time of arrival
        let object = NSKeyedArchiver.archivedDataWithRootObject(objects)
        println("objects saved as \(objects)");
        defaults.setObject(object, forKey: "object")
    }
    
    @IBOutlet weak var alarmSwitch: CustomTableViewCell!
    // Retreive the managedObjectContext from AppDelegate
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    var latitude: Float = Float();
    var longitude: Float = Float();
    let locationManager = CLLocationManager()

    var audioPlayer = AVAudioPlayer()

    override func awakeFromNib() {
        super.awakeFromNib()
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let defaults = NSUserDefaults.standardUserDefaults()
        
        if let alarm = defaults.stringForKey("alarmMgr")
        {
            println("loaded alarm \(alarm)");
        }
        
        // Do any additional setup after loading the view, typically from a nib.
        
        if ((objects.count - 1) > 0){
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
        println("view loaded)");
        
        syncData();
        
    }
    
    func syncData() -> Void{
        let names: [String] = alarmMgr.retrievedName() as! [String]
        println("returning names as \(names)");
        alarmMgr.name = names;
        
        // set to null array then push
        for (var i = 0; i < count(names); i++){
            println("hit that");
            if (count(alarmMgr.traffic_scheduler) < i){
               alarmMgr.traffic_scheduler.append((NSTimer.scheduledTimerWithTimeInterval(300.0, target: self, selector: Selector("updateAlarm"), userInfo: nil, repeats: true)))
            }
            if (count(alarmMgr.alarm_scheduler) < i){
                alarmMgr.alarm_scheduler.append((NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: Selector("checkAlarm"), userInfo: nil, repeats: true)))
            }
        }
        
//        let alarmScheduler: [NSTimer] = alarmMgr.retrievedAlarmScheduler() as! [NSTimer]
//        println("returning alarm scheduler as \(alarmScheduler)");
//        alarmMgr.alarm_scheduler = alarmScheduler;
//        
//        let trafficScheduler: [NSTimer] = alarmMgr.retrievedTrafficScheduler() as! [NSTimer]
//        println("returning trafficScheduler as \(trafficScheduler)");
//        alarmMgr.traffic_scheduler = trafficScheduler;
        
        let totalDelayTime: [Int] = alarmMgr.retrievedTotalDelayTime() as! [Int]
        println("returning totalDelayTime as \(totalDelayTime)");
        alarmMgr.total_delay_time = totalDelayTime;
        
        let totalTimeSeconds: [Int] = alarmMgr.retrievedTotalTimeSeconds() as! [Int]
        println("returning total_time_seconds as \(totalTimeSeconds)");
        alarmMgr.total_time_seconds = totalTimeSeconds;
        
        let avoidTolls: [String] = alarmMgr.retrievedAvoidTolls() as! [String]
        println("returning avoidTolls as \(avoidTolls)");
        alarmMgr.avoidTolls = avoidTolls;
        
        let destination: [String] = alarmMgr.retrievedDestination() as! [String]
        println("returning destination as \(destination)");
        alarmMgr.destination = destination;
        
        let timeOfArrival: [NSDate] = alarmMgr.retrievedTimeofArrival() as! [NSDate]
        println("returning time of arrival as \(timeOfArrival)");
        alarmMgr.timeOfArrival = timeOfArrival;
        
        let bufferTime: [Int] = alarmMgr.retrievedBufferTime() as! [Int]
        println("returning bufferTime as \(bufferTime)");
        alarmMgr.bufferTime = bufferTime;
        
        let timeCalculated: [NSDate] = alarmMgr.retrievedTimeCalculated() as! [NSDate]
        println("returning time calculated as \(timeCalculated)");
        alarmMgr.timeCalculated = timeCalculated;
        
    }
    
    func getAlarmCount() -> Int{
        let names: [String] = alarmMgr.retrievedName() as! [String]
        return (count(names) - 1)
        println("returning names as \(names)");
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        let defaults = NSUserDefaults.standardUserDefaults()
        
        println("view appeared");
        self.tableView.reloadData()
        if ((objects.count - 1) > 1){
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func insertNewObject(sender: AnyObject) {
        objects.insert("", atIndex: 0)
        saveObject(objects);
        let indexPath = NSIndexPath(forRow: 0, inSection: 0)
        //objects.insert(indexPath, atIndex: 0)
        self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        
        alarmMgr.time.append(nil);
        alarmMgr.alarm_scheduler.append(NSTimer());
        alarmMgr.traffic_scheduler.append(NSTimer());
        alarmMgr.destination.append("");
        alarmMgr.timeOfArrival.append(NSDate());
        alarmMgr.timeCalculated.append(NSDate());
        alarmMgr.bufferTime.append(0);
        alarmMgr.total_delay_time.append(0);
        alarmMgr.total_time_seconds.append(0);
        alarmMgr.name.append("None");
        alarmMgr.avoidTolls.append("true");
        
        if ((objects.count - 1) >= 1){
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
        if ((objects.count - 1) == 0){
            println("empty table");
            addEmptyTableText();
        }
//        let fetchRequest = NSFetchRequest(entityName: "LogItem")
//        fetchRequest.returnsObjectsAsFaults = false
//        var results: NSArray = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil)!;
//        var count = results.count
//        println("initial count is \(results.count)");
        println("object count is \((objects.count - 1))");
//        if (results.count > 0){
//            return results.count
//        } else{
//            return objects.count
//        }
        return (objects.count - 1)
    }

    func updateAlarm() -> Void {
        return DetailViewController().updateAlarm()
    }
    
    func checkAlarm() -> Void {
        return DetailViewController().checkAlarm()
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! UITableViewCell
        println("Cell for row");
        //let object = objects[indexPath.row] as! String
        println("format is \(alarmMgr.name)")
        println("traffic count \(count(alarmMgr.traffic_scheduler)) and index row is \(indexPath.row + 1)");
//        if (count(alarmMgr.traffic_scheduler) - 1 >= (indexPath.row)){
//            //Check for traffic api loop
//            alarmMgr.traffic_scheduler[indexPath.row] = (NSTimer.scheduledTimerWithTimeInterval(300.0, target: self, selector: Selector("updateAlarm"), userInfo: nil, repeats: true))
//        }
//        
//        if (count(alarmMgr.alarm_scheduler) - 1 >= (indexPath.row)){
//            //Check for alarm loop
//            alarmMgr.alarm_scheduler[indexPath.row] = (NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: Selector("checkAlarm"), userInfo: nil, repeats: true))
//
//        }
        
        // clock label
        if let label = cell.viewWithTag(100) as? UILabel {
            var dateFormatter = NSDateFormatter();
            dateFormatter.dateFormat = "hh:mm"
            dateFormatter.timeZone = NSTimeZone.localTimeZone()
            var dateString = dateFormatter.stringFromDate(NSDate());
            label.text = dateString
        }
        
        // AM/PM label
        if let label2 = cell.viewWithTag(101) as? UILabel {
            var dateFormatter2 = NSDateFormatter();
            dateFormatter2.dateFormat = "a"
            var dateString2 = dateFormatter2.stringFromDate(NSDate());
            label2.text = dateString2
        }
        
        // name label
        if let nameField = cell.viewWithTag(102) as? UILabel {
            nameField.text = "None";
        }
        
        cell.textLabel!.text = "";
        
        println("still okay");
        if let array = (alarmMgr.timeOfArrival.count > indexPath.row ? alarmMgr.timeOfArrival[indexPath.row] : nil) as NSDate?{
            var dateFormatter = NSDateFormatter();
            dateFormatter.dateFormat = "hh:mm"
            dateFormatter.timeZone = NSTimeZone.localTimeZone()
            if let dateString = dateFormatter.stringFromDate(alarmMgr.timeOfArrival[indexPath.row]) as? String{
                // clock label
                if let label = cell.viewWithTag(100) as? UILabel {
                    if (alarmMgr.timeOfArrival[indexPath.row] != NSDate()){
                        label.text = dateString
                    } else{
                        var dateString = dateFormatter.stringFromDate(NSDate());
                        label.text = dateString;
                    }
                }
                // AM/PM label
                var dateFormatter2 = NSDateFormatter();
                dateFormatter2.dateFormat = "a"
                var dateString2 = dateFormatter2.stringFromDate(alarmMgr.timeOfArrival[indexPath.row]);
                
                if let label2 = cell.viewWithTag(101) as? UILabel {
                    label2.text = dateString2
                }
                
                // name label
                if let nameField = cell.viewWithTag(102) as? UILabel {
                    if let alarmManager = alarmMgr as? AnyObject {
                        if let name = alarmMgr.name[indexPath.row] as? String{
                            nameField.text = name;
                        } else{
                            nameField.text = "None";
                        }
                    }
                }

            }
        }
        return cell
    }

    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            objects.removeAtIndex(indexPath.row)

            if (count(alarmMgr.time) > indexPath.row){
                alarmMgr.time.removeAtIndex(indexPath.row)
            }
            
            if (count(alarmMgr.name) > indexPath.row){
                alarmMgr.name.removeAtIndex(indexPath.row)
            }
            
            if (count(alarmMgr.alarm_scheduler) > indexPath.row){
                alarmMgr.alarm_scheduler[indexPath.row].invalidate()
                alarmMgr.alarm_scheduler.removeAtIndex(indexPath.row)
            }
        
            if (count(alarmMgr.traffic_scheduler) > indexPath.row){
                alarmMgr.traffic_scheduler[indexPath.row].invalidate()
                alarmMgr.traffic_scheduler.removeAtIndex(indexPath.row)
            }
        
            if (count(alarmMgr.destination) > indexPath.row){
                alarmMgr.destination.removeAtIndex(indexPath.row)
            }
            
            if (count(alarmMgr.timeOfArrival) > indexPath.row){
                alarmMgr.timeOfArrival.removeAtIndex(indexPath.row)
            }
            
            if (count(alarmMgr.timeCalculated) > indexPath.row){
                alarmMgr.timeCalculated.removeAtIndex(indexPath.row)
            }
            
            if (count(alarmMgr.bufferTime) > indexPath.row){
                alarmMgr.bufferTime.removeAtIndex(indexPath.row)
            }
            
            if (count(alarmMgr.avoidTolls) > indexPath.row){
                alarmMgr.avoidTolls.removeAtIndex(indexPath.row)
            }
        
            println("Removed alarm");
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            
            saveObject(objects);
            
            if ((objects.count - 1) < 1){
                self.navigationItem.leftBarButtonItem = nil
                self.navigationItem.leftBarButtonItem?.tintColor = nil
            } else{
//                DetailViewController().deleteAllObjectsForEntityWithName("LogItem");
//                DetailViewController().saveNewItem(alarmMgr);
//                DetailViewController().save();
            }
            
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }


}

