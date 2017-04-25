
//
//  MyDetailViewController.swift
//  RainyParade
//
//  Created by Samuel MCDONALD on 1/24/17.
//  Copyright © 2017 Samuel MCDONALD. All rights reserved.
//

import UIKit
import CoreData

class MyDetailViewController: UIViewController {
    @IBOutlet var saveButton                :UIBarButtonItem!
    @IBOutlet var cancelButton              :UIBarButtonItem!
    @IBOutlet var myLocationNameTextField   :UITextField!
    @IBOutlet var targetLocLatTextField     :UITextField!
    @IBOutlet var targetLocLongTextField    :UITextField!
    @IBOutlet var mapButton                 :UIButton!
    @IBOutlet var targetTimeStartPicker     :UIDatePicker!
    @IBOutlet var myTargetHourDuration      :UILabel!
    @IBOutlet var durationStepper           :UIStepper!
    
    var currentRainCoat :RainCoat?
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var managedContext :NSManagedObjectContext!
    let dateFormatter = DateFormatter()
    //dateFormatter.dateFormat = "yyyy/MM/dd"
    //let dateString = dateFormatter.string(from: date)
    
    
    
    
    //MARK: - Core Methods
    
    func display(rainCoat: RainCoat) {
        print ("in display")
        myLocationNameTextField.text = rainCoat.myLocationName
        print("rainCoat.myLocationName \(String(describing: rainCoat.myLocationName))")
        targetLocLatTextField.text = rainCoat.targetLocLat
        targetLocLongTextField.text = rainCoat.targetLocLong
        myTargetHourDuration.text = "\(rainCoat.targetHourDuration) Hours"
        targetTimeStartPicker.date = rainCoat.targetTimeStart! as Date
        
    }
    
    func setRainCoatValues(rainCoat: RainCoat) {
        print (" working set Values")
        if let _ = currentRainCoat {
            rainCoat.dateModified = NSDate()
            
        }else{
            rainCoat.dateCreated = NSDate()
            rainCoat.dateModified = NSDate()
            rainCoat.lastWeatherUpdate = NSDate()
            rainCoat.averageTemp = " -- "
            rainCoat.chancePercipitation = "0.00%"
            rainCoat.weatherIcon = "weathercock.png" as String
            rainCoat.targetHourDuration = 1
            rainCoat.myLocationName = myLocationNameTextField.text ?? "Fort Mackinaw"
            rainCoat.targetLocLat = targetLocLatTextField.text ?? "45.851803"
            rainCoat.targetLocLong =  targetLocLongTextField.text ?? "84.616937"
            rainCoat.targetTimeStart = targetTimeStartPicker.date as NSDate
            rainCoat.chancePercipitation = " -- "
        }
        print (" \(String(describing: rainCoat.dateCreated))")
    }
    
    func createRainCoat(){
        
        let newRainCoat = NSEntityDescription.insertNewObject(forEntityName: "RainCoat", into: managedContext) as! RainCoat
        setRainCoatValues(rainCoat: newRainCoat)
        appDelegate.saveContext()
        
    }
    
    
    func editRainCoat(rainCoat: RainCoat) {
        setRainCoatValues(rainCoat: rainCoat)
        appDelegate.saveContext()
    }
    
    //Mark: - interactivity methods
    
    @IBAction func savePressed(button: UIBarButtonItem!) {
        if button == saveButton {
            if let rainCoat = currentRainCoat{
                editRainCoat(rainCoat: rainCoat)
            } else {
                createRainCoat()
            }
        }
        self.navigationController!.popViewController(animated: true)
    }
    
    
    @IBAction func valueChanged(stepper: UIStepper){
        var dtime = Int16(stepper.value)
        dtime = currentRainCoat?.targetHourDuration ?? 1
        print("stepper is  \(String(describing: currentRainCoat?.targetHourDuration))  \(dtime)")
        if dtime < 10 { dtime = dtime + 1}
        currentRainCoat?.targetHourDuration = dtime
        
    }
    
    
        
    //MARK: - Life Cycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        managedContext = appDelegate.persistentContainer.viewContext
        if let rainCoat = currentRainCoat{
            display(rainCoat: rainCoat)
        }else{
        
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}






