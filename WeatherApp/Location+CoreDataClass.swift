//
//  Location+CoreDataClass.swift
//  
//
//  Created by Robert Haworth on 10/26/16.
//
//

import Foundation
import CoreLocation
import CoreData


public class Location: NSManagedObject {
    
    var weather:Weather?
    
    func getWeather(completionBlock:(() ->())?) {
        
        
        // If lat and long are not defaulted, use this as it is nearly guarunteed to be more accurate.
        if latitude != 0 && longitude != 0 {
            WeatherService.sharedInstance.weatherReport(coordinates: CLLocation(latitude: latitude, longitude: longitude)) { [weak self] returnedWeather in
                self?.weather = returnedWeather
                completionBlock?()
            }
        } else {
            guard let queryString = queryString else {
                print("no query string found, no way to query API")
                return
            }
            WeatherService.sharedInstance.weatherReport(searchString: queryString) {[weak self] returnedWeather in
                self?.weather = returnedWeather
                completionBlock?()
            }
        }
    }
}
