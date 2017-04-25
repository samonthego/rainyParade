//
//  RainCoat.swift
//  RainyParade
//
//  Created by Samuel MCDONALD on 4/11/17.
//  Copyright © 2017 Samuel MCDONALD. All rights reserved.
//

import UIKit

class RainCoat: NSObject {
    
    var myLocationName = String()
    var dateCreated  = Date()
    var dateModified = Date()
    var targetTimeStart = Date()
    var targetHourDuration   = Int16()
    var targetLocLat = String()
    var targetLocLong = String()
    var lastWeatherUpdate = Date()
    var chancePercipitation = String()
    var averageTemp = String()
    var weatherIcon = String()
    
    func aveTempCalc(){
        print("average temp calculator for more than 1 hour at a spot.")
    }
    
}
