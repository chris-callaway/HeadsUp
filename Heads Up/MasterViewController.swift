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

    var index: Int?
    
    @IBOutlet weak var alarmSwitch: UISwitch!
    
    @IBAction func alarmSwitchChanged(sender: AnyObject) {
        
        if (alarmSwitch.on){
            var text = alarmMgr.time[0];
            println("ON \(index)");
            alarmMgr.alarm_scheduler[0]!.invalidate()
            alarmMgr.traffic_scheduler[0]!.invalidate()
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

    override func awakeFromNib() {
        super.awakeFromNib()
        tableView.delegate = self
        tableView.dataSource = self
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
        alarmMgr.avoidTolls.append("true");
        
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
            
            if ((alarmMgr.avoidTolls[indexPath.row]) != nil){
                alarmMgr.avoidTolls.removeAtIndex(indexPath.row)
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

