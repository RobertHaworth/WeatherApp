//
//  Weather.swift
//  WeatherApp
//
//  Created by Robert Haworth on 10/24/16.
//  Copyright © 2016 Robert Haworth. All rights reserved.
//

import UIKit

// TODO: - Add more enumerations to describe data states better for Weather
// MARK: -

class Weather {
    
    private let jsonObject:Dictionary<String, AnyObject>
    
    private init() {
        jsonObject = [:]
    }
    
    init(jsonPayload:Dictionary<String, AnyObject>) {
        jsonObject = jsonPayload
    }

    func cityName() -> String {
        guard let name = jsonObject["name"] as? String else {
            return "Unknown"
        }
        
        return name
    }
    
    func currentTemp() -> Double? {
        guard let currentTemp = mainStructure()["temp"] as? Double else {
            return nil
        }
        
        return currentTemp
    }
    
    func currentHumidity() -> Double? {
        guard let currentHumidity = mainStructure()["humidity"] as? Double else {
            return nil
        }
        
        return currentHumidity
    }
    
    // Helper function to unwrap main structure dictionary
    func mainStructure() -> Dictionary<String, AnyObject> {
        guard let mainDictionary = jsonObject["main"] as? Dictionary<String, AnyObject> else {
            return [:]
        }
        
        return mainDictionary
    }
    
    func description() {
        print(jsonObject)
    }
}
