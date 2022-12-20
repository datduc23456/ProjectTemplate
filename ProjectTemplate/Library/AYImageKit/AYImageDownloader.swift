//
//  TrendingCollectionViewCell.swift
//  ProjectDemo
//
//  Created by Nguyễn Đạt on 17/11/2022.
//

import UIKit

public class AYImageDownloader {
    
    public enum DownloadImageError: Error {
        case invalidRequestData
        case invalidResponseData
    }
    
    public typealias FetchImageHandler = (Result<UIImage>) -> Void
    
    private let memoryImageCache = MemoryImageCache(capacity: .megaBytes(4))
    private let diskImageCache = DiskImageCache(capacity: .megaBytes(50))
    private let memoryCache = NSCache<NSURL, UIImage>()
    private let diskCache: URLCache
    
    private let urlSession: URLSession
    private let queue: DispatchQueue
    private var completionHandlers: [URL: [FetchImageHandler]] = [:]
    
    public static let shared = AYImageDownloader()
    
    public init() {
        self.diskCache = URLCache(memoryCapacity: 0, diskCapacity: 20 * 1024 * 1024, diskPath: nil) // 20MB on disk
        let configuration = URLSessionConfiguration.default
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        self.urlSession = URLSession(configuration: configuration)
        self.memoryCache.totalCostLimit = 4 * 1024 * 1024 // 4MB on memory
        self.queue = DispatchQueue(label: "ImageDownloader.Queue", qos: .utility)
    }
    
    public func fetchImage(from url: URL?, forceRemoteFetching: Bool = false, cacheInMemory: Bool = false, cacheInDisk:Bool = true, completionQueue: DispatchQueue = .main, completion: @escaping FetchImageHandler) {
        
        let dispatchCompletion: FetchImageHandler = { result in
            completionQueue.async { completion(result) }
        }
        
        guard let url = url else {
            dispatchCompletion(.failure(DownloadImageError.invalidRequestData))
            return
        }
        
        let referenceURL = self.referenceURL(for: url)

        var imageFetched = false
        if let imageOnMemory = memoryImageCache.image(for: referenceURL) {
            dispatchCompletion(.success(imageOnMemory))
            guard forceRemoteFetching else { return }
            imageFetched = true
        }

        self.queue.async {
            
            if imageFetched == false, let imageOnDisk = self.diskImageCache.image(for: referenceURL) {
                self.memoryImageCache.store(imageOnDisk, for: referenceURL)
                dispatchCompletion(.success(imageOnDisk))
                guard forceRemoteFetching else { return }
                imageFetched = true
            }

            if var handlers = self.completionHandlers[referenceURL] {
                handlers.append(dispatchCompletion)
                self.completionHandlers[referenceURL] = handlers
                
            } else {
                
                self.completionHandlers[referenceURL] = [dispatchCompletion]
                self.downloadImage(from: url) { [weak self] result in
                    
                    guard let self = self else { return }
                    
                    self.queue.async {
                        
                        let completionHandlers = self.completionHandlers[referenceURL] ?? []
                        self.completionHandlers[referenceURL] = nil
                        
                        if let (image, data) = result.value {
                            
                            if cacheInDisk {
                                self.diskImageCache.store(image, data: data, for: referenceURL)
                            }
                            if cacheInMemory {
                                self.memoryImageCache.store(image, for: referenceURL)
                            }
                        }
                        
                        let result: Result<UIImage> = result.map { $0.0 }
                        completionHandlers.forEach { $0(result) }
                    }
                }
            }
        }
    }

    private func referenceURL(for url: URL) -> URL {
        var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)
        urlComponents?.query = nil
        guard let truncatedURL = urlComponents?.url else {
            print("Unable to truncate \(url) for image caching")
            return url
        }
        return truncatedURL
    }
    
    private func downloadImage(from url: URL, completion: @escaping (Result<(UIImage, Data)>) -> Void) {
        
        let dataTask = urlSession.dataTask(with: url) { [weak self] (data, response, error) in
            guard let self = self else { return }
            
            self.queue.async {
                
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let data = data,
                    let image = UIImage(data: data) else {
                        completion(.failure(DownloadImageError.invalidResponseData))
                        return
                }
                completion(.success((image, data)))
            }
        }
        
        dataTask.resume()
    }
    
    public func clearCache(for url: URL) {
        let referenceURL = self.referenceURL(for: url)
        
        memoryImageCache.clearCache(for: referenceURL)
        
        self.queue.async {
            self.diskImageCache.clearCache(for: referenceURL)
        }
    }
    
}

// MARK: - Image Caching

struct ByteCount {
    
    var value: Int
    
    public static func bytes(_ value: Int) -> ByteCount {
        return ByteCount(value: value)
    }
    
    public static func kiloBytes(_ value: Int) -> ByteCount {
        return .bytes(value * 1_000)
    }
    
    public static func megaBytes(_ value: Int) -> ByteCount {
        return .kiloBytes(value * 1_000)
    }
    
    public static func gigaBytes(_ value: Int) -> ByteCount {
        return .megaBytes(value * 1_000)
    }
}


protocol ImageCache: AnyObject {
    
    init(capacity: ByteCount)
    func image(for url: URL) -> UIImage?
    func clearCache(for url: URL)
}


final class MemoryImageCache: ImageCache {
    
    private let cache: NSCache<NSURL, UIImage>
    
    init(capacity: ByteCount) {
        self.cache = NSCache<NSURL, UIImage>()
        self.cache.totalCostLimit = capacity.value
    }
    
    func image(for url: URL) -> UIImage? {
        return cache.object(forKey: url as NSURL)
    }
    
    func store(_ image: UIImage, for url: URL) {
        cache.setObject(image, forKey: url as NSURL)
    }
    
    func clearCache(for url: URL) {
        cache.removeObject(forKey: url as NSURL)
    }
    
}


final class DiskImageCache: ImageCache {
    
    private let urlCache: URLCache
    
    init(capacity: ByteCount) {
        self.urlCache = URLCache(memoryCapacity: 0, diskCapacity: capacity.value, diskPath: nil) // 20MB on disk
    }
    
    func image(for url: URL) -> UIImage? {
        let urlRequest = URLRequest(url: url)
        guard let cachedResponse = urlCache.cachedResponse(for: urlRequest) else {
            return nil
        }
        return UIImage(data: cachedResponse.data)
    }
    
    func store(_ image: UIImage, data: Data, for url: URL) {
        
        let urlRequest = URLRequest(url: url)
        var headers = [String: String]()
        let numberOfDays = 1
        headers["Cache-Control"] = "private, max-age=\(60 * 60 * 24 * numberOfDays)"
        guard let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: headers) else { return }
        let cachedURLResponse = CachedURLResponse(response: response, data: data, userInfo: nil, storagePolicy: .allowed)
        urlCache.storeCachedResponse(cachedURLResponse, for: urlRequest)
        
    }
    
    func clearCache(for url: URL) {
        
        let urlRequest = URLRequest(url: url)
        guard let newResponse = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: ["Cache-Control": "max-age=0"]) else { return }
        let cachedResponse = CachedURLResponse(response: newResponse, data: Data())
        URLCache.shared.storeCachedResponse(cachedResponse, for: urlRequest)
    }
    
}



