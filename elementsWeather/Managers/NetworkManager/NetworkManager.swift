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
    
    func getActualWeather(completion: @escaping ([WeatherModel]?, String?) -> Void) {
        AF.request(ConfigAPI.url, method: .get).response { response in
            switch response.result {
            case .success:
                guard let data = response.data else { return }
                let mapped = try? WeatherModel.decodeArray(from: data)
                if mapped?.count != 0 {
                    completion(mapped, nil)
                } else {
                    completion(nil, ErrorTypes.something.rawValue)
                }
            case let .failure(error):
                completion(nil, error.errorDescription)
            }
        }
    }
    
}
