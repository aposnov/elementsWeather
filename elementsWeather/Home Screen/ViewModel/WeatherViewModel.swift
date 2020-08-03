//
//  WeatherViewModel.swift
//  elementsWeather
//
//  Created by Andrey Posnov on 30.07.2020.
//  Copyright © 2020 Andrey Posnov. All rights reserved.
//

import UIKit

struct WeatherViewModel {
    let cityId: Int
    let cityName: String?
    let cityPicture: String?
    let cityPictureImg: UIImage?
    var temps: [CityTemp]?
}

struct CityTemp {
    var date: WeatherDate?
    var temp: Float?
}

struct WeatherDate {
    let order: Int?
    let dayTime: String?
    let dateOrigin: String?
}
