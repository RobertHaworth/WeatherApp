//
//  WeatherViewController.swift
//  
//
//  Created by Robert Haworth on 10/24/16.
//
//

import UIKit
import CoreLocation

class WeatherViewController: UIViewController, UITextFieldDelegate, CLLocationManagerDelegate {
    
    @IBOutlet var inputTextField: UITextField!
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        inputTextField.becomeFirstResponder()
        locationManager.delegate = self
        
        // Do any additional setup after loading the view.
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Fire search
        if let possibleSearchString = textField.text {
            attemptServiceCall(searchString: possibleSearchString)
        } else {
            let alertController = UIAlertController(title: "Parse Error", message: "Unable to reach possible search parameter", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
            present(alertController, animated: true, completion: nil)
        }
        
        inputTextField.resignFirstResponder()
        return true
    }
    
    func attemptServiceCall(searchString:String) {
        guard let possibleZipCode = Int(searchString) else {
            WeatherService.sharedInstance.weatherReport(cityName: searchString)
            return
        }
        
        WeatherService.sharedInstance.weatherReport(zipCode: possibleZipCode)

    }
    @IBAction func didActivatePanningGesture(_ sender: UIPanGestureRecognizer) {
        inputTextField.resignFirstResponder()
    }
    
    func requestLocationAuthorization() {
        print("requesting location access")
        switch CLLocationManager.authorizationStatus() {
            case .denied, .notDetermined, .restricted: locationManager.requestWhenInUseAuthorization()
            case .authorizedAlways, .authorizedWhenInUse: requestLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print("location manager did change auth \(status.rawValue)")
        switch status {
            case .authorizedWhenInUse, .authorizedAlways: requestLocation()
            default: print("what should I do if the user denies access?")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("location did update")
        guard let location = locations.first else {
            print("location not returned, but updated. Should not occur")
            return
        }
        print("location found \(location.coordinate.latitude) \(location.coordinate.longitude)")
        WeatherService.sharedInstance.lastLocation = location
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        let alert = UIAlertController(title: "Core Location Error", message: "\(error.localizedDescription)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func requestLocation() {
        locationManager.requestLocation()
    }
}
