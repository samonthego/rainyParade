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
    var skeltonKey = ""
    var myUrlString:String = ""
    
    
    
    
    @IBOutlet var rainCoatTableView : UITableView!
    
    
    
    
    //!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! end headers !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    //MARK: - Interactivity Methods
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueListToEdit" {
            let indexPath = rainCoatTableView.indexPathForSelectedRow!
            let currentRainCoat = rainCoatArray[indexPath.row]
            let destVC = segue.destination as! MyDetailViewController
            destVC.currentRainCoat = currentRainCoat
            rainCoatTableView.deselectRow(at: indexPath, animated: true)}
    }
    
    //!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    
    //Mark: - TableView Methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int)->Int {
        print("rainCoatArray.count \(rainCoatArray.count)")
        return rainCoatArray.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
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
    
    //MARK: - Dark Sky Methods
    
    func parseJson(data: Data,currentRainCoat: RainCoat){
        print("\(index)")
        
        do {
            let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as! [String:Any]
            print ("JSON:\(jsonResult)")
            if let nestedDictionary = jsonResult["daily"] as? [String: Any] {
                // access nested dictionary values by key
                print("nestedDictionary:\(nestedDictionary)")
                let icon:String = nestedDictionary["icon"] as! String? ?? "none"
                
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
                
                let tempMax = nestedDictionary["temperatureMax"] ?? 0.0
                let tempMin = nestedDictionary["temperatureMin"] ?? 0.0
                let temp = ("\(tempMax),\(tempMin)")
                currentRainCoat.averageTemp = temp

                
                
                
            }
            
            
            
        }catch { print("JSON Parsing Error")}
        DispatchQueue.main.async {
          //  self.temperatureLabel.text = self.weatherText
           // self.weatherImageView.image = UIImage(named: (self.iconImage))
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            
        }
    }
    
    
    
    func getFile(myUrlString:String,myIndex: Int){
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        //let currentRainCoat = rainCoatArray[myIndex]
        let urlString = myUrlString
        let url = URL(string: urlString)!
        var request = URLRequest(url:url)
        request.timeoutInterval = 30
        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        let session = URLSession.shared
        let task = session.dataTask(with: request) { (data, response, error) in
            guard let recvData = data else {
                print("No Data")
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                return
            }
            if recvData.count > 0 && error == nil {
                //print("Got Data:\(recvData)")
                //print("Got Data!")
                let dataString = String.init(data: recvData, encoding: .utf8)
                print("Got Data String:\(String(describing: dataString))")
                self.parseJson(data: recvData, currentRainCoat: self.rainCoatArray[myIndex])
            }else{
                print("Got Data of Length 0")
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        }
        task.resume()
    }
    
    func updateWeather(){
        rainCoatArray = appDelegate.fetchAllRainCoats()
        print("update Weather! \(rainCoatArray.count)")
        for myIndex in 0..<rainCoatArray.count{
            let currentRainCoat = rainCoatArray[myIndex]
            let last = currentRainCoat.lastWeatherUpdate!
            //let now = NSDate
            let elapsed = Date().timeIntervalSince(last as Date)
             print(" elapsed \(elapsed)")
        let lat = currentRainCoat.targetLocLat
        let long = currentRainCoat.targetLocLong
        myUrlString = hostName + "forecast/" + skeltonKey + "/"+lat!+","+long!
        
        
        }
    }
    
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
    
    
    //MARK: - PLIST Methods
    
    func getSkeltonKey()-> String {
        var DSKey = ""
        if let file = Bundle.main.path(forResource: "dsdata", ofType: "plist"), let dict = NSDictionary(contentsOfFile: file) as? [String: AnyObject]{
            DSKey = (dict["DarkSkyAPISecretKey"] as? String)!
        }
        return DSKey
    }
    
//!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    
    
    
    //MARK: - Life Cycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        managedContext = appDelegate.persistentContainer.viewContext
        
        skeltonKey = getSkeltonKey()
        updateWeather()
        print("ok")
        setupReachability(hostName: hostName)
        startReachability()
    }
    /*

        setupLocationMonitoring()
        
        lat  = (locationMgr.location?.coordinate.latitude)!
        long = (locationMgr.location?.coordinate.longitude)!
        myUrlString = hostName + "forecast/" + skeltonKey + "/" + String(lat) + "," + String(long)
        print("  lat & long  \(lat) \(long)")
        getFile(myUrlString: myUrlString)

    }
    */
    
    
    
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
    }
    
    
}

class myTableViewCell: UITableViewCell{

    @IBOutlet weak var myLocationName :UILabel!
    @IBOutlet weak var myTargetDate   :UILabel!
    @IBOutlet weak var myThirdLine    :UILabel!
    @IBOutlet weak var myImageView    :UIImageView!
    
}


