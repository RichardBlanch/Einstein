//
//  ImageCache.swift
//  
//
//  Created by Richard Blanchard on 6/23/19.
//

import Combine
import Foundation
import UIKit

public class ImageCache {
    
    public enum Error: Swift.Error {
        case couldNotConvertData(URL)
        case general(Swift.Error )
    }
    
    private var imageMap: [URL: UIImage] = [:]
    private let dispatchQueue = DispatchQueue(from: StringKey(rawValue: "com.ImageCache"))
    
    public subscript(key: URL) -> Publishers.Future<UIImage, Error>? {
        get {
            let imageForKey = image(for: key)
    
            imageForKey
                .sink(receiveValue: { [weak self, key] image in
                    self?.dispatchQueue.sync {
                        self?.imageMap[key] = image
                    }
                })
            
            return imageForKey
        }
    }
    
    private func image(for key: URL) -> Publishers.Future<UIImage, Error> {
        if let cachedImageFuture = self[key] {
            return cachedImageFuture
        } else {
            return Publishers.Future { completion in
                _ = URLSession.shared.dataTaskPublisher(for: key).sink { (dataWithResponse) in
                    guard let fetchedImage = UIImage(data: dataWithResponse.data) else {
                        completion(.failure(.couldNotConvertData(key)))
                        return
                    }
                    
                    completion(.success(fetchedImage))
                }
            }
        }
    }
    
    public func hasImage(for key: URL) -> Bool {
        return self[key] != nil
    }
}
