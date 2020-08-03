//
//  HomeScreenInteractor.swift
//  elementsWeather
//
//  Created by Andrey Posnov on 30.07.2020.
//  Copyright © 2020 Andrey Posnov. All rights reserved.
//

import Foundation
import Alamofire
import SystemConfiguration
import CoreData

let imageCache = NSCache<NSString, UIImage>()

class HomeScreenInteractor {
    
    // Get weather if we have internet load from internet, if not, load from database
    func getActualWeather(completion: @escaping ([WeatherViewModel]?) -> Void) {
        if isConnectedToNetwork() {
            self.getWeatherFromInternet() { weather in
                completion(weather)
            }
        } else {
           completion(self.getWeatherFromDatabase())
        }
    }
    
    // Save weather to database
    private func saveWeatherToDatabse(data: [WeatherViewModel]?) {
        guard let data = data else { return }
        self.clearDatabase()
        for newWeather in data {
            let weatherModelDb = WeatherModelDb(context: CoreDataManager.context)
            for temp in newWeather.temps ?? [] {
                let cityTempDb = CityTempDb(context: CoreDataManager.context)
                let weatherDateDb = WeatherDateDb(context: CoreDataManager.context)
                weatherDateDb.dateOrigin = temp.date?.dateOrigin
                weatherDateDb.dayTime = temp.date?.dayTime
                weatherDateDb.order = Int32(temp.date?.order ?? 0)
                cityTempDb.temp = temp.temp ?? 0.0
                cityTempDb.relationship = weatherDateDb
                weatherModelDb.addToRelationship(cityTempDb)
            }
            
            weatherModelDb.cityId = Int32(newWeather.cityId)
            weatherModelDb.cityName = newWeather.cityName
            weatherModelDb.cityPicture = newWeather.cityPicture
            weatherModelDb.cityPictureImg = UIImage(named: "nopicture")?.pngData()
            self.imageFromURLstored(urlString: newWeather.cityPicture ?? "") { picture in
                guard let picture = picture else { return }
                weatherModelDb.cityPictureImg = picture.pngData()
            }
        }
        
        CoreDataManager.saveContext()
    }
    
    // Load weather to database
    private func getWeatherFromDatabase() -> [WeatherViewModel]? {
        var result: [WeatherViewModel] = []
        let fetchRequestWeatherModel: NSFetchRequest<WeatherModelDb> = WeatherModelDb.fetchRequest()
        do {
            let weatherFromDb = try CoreDataManager.context.fetch(fetchRequestWeatherModel)
         
            for weather in weatherFromDb {
                var tempsArray: [CityTemp] = []
                let weatherTemps = weather.relationship?.allObjects as! [CityTempDb]
                for temp in weatherTemps {
                    let weatherDate = WeatherDate(order: Int(temp.relationship?.order ?? 0),
                                                  dayTime: temp.relationship?.dayTime,
                                                  dateOrigin: temp.relationship?.dateOrigin)
                    tempsArray.append(CityTemp(date: weatherDate, temp: temp.temp))
                }
               
                let weather = WeatherViewModel(cityId: Int(weather.cityId),
                                               cityName: weather.cityName,
                                               cityPicture: weather.cityPicture,
                                               cityPictureImg: UIImage(data: weather.cityPictureImg ?? Data()),
                                               temps: tempsArray)
                result.append(weather)
            }
           return result
        } catch {
            debugPrint("core data error \(error.localizedDescription)")
        }
        return result
    }
    
    // Clear Database
    func clearDatabase() {
        let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "WeatherModelDb")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
        
        let deleteFetch2 = NSFetchRequest<NSFetchRequestResult>(entityName: "WeatherDateDb")
        let deleteRequest2 = NSBatchDeleteRequest(fetchRequest: deleteFetch2)
        
        let deleteFetch3 = NSFetchRequest<NSFetchRequestResult>(entityName: "CityTempDb")
        let deleteRequest3 = NSBatchDeleteRequest(fetchRequest: deleteFetch3)
        
        do {
            try CoreDataManager.context.execute(deleteRequest)
            try CoreDataManager.context.save()
        } catch {
            print ("There was an error")
        }
        
        
        do {
            try CoreDataManager.context.execute(deleteRequest2)
            try CoreDataManager.context.save()
        } catch {
            print ("There was an error")
        }
        
        do {
            try CoreDataManager.context.execute(deleteRequest3)
            try CoreDataManager.context.save()
        } catch {
            print ("There was an error")
        }
    }
    
    // Load weather from internet
    private func getWeatherFromInternet(completion: @escaping ([WeatherViewModel]?) -> Void) {
        NetworkManager.shared.getActualWeather() { [weak self] weather, error  in
            guard let self = self else { return }
            if error != nil {
                self.displayResultInMainVc(userMessage: error ?? ErrorTypes.something.rawValue)
                return
            }
            guard let data = weather else { return }
            let viewModels = self.mergeAndSortCitiesWeather(data: data)
            self.saveWeatherToDatabse(data: viewModels)
            completion(viewModels)
        }
    }
    
    // Merge And Sort data weather
    private func mergeAndSortCitiesWeather(data: [WeatherModel]) -> [WeatherViewModel] {
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
                                               cityPicture: city.city?.picture, cityPictureImg: nil,
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
    
     // Convertion to Celcius
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
    
     // Convertion to DayTime
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
    
    // Diplay Alert if error
    private func displayResultInMainVc(userMessage: String) {
        guard var toVc = UIApplication.shared.keyWindow?.rootViewController else { return }
        while let presentedViewController = toVc.presentedViewController {
            toVc = presentedViewController
        }
        
        let myAlert = UIAlertController(title: ErrorTypes.Error.rawValue,
                                        message: userMessage,
                                        preferredStyle: UIAlertController.Style.alert)
        let okAction = UIAlertAction(title: "Ok",
                                     style: .default)
        myAlert.addAction(okAction)
        toVc.present(myAlert, animated: true, completion: nil)
    }
    
    // Check internet connection
    private func isConnectedToNetwork() -> Bool {
        var zeroAddress = sockaddr_in(sin_len: 0, sin_family: 0, sin_port: 0, sin_addr: in_addr(s_addr: 0), sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        
        var flags: SCNetworkReachabilityFlags = SCNetworkReachabilityFlags(rawValue: 0)
        if SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) == false {
            return false
        }

        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        let ret = (isReachable && !needsConnection)
        
        return ret
        
    }
    
    // download image
    private func imageFromURLstored(urlString: String, completion: @escaping (UIImage?) -> Void ) {
        // check if the image is already in the cache
        if let imageToCache = imageCache.object(forKey: urlString as NSString) {
            completion(imageToCache)
        }
        
        URLSession.shared.dataTask(with: NSURL(string: urlString)! as URL, completionHandler: { (data, response, error) -> Void in
            if error != nil {
                print(error ?? "No Error")
                return
            }
            DispatchQueue.main.async(execute: { () -> Void in
                let image = UIImage(data: data!)
                // add image to cache
                imageCache.setObject(image!, forKey: urlString as NSString)
                completion(image)
            })
        }).resume()
    }
    
    

}
