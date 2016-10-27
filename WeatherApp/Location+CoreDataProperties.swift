//
//  Location+CoreDataProperties.swift
//  WeatherApp
//
//  Created by Robert Haworth on 10/27/16.
//  Copyright © 2016 Robert Haworth. All rights reserved.
//

import Foundation
import CoreData


extension Location {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Location> {
        return NSFetchRequest<Location>(entityName: "Location");
    }

    @NSManaged public var queryString: String?
    @NSManaged public var name: String?
    @NSManaged public var longitude: Double
    @NSManaged public var latitude: Double

}
