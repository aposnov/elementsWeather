//
//  CityDetailCollectionViewCell.swift
//  elementsWeather
//
//  Created by Andrey Posnov on 02.08.2020.
//  Copyright © 2020 Andrey Posnov. All rights reserved.
//

import UIKit

class CityDetailCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var dayTimeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func fillData(data: CityTemp) {
        if let temp = data.temp {
            self.tempLabel.text = String(format: "%.1f", temp) + " C"
        }
        if let date = data.date {
            self.dayTimeLabel.text = date.dayTime
        }
    }

}
