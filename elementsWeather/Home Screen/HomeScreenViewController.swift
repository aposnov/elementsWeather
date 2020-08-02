//
//  HomeScreenViewController.swift
//  elementsWeather
//
//  Created by Andrey Posnov on 29.07.2020.
//  Copyright © 2020 Andrey Posnov. All rights reserved.
//

import UIKit

class HomeScreenViewController: UIViewController {
    
    @IBOutlet var viewHandler: HomeScreenViewHandler!
    private var interactor = HomeScreenInteractor()
    
    private var dataWeather: [WeatherViewModel] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        self.viewHandler.configView(delegate: self)
        self.getActualWeather()
    }

    private func getActualWeather() {
        NetworkManager.shared.getActualWeather() { weather in
            guard let data = weather else { return }
            let viewModels = self.interactor.mergeAndSortCitiesWeather(data: data)
            self.dataWeather = viewModels
            self.viewHandler.updateData(data: viewModels)
        }
    }
}

extension HomeScreenViewController: CityChooseDelegate {
    func chooseCity(cityId: Int) {
        let weatherInCity = dataWeather.first(where: { $0.cityId == cityId })
        let nextScreen = CityDetailScreenViewController.storyboardController(cityId: cityId, data: weatherInCity)
        self.present(nextScreen, animated: true, completion: nil)
    }
}

