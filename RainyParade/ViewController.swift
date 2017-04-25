//
//  ViewController.swift
//  RainyParade
//
//  Created by Samuel MCDONALD on 4/11/17.
//  Copyright © 2017 Samuel MCDONALD. All rights reserved.
//

import UIKit
import CoreData


class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var managedContext :NSManagedObjectContext!
    var rainCoatArray = [RainCoat]()
    var iconImage = "weathercock.png"
    let dateFormatter = DateFormatter()
    
    // for Reachability methods
    
    let hostName = "https://api.darksky.net/"
    var reachability : Reachability?
    
    
    
    
    @IBOutlet var rainCoatTableView : UITableView!
    
    
    //MARK: - Interactivity MEthods
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueListToEdit" {
            let indexPath = rainCoatTableView.indexPathForSelectedRow!
            let currentRainCoat = rainCoatArray[indexPath.row]
            let destVC = segue.destination as! MyDetailViewController
            destVC.currentRainCoat = currentRainCoat
            rainCoatTableView.deselectRow(at: indexPath, animated: true)}
    }
    
    //Mark: - TableView Methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int)->Int {
        print("rainCoatArray.count \(rainCoatArray.count)")
        return rainCoatArray.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
         print("in cellForRowAt")
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! myTableViewCell
        let currentRainCoat = rainCoatArray[indexPath.row]
        cell.myLocationName.text = ( currentRainCoat.myLocationName!)  //+ "  \(currentRainCoat.averageTemp!)")
        dateFormatter.dateFormat = "MM/dd/yyyy"
        let dateString = dateFormatter.string(from: currentRainCoat.targetTimeStart! as Date)
        cell.myTargetDate.text = (" \(dateString)")
        let icon = currentRainCoat.weatherIcon ?? "weathercock.png"
        switch icon {
        case "clear-day":
            iconImage = "sun.png"
        case "clear-night":
            iconImage = "moon.png"
        case "rain":
            iconImage = "rain.png"
        case "snow":
            iconImage = "snow.png"
        case "sleet":
            iconImage = "rain-6.png"
        case "wind":
            iconImage = "wind.png"
        case "fog":
            iconImage = "haze-3.png"
        case "cloudy":
            iconImage = "cloud.png"
        case "partly-cloudy-day":
            iconImage = "cloudy.png"
        case "partly-cloudy-night":
            iconImage = "cloudy-1.png"
        default:
            iconImage = "weathercock.png"
        }
        if currentRainCoat.weatherIcon == "weathercock.png"{
           cell.myImageView.image = UIImage(named: (self.iconImage))
        }
        cell.myThirdLine.text = " Temp: \(currentRainCoat.averageTemp!)  Precipitation: \(currentRainCoat.chancePercipitation!)"
        //cell.textLabel!.text = currentRainCoat.myLocationName! + " " + currentRainCoat.averageTemp!
        //cell.myTargetDate!.text = ("\(String(describing: currentRainCoat.targetTimeStart))")
        //cell.detailTextLabel!.text = ("\(currentRainCoat.targetHourDuration)")
       
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            let rainCoatToDelete = rainCoatArray[indexPath.row]
            managedContext.delete(rainCoatToDelete)
            appDelegate.saveContext()
            rainCoatArray = appDelegate.fetchAllRainCoats()
            rainCoatTableView.deleteRows(at: [indexPath], with: .automatic)
            tableView.isEditing = false
        }
    }
    
///////////////////////////////////////   end table view //////////////
    
    //!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    
    //MARK: - Reachability Methods
    
    func setupReachability(hostName: String)  {
        reachability = Reachability(hostname: hostName)
        reachability!.whenReachable = { reachability in
            DispatchQueue.main.async {
                self.updateLabel(reachable: true, reachability: reachability)
            }
            
        }
        reachability!.whenUnreachable = {reachability in
            self.updateLabel(reachable: false, reachability: reachability)        }
    }
    
    func startReachability() {
        do{
            try reachability!.startNotifier()
        }catch{
            //            networkStatusLabel.text = "Unable to Start Notifier"
            //            networkStatusLabel.textColor = .red
            print("Unable to Start Notifier!")
            return
        }
    }
    
    func updateLabel(reachable: Bool, reachability: Reachability){
        if reachable {
            if reachability.isReachableViaWiFi{
                //                networkStatusLabel.textColor = .green
                print("WiFi is available.")
            }else {
                //                networkStatusLabel.textColor = .blue
                print("Cellular data is being used")
            }
        }else{
            //            networkStatusLabel.textColor = .red
            print("No Network Available")
        }
        //        networkStatusLabel.text = reachability.currentReachabilityString
        print("     /(reachability.currentReachabilityString)")
    }
    
    // END Reachability Methods
    //!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    
    
    //MARK: - Life Cycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        managedContext = appDelegate.persistentContainer.viewContext        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        rainCoatArray = appDelegate.fetchAllRainCoats()
        print("Count \(rainCoatArray.count)")
        
      /*  print("    0 \(rainCoatArray[0].myLocationName!)")
         
        print("    1 \(rainCoatArray[1].myLocationName!)")
        print("    2 \(rainCoatArray[2].myLocationName!)")
        let rainCoatToDelete = rainCoatArray[0]
        managedContext.delete(rainCoatToDelete)
        appDelegate.saveContext() */
 
        rainCoatTableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

class myTableViewCell: UITableViewCell{

    @IBOutlet weak var myLocationName :UILabel!
    @IBOutlet weak var myTargetDate   :UILabel!
    @IBOutlet weak var myThirdLine    :UILabel!
    @IBOutlet weak var myImageView    :UIImageView!
    
}


