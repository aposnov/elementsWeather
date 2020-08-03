//
//  WeatherTableViewCell.swift
//  elementsWeather
//
//  Created by Andrey Posnov on 30.07.2020.
//  Copyright © 2020 Andrey Posnov. All rights reserved.
//

import UIKit

class WeatherTableViewCell: UITableViewCell {

    @IBOutlet weak var cityName: UILabel!
    @IBOutlet weak var cityImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override var frame: CGRect {
           get {
               return super.frame
           }
           set (newFrame) {
               var frame = newFrame
               let newWidth = frame.width * 0.90
               let space = (frame.width - newWidth) / 2
               frame.size.width = newWidth
               frame.origin.x += space
               frame.size.height -= 15
               
               super.frame = frame
           }
       }
    
    func fillData(data: WeatherViewModel) {
        self.cityName.text = data.cityName
        if let imageLocal = data.cityPictureImg {
            self.cityImage.image = imageLocal
        } else if let imageUrl = data.cityPicture {
            self.cityImage.imageFromURL(urlString: imageUrl)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.cityImage.image = nil
    }
    

}
