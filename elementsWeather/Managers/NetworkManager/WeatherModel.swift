//
//  WeatherModel.swift
//  elementsWeather
//
//  Created by Andrey Posnov on 29.07.2020.
//  Copyright © 2020 Andrey Posnov. All rights reserved.
//

import Foundation

struct WeatherModel: Codable {
    let date: String?
    let city: CityModel?
    let tempType: String?
    let temp: Float?
}

struct CityModel: Codable {
    let name: String?
    let picture: String?
}
