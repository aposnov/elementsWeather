//
//  CityDetailScreenViewController.swift
//  elementsWeather
//
//  Created by Andrey Posnov on 02.08.2020.
//  Copyright © 2020 Andrey Posnov. All rights reserved.
//

import UIKit

class CityDetailScreenViewController: UIViewController {
    
    @IBOutlet var viewHandler: CityDetailViewHandler!
    
    private var cityId = 0
    private var weatherInCity: WeatherViewModel?
    
    static func storyboardController(cityId: Int?, data: WeatherViewModel?) -> CityDetailScreenViewController {
        let storyboard = UIStoryboard(name: "CityDetailScreen", bundle: nil)
        let vc = storyboard.instantiateInitialViewController() as! CityDetailScreenViewController
        vc.modalPresentationStyle = .fullScreen
        vc.cityId = cityId ?? 0
        vc.weatherInCity = data ?? WeatherViewModel(cityId: 0, cityName: nil, cityPicture: nil, temps: nil)
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let weatherInCity = self.weatherInCity {
            self.viewHandler.configView(cityId: cityId, weatherInCity: weatherInCity)
        }
    }
    
    @IBAction func backButtonAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    

}
