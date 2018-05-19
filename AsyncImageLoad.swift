//
//  AsyncImageLoad.swift
//  AsyncImageLoading
//
//  Created by Ganesan, Veeramani on 5/18/18.
//  Copyright © 2018 Ganesan, Veeramani. All rights reserved.
//

import UIKit

class AsyncImageLoad {
    
    typealias ImageData = (UIImage?, Error?) -> ()
    
    var url: URL?
    var image: UIImage?
    var localizedError: Error!
    
    init (withURL url: String)
    {
        self.url = URL(string: url)
    }
    
    func loadImage (imgData: @escaping ImageData) {
        
        DispatchQueue(label: "com.Image.AsyncImageLoad", qos: .background, attributes: .concurrent).async {
            
            if let url = self.url {
                
                URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
                    
                    let httpResponse = response as? HTTPURLResponse
                    
                    if httpResponse?.statusCode == 200 {
                        
                        if let httpData = data {
                            self.image = UIImage(data: httpData)
                        }
                        
                        imgData(self.image, nil)
                    }
                    else {
                        
                        self.localizedError = NSError(domain: "com.Image.AsyncImageLoad", code: (httpResponse?.statusCode)!, userInfo: [NSLocalizedDescriptionKey: "Invalid Response"])
                        imgData(self.image, self.localizedError)
                    }
                    
                }).resume()
            }
            else {
                
                self.localizedError = NSError(domain: "com.Image.AsyncImageLoad", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invaild Url"])
                imgData(self.image, self.localizedError)
            }
        }
    }
}

