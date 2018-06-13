//
//  AsyncImageLoad.swift
//  AsyncImageLoading
//
//  Created by Ganesan, Veeramani on 5/18/18.
//  Copyright © 2018 Ganesan, Veeramani. All rights reserved.
//

//Fucntionality of this class is to download the images concurrenly using custom queue and support the image caching using NSCache. This will increase the efficiency of the image download process by saving the time and network data

import UIKit

class AsyncImageLoad {
    
    //NSCache to store already downloaded images with image url as key
    static let cache = NSCache <NSString, UIImage>()
    
    typealias ImageData = (UIImage?, Error?) -> ()
    
    var url: URL?
    var image: UIImage?
    var localizedError: Error!
    
    init (withURL url: String)
    {
        self.url = URL(string: url)
    }
    
    //Method to load image from the given url asynchronously. Also make entry in the NSCache for downloaded images to support caching and increase efficiency of the download process
    func loadImage (imgData: @escaping ImageData) {
        
        self.image = AsyncImageLoad.cache.object(forKey: (self.url?.absoluteString)! as NSString)
        
        if(self.image != nil) {
            imgData(image, nil)
        }
        else {
            
            //Custom concurrent queues to download images asynchronousy and concurrently
            DispatchQueue(label: "com.Image.AsyncImageLoad", qos: .background, attributes: .concurrent).async {
                
                if let url = self.url {
                    
                    URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
                        
                        let httpResponse = response as? HTTPURLResponse
                        
                        //Check for http status success and send the image data
                        if httpResponse?.statusCode == 200 {
                            
                            if let httpData = data {
                                
                                self.image = UIImage(data: httpData)
                                
                                //Set the image in cache once downloaded
                                AsyncImageLoad.cache.setObject(self.image!, forKey: (self.url?.absoluteString)! as NSString)
                            }
                            
                            imgData(self.image, nil)
                        }
                        else {
                            
                            //If image download fails send the error as invalid response with status code as 0
                            self.localizedError = NSError(domain: "com.Image.AsyncImageLoad", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid Response"])
                            
                            imgData(self.image, self.localizedError)
                        }
                        
                    }).resume()
                }
                else {
                    
                    //If invalid image url passed, send the error as invalid url with status code as 0
                    self.localizedError = NSError(domain: "com.Image.AsyncImageLoad", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invaild Url"])
                    
                    imgData(self.image, self.localizedError)
                }
            }
        }
    }
}

