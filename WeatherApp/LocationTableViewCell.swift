//
//  LocationTableViewCell.swift
//  WeatherApp
//
//  Created by Robert Haworth on 10/26/16.
//  Copyright © 2016 Robert Haworth. All rights reserved.
//

import UIKit

class LocationTableViewCell: UITableViewCell {

    @IBOutlet var locationNameLabel: UILabel!
    @IBOutlet var locationQueryNameLabel: UILabel!
    @IBOutlet var weatherLocationNameLabel: UILabel!
    @IBOutlet var weatherTemperatureLabel: UILabel!
    @IBOutlet var weatherHumidityLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
}
