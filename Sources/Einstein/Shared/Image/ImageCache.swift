//
//  ImageCache.swift
//  
//
//  Created by Richard Blanchard on 6/23/19.
//

#if os(iOS)
import Combine
import Foundation
import UIKit

public class ImageCache {
    
    public enum Error: Swift.Error {
        case couldNotConvertData(URL)
        case general(Swift.Error)
        case unknown
    }
    
    private var imageMap: [URL: UIImage] = [:]
    private let dispatchQueue = DispatchQueue(from: StringKey(rawValue: "com.ImageCache"))
    
    public subscript(url: URL) -> Publishers.Future<UIImage, ImageCache.Error>? {
        get {
            let imageForKey = image(for: url)
            _ = imageForKey
                .sink(receiveValue: { [weak self, url] image in
                    self?.write(image: image, for: url)
                })
            
            return imageForKey
        }
    }
    
    private func image(for url: URL) -> Publishers.Future<UIImage, ImageCache.Error> {
        return Publishers.Future { [weak self] (completion) in
            guard let self = self else {
                completion(.failure(Error.unknown))
                return
            }
            
            if let cachedImageFuture = self.readFromImageMap(for: url) {
                completion(.success(cachedImageFuture))
            } else {
                _ = URLSession.shared.dataTaskPublisher(for: url).sink { (dataWithResponse) in
                    guard let fetchedImage = UIImage(data: dataWithResponse.data) else { completion(.failure(.couldNotConvertData(url)))
                        return
                    }
                    
                    completion(.success(fetchedImage))
                }
            }
        }
    }
    
    private func readFromImageMap(for url: URL) -> UIImage? {
        return dispatchQueue.sync {
            return imageMap[url]
        }
    }
    
    private func write(image: UIImage, for url: URL) {
        return dispatchQueue.sync {
            imageMap[url] = image
        }
    }
    
    public func hasImage(for url: URL) -> Bool {
        return readFromImageMap(for: url) != nil
    }
}
#endif
