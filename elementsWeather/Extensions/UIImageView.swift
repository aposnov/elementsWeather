//
//  UIImageView.swift
//  elementsWeather
//
//  Created by Andrey Posnov on 02.08.2020.
//  Copyright © 2020 Andrey Posnov. All rights reserved.
//

import UIKit

extension UIImageView {
    public func imageFromURL(urlString: String) {
        let activityIndicator = UIActivityIndicatorView(style: .gray)
        activityIndicator.frame = CGRect.init(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height)
        activityIndicator.startAnimating()
        if self.image == nil{
            self.addSubview(activityIndicator)
        }
        
        // check if the image is already in the cache
        if let imageToCache = imageCache.object(forKey: urlString as NSString) {
            self.image = imageToCache
            activityIndicator.removeFromSuperview()
            return
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
                activityIndicator.removeFromSuperview()
                self.image = image
            })

        }).resume()
    }
}



