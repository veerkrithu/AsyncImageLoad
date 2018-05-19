//
//  AsyncImageLoad.swift
//  AsyncImageLoading
//
//  Created by Ganesan, Veeramani - Contractor {BIS} on 5/18/18.
//  Copyright © 2018 Ganesan, Veeramani - Contractor {BIS}. All rights reserved.
//

import UIKit

class AsyncImageLoad {
    
    typealias ImageData = (UIImage?) -> ()
    
    var url: URL?
    var image: UIImage?
    
    init (withURL url: String)
    {
        self.url = URL(string: url)
    }
    
    func loadImage (imgData: @escaping ImageData) {
     
        DispatchQueue(label: "com.Image.AsyncImageLoad", qos: .background, attributes: .concurrent).async {
            
            if let url = self.url {
                
                URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
                    
                    if error == nil {
                        
                        if let dataValue = data {
                            self.image = UIImage(data: dataValue)
                        }
                    }
                    imgData(self.image)
                }).resume()
            }
        }
    }
}
