//
//  NetworkManager.swift
//  elementsWeather
//
//  Created by Andrey Posnov on 29.07.2020.
//  Copyright © 2020 Andrey Posnov. All rights reserved.
//

import Foundation
import Alamofire

class NetworkManager {
    static let shared = NetworkManager()
    private init() {}
    
    func getActualWeather(completion: @escaping ([WeatherModel]?) -> Void) {
        AF.request(ConfigAPI.url, method: .get).response { response in
            guard let data = response.data else { return }
            let mapped = try? WeatherModel.decodeArray(from: data)
            completion(mapped)
        }
    }
    
}
