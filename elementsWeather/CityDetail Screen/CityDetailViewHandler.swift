//
//  CityDetailViewHandler.swift
//  elementsWeather
//
//  Created by Andrey Posnov on 02.08.2020.
//  Copyright © 2020 Andrey Posnov. All rights reserved.
//

import UIKit

class CityDetailViewHandler: NSObject {
    
    @IBOutlet weak var cityNameLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    private var cityId = 0
    private var weatherInCity: WeatherViewModel?
    private let cellIdentifier = "CityDetailCollectionViewCell"
    
    func configView(cityId: Int, weatherInCity: WeatherViewModel) {
        self.cityId = cityId
        self.weatherInCity = weatherInCity
        self.setupLabels()
        self.setupCollectionCell()
    }
    
    private func setupLabels() {
        self.cityNameLabel.text = weatherInCity?.cityName
    }
    
    private func setupCollectionCell() {
        self.collectionView.register(UINib(nibName: cellIdentifier, bundle: nil), forCellWithReuseIdentifier: cellIdentifier)
    }

}

extension CityDetailViewHandler: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return weatherInCity?.temps?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! CityDetailCollectionViewCell
        if let data = weatherInCity?.temps?[indexPath.row] {
            cell.fillData(data: data)
        }
        cell.layer.applySketchShadow(color: .black, alpha: 0.12, xCoord: 0, yCoord: 4, blur: 16, spread: 0)
        let gradientLayer2 = CAGradientLayer()
        let niceColorTop = UIColor(red: 72.0 / 255.0, green: 73.0 / 255.0, blue: 193.0 / 255.0, alpha: 1).cgColor
        let niceColorBottom = UIColor(red: 236.0 / 255.0, green: 88.0 / 255.0, blue: 95.0 / 255.0, alpha: 1).cgColor
        gradientLayer2.frame = cell.bounds
        gradientLayer2.colors = [niceColorTop, niceColorBottom]
        cell.layer.insertSublayer(gradientLayer2, at: 0)
        cell.layer.cornerRadius = 15
        cell.layer.borderWidth = 0.5
        cell.layer.borderColor = UIColor.gray.cgColor
        cell.layer.masksToBounds = true
        return cell
    }
}


