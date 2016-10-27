//
//  DataManager.swift
//  WeatherApp
//
//  Created by Robert Haworth on 10/26/16.
//  Copyright © 2016 Robert Haworth. All rights reserved.
//

import UIKit
import CoreData

// TODO: Handle several error cases involved with CoreData
// MARK: -

class DataManager {

    // MARK: - Core Data stack
    
    private var locationsArray:[Location] = []
    
    static let sharedInstance = {
        return DataManager()
    }()
    
    private init() {
        loadLocationsArray()
    }
    
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "WeatherApp")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    // MARK: - Location convenience functions
    
    func location(queryString:String) -> Location? {
        return locationsArray.filter({return $0.queryString == queryString}).first
    }
    
    func location(name:String) -> Location? {
        return locationsArray.filter({return $0.name == name}).first
    }
    
    func currentLocation() -> Location? {
        return locationsArray.filter({ return $0.name == "Current Location"}).first
    }
    
    func allLocations() -> [Location] {
        return locationsArray
    }
    
    private func locations(predicate:NSPredicate?) -> [Location]? {
        let fetchRequest: NSFetchRequest<Location> = NSFetchRequest(entityName: "Location")
        fetchRequest.predicate = predicate
        do {
            let locations = try persistentContainer.viewContext.fetch(fetchRequest)
            return locations
            
        } catch {
            print("Please handle this catch with some kind of action.")
            return nil
        }
    }
    
    // MARK: - Location Delete/Create Methods
    
    func newLocation(queryString:String, name:String) {
        let location = Location(context: persistentContainer.viewContext)
        location.name = name
        location.queryString = queryString
        locationsArray.append(location)
        saveContext()
    }
    
    func delete(location:Location) {
        locationsArray = locationsArray.filter { return $0 != location}
        persistentContainer.viewContext.delete(location)
        saveContext()
    }
    
    // MARK: - LocationsArray creation population function
    
    private func loadLocationsArray() {
        if let unwrappedLocations = locations(predicate:nil) {
                locationsArray = unwrappedLocations
        }
    }
}
