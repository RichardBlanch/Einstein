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
        case unknown
    }
    
    private var imageMap: [URL: UIImage] = [:]
    private let dispatchQueue = DispatchQueue(from: StringKey(rawValue: "com.ImageCache"))
    
    public subscript(key: URL) -> Publishers.Future<UIImage, Error>? {
        get {
            let imageForKey = image(for: key)
            _ = imageForKey
                .sink(receiveValue: { [weak self, key] image in
                    self?.imageMap[key] = image
                })
            
            return imageForKey
        }
    }
    
    private func image(for key: URL) -> Publishers.Future<UIImage, Error> {
        return Publishers.Future { [weak self] (completion) in
            guard let self = self else {
                completion(.failure(Error.unknown))
                return
            }
            
            if let cachedImageFuture = self.imageMap[key] {
                completion(.success(cachedImageFuture))
            } else {
                _ = URLSession.shared.dataTaskPublisher(for: key).sink { (dataWithResponse) in
                    guard let fetchedImage = UIImage(data: dataWithResponse.data) else { completion(.failure(.couldNotConvertData(key)))
                        return
                    }
                    
                    completion(.success(fetchedImage))
                }
            }
        }
    }
    
    public func hasImage(for key: URL) -> Bool {
        return imageMap[key] != nil
    }
}
