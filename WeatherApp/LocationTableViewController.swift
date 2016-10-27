//
//  LocationViewController.swift
//  WeatherApp
//
//  Created by Robert Haworth on 10/25/16.
//  Copyright © 2016 Robert Haworth. All rights reserved.
//

import UIKit
import MapKit

class LocationTableViewController: UITableViewController, UISearchResultsUpdating, MKLocalSearchCompleterDelegate, UISearchControllerDelegate {
    
    var searchController:UISearchController!
    
    let mapKitLocalSearchCompleter = MKLocalSearchCompleter()
    
    let locationSearchCellIdentifier = "LocationSearchCell"
    let locationCellIdentifier = "LocationCell"
    
    let locationManager = CoreLocationManager()
    
    var updateTimer:Timer?

    var userSearchArray:Array<MKLocalSearchCompletion> = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        searchController = UISearchController(searchResultsController: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Attempt request to receive Current Location's coordinates.
        locationManager.requestLocationAuthorization()

        
        tableView.tableHeaderView = searchController.searchBar
        definesPresentationContext = true
        
        // Configure UISearchController
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.delegate = self
        
        mapKitLocalSearchCompleter.delegate = self
        
        updateLocations()
        
        
        updateTimer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: true) { [weak self] timer in
            if !((self?.searchController.isActive)!) {
                self?.updateLocations()
            }
        }
        
        
        // Do any additional setup after loading the view.
    }
    
    // MARK: - MKLocalSearchCompleterDelegate functions
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        userSearchArray = completer.results
    }
    
    // MARK: - UISearchResultsUpdating functions
    
    
    // As the user modifies the searchText in the searchBar, feed updates to the mapKitLocalSearchCompleter to refine/modify userSearchArray
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text else {
            return
        }
        
        mapKitLocalSearchCompleter.queryFragment = searchText
    }
    
    // Prompt for tableView to clear it's current configuration.
    // MARK: - UISearchControllerDelegate functions
    
    func willDismissSearchController(_ searchController: UISearchController) {
        userSearchArray = []
    }
    
    func didDismissSearchController(_ searchController: UISearchController) {
        tableView.reloadData()
        updateLocations()
    }
    
    func didPresentSearchController(_ searchController: UISearchController) {
        tableView.reloadData()
    }
    
    // MARK: - TableViewDelegate functions

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if searchController.isActive {
            let mapKitObject = userSearchArray[indexPath.row]
            let test = DataManager.sharedInstance.location(queryString: mapKitObject.subtitle)
            
            if test == nil {
                DataManager.sharedInstance.newLocation(queryString: mapKitObject.subtitle, name: mapKitObject.title)
            }
            
            searchController.isActive = false
            tableView.reloadData()
            
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if searchController.isActive {
            return 44.0
        }
        
        return 100.0
    }
    
    // MARK: - TableViewDataSource functions
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.isActive {
            return userSearchArray.count
        }
        
        return DataManager.sharedInstance.allLocations().count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell:UITableViewCell
        if searchController.isActive {
            cell = tableView.dequeueReusableCell(withIdentifier: locationSearchCellIdentifier, for: indexPath)
            
            let completionData = userSearchArray[indexPath.row]
            
            
            cell.textLabel?.text = completionData.title
            cell.detailTextLabel?.text = completionData.subtitle
        } else {
            let locationCell = tableView.dequeueReusableCell(withIdentifier: locationCellIdentifier, for: indexPath) as! LocationTableViewCell
            let location = DataManager.sharedInstance.allLocations()[indexPath.row]

            locationCell.locationNameLabel.text = location.name
            locationCell.locationQueryNameLabel.text = location.queryString
            if let weather = location.weather {
                    locationCell.weatherLocationNameLabel.text = weather.cityName()
                if let temperature = weather.currentTemp(), let humidity = weather.currentHumidity() {
                    locationCell.weatherTemperatureLabel.text = String(format:"%.2f F", temperature)
                    locationCell.weatherHumidityLabel.text = String(format:"%.0f", humidity) + " %"
                }
            }
        
            locationCell.selectionStyle = .none
            cell = locationCell
        }
        
        return cell
    }
    
    // MARK: - Editing tableView functions
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if searchController.isActive {
            return false
        } else {
             return true
        }
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let location = DataManager.sharedInstance.allLocations()[indexPath.row]
            DataManager.sharedInstance.delete(location: location)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    // MARK: - Update Locations weather data
    
    func updateLocations() {
        for (index, location) in DataManager.sharedInstance.allLocations().enumerated() {
            location.getWeather(completionBlock: { [weak self] in
                
                guard let selfie = self else {
                    print("self was destroyed")
                    return
                }
                if selfie.tableView.isEditing {
                    return
                }
                if !(Thread.isMainThread) {
                    DispatchQueue.main.async {
                        selfie.tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
                    }
                } else {
                    selfie.tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
                }
                })
        }
    }
}
