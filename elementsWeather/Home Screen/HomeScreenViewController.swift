//
//  HomeScreenViewController.swift
//  elementsWeather
//
//  Created by Andrey Posnov on 29.07.2020.
//  Copyright © 2020 Andrey Posnov. All rights reserved.
//

import UIKit

class HomeScreenViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.getActualWeather()
    }

    func getActualWeather() {
        NetworkManager.shared.getActualWeather() { weather in
            debugPrint("weather is here \(weather)")
        }
    }

}

