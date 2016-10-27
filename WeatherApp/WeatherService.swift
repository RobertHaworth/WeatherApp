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


// TODO: - Expand user options with settings screen, allow user to choose UnitType, countryCode.
// MARK: -

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

    static let sharedInstance: WeatherService = {
        return WeatherService()
    }()
    
    
    // Use this function to add on extra parameters to all calls.
    func prependedOptions() -> String {
        return "&units=\(currentUnitType)&APPID=\(apiKey)"
    }
    
    func weatherReport(searchString:String, completionBlock:@escaping (Weather?) -> ()) {
        
        let sanitizedString = searchString.replacingOccurrences(of: " ", with: "%20")
        
        Alamofire.request(serverURL + "?q='\(sanitizedString)',\(countryCode)" + prependedOptions(), method: .get, parameters: nil, encoding: JSONEncoding(options:.prettyPrinted), headers: nil).validate().responseJSON { response in
            switch response.result {
                case .success(let jsonData as Dictionary<String, AnyObject>):
                    completionBlock(Weather(jsonPayload: jsonData))
                case .success(let value):
                    print("success without being a JSON dictionary? \(value)")
                case .failure(let responseError): print("jsonError searchString: \(responseError)")
            }
        }
    }
    
    func weatherReport(coordinates:CLLocation, completionBlock:@escaping (Weather?) -> ()) {
        Alamofire.request(serverURL + "?lat=\(coordinates.coordinate.latitude)&lon=\(coordinates.coordinate.longitude)" + prependedOptions(), method: .get, parameters: nil, encoding: JSONEncoding(options:.prettyPrinted), headers: nil).validate().responseJSON { response in
            switch response.result {
                case .success(let jsonData as Dictionary<String, AnyObject>):
                    completionBlock(Weather(jsonPayload: jsonData))
                case .success(let value):
                    print("success without being a JSON dictionary? \(value)")
                case .failure(let responseError): print("jsonError coordinates: \(responseError)")
            }
        }
    }
}
