//
//  WeatherService.swift
//  WeatherApp
//
//  Created by Robert Haworth on 10/23/16.
//  Copyright © 2016 Robert Haworth. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire

enum UnitType {
    case imperial, metric, standard
    
    func description() -> String {
        switch self {
            case .imperial: return "imperial"
            case .metric: return "metric"
            case .standard: return "standard"
        }
    }
}



class WeatherService {
    
    let serverURL = "http://api.openweathermap.org/data/2.5/weather"
    let apiKey = "4b73d40aee97a52f070e6e24dda1e776"
    let countryCode = "us"
    var currentUnitType = UnitType.imperial.description()
    var currentWeather:Weather? {
        didSet {
            print("Current weather set: \(currentWeather?.description())")
        }
    }
    
    // Using this to guard against finding too many locations at once.
    var lastLocation:CLLocation? {
        didSet {
            guard let unwrappedOldValue = oldValue else {
                print("")
                return
            }
            if let newValue = lastLocation {
                if unwrappedOldValue.distance(from: newValue) > 20 {
                    WeatherService.sharedInstance.weatherReport(coordinates: newValue)
                }
            }
        }
    }
    
    
    // API routes
    
    //?zip=94040
    
    
    static let sharedInstance: WeatherService = {
        return WeatherService()
    }()
    
    
    // Use this function to add on extra parameters to all calls.
    func prependedOptions() -> String {
        return "&units=\(currentUnitType)&APPID=\(apiKey)"
    }
    
    func weatherReport(zipCode:Int) {
        Alamofire.request(serverURL + "?zip=\(zipCode),\(countryCode)" + prependedOptions(), method: .get, parameters: nil, encoding: JSONEncoding(options:.prettyPrinted), headers: nil).validate().responseJSON { [weak self] response in
            switch response.result {
                case .success(let jsonData as Dictionary<String, AnyObject>):
                    self?.currentWeather = Weather(jsonPayload: jsonData)
                case .success(let value):
                    print("success without being a JSON dictionary? \(value)")
                case .failure(let responseError): print("jsonError zipCode: \(responseError)")
            }
        }
    }
    
    func weatherReport(cityName:String) {
        
        let sanitizedString = cityName.replacingOccurrences(of: " ", with: "%20")
        
        Alamofire.request(serverURL + "?q='\(sanitizedString)',\(countryCode)&APPID=\(apiKey)" + prependedOptions(), method: .get, parameters: nil, encoding: JSONEncoding(options:.prettyPrinted), headers: nil).validate().responseJSON { [weak self] response in
            switch response.result {
                case .success(let jsonData as Dictionary<String, AnyObject>):
                    self?.currentWeather = Weather(jsonPayload: jsonData)
                case .success(let value):
                    print("success without being a JSON dictionary? \(value)")
                case .failure(let responseError): print("jsonError cityName: \(responseError)")
            }
        }
    }
    
    func weatherReport(coordinates:CLLocation) {
        Alamofire.request(serverURL + "?lat=\(coordinates.coordinate.latitude)&lon=\(coordinates.coordinate.longitude)&APPID=\(apiKey)" + prependedOptions(), method: .get, parameters: nil, encoding: JSONEncoding(options:.prettyPrinted), headers: nil).validate().responseJSON {[weak self] response in
            switch response.result {
                case .success(let jsonData as Dictionary<String, AnyObject>):
                    self?.currentWeather = Weather(jsonPayload: jsonData)
                case .success(let value):
                    print("success without being a JSON dictionary? \(value)")
                case .failure(let responseError): print("jsonError coordinates: \(responseError)")
            }
        }
    }
}
