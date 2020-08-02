//
//  HomeScreenInteractor.swift
//  elementsWeather
//
//  Created by Andrey Posnov on 30.07.2020.
//  Copyright © 2020 Andrey Posnov. All rights reserved.
//

import Foundation
import Alamofire

class HomeScreenInteractor {
    
    func mergeAndSortCitiesWeather(data: [WeatherModel]) -> [WeatherViewModel] {
        var result: [WeatherViewModel] = []
        var iterator = 0
        
        for city in data {
            if result.contains(where: { $0.cityName == city.city?.name }) { // check if already have this city
                if let foundedCityIndex = result.firstIndex(where: { $0.cityName == city.city?.name }) {
                    result[foundedCityIndex].temps?.append(CityTemp(date: self.convertDateToDaytime(dateString: city.date ?? ""),
                                                                    temp: self.convertToCelcius(temptType: city.tempType ?? "",
                                                                              temp: city.temp ?? 0.0)))
                }
            } else { // add city if not found yet
                var cityTempsArray: [CityTemp] = []
                let cityTemp = CityTemp(date: self.convertDateToDaytime(dateString: city.date ?? ""),
                                        temp: self.convertToCelcius(temptType: city.tempType ?? "",
                                                               temp: city.temp ?? 0.0))
                cityTempsArray.append(cityTemp)
                result.append(WeatherViewModel(cityId: iterator, cityName: city.city?.name,
                                               cityPicture: city.city?.picture,
                                               temps: cityTempsArray))
                iterator += 1
            }
        }
        
        //sorting cities by alphabet
       result = result.sorted { $0.cityName ?? "" < $1.cityName ?? "" }
        
        // sorting date
        for i in 0..<result.count {
            //result[i].temps = result[i].temps?.sorted(by: { ($0.date ?? "").compare($1.date ?? "") == .orderedAscending })
            result[i].temps = result[i].temps?.sorted { $0.date?.order ?? 0 < $1.date?.order  ?? 0}
        }
        
        
       return result
    }
    
    private func convertToCelcius(temptType: String, temp: Float) -> Float {
        switch temptType {
        case "K":
            return temp - 273.15
        case "F":
            return (temp - 32) / 1.8
        default:
            return temp
        }
    }
    
    private func convertDateToDaytime(dateString: String) -> WeatherDate {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss+00:00"
        let date = dateFormatter.date(from: dateString)
        let hour = Calendar.current.component(.hour, from: date ?? Date())
        let minutes = Calendar.current.component(.minute, from: date ?? Date())
        switch hour {
        case 6..<12 : return WeatherDate(order: 0, dayTime: "\(hour):\(minutes)0 Morning", dateOrigin: dateString)
        case 12 : return WeatherDate(order: 1, dayTime: "\(hour):\(minutes)0 Noon", dateOrigin: dateString)
        case 13...17: return WeatherDate(order: 2, dayTime: "\(hour):\(minutes)0 Day", dateOrigin: dateString)
        case 17...23: return WeatherDate(order: 3, dayTime: "\(hour):\(minutes)0 Evening", dateOrigin: dateString)
        default: return WeatherDate(order: 4, dayTime: "\(hour):\(minutes)0 Night", dateOrigin: dateString)
        }
    }

}
