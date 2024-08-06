//
// NetworkService.swift
// Cityflo
//
// Created by Anshul Gupta on 03/08/24.
// Copyright © Cityflo. All rights reserved.
//

import Foundation
import Combine
import UIKit

class ImageLoader {
    private(set) var image = CurrentValueSubject<UIImage?, Never>(nil)
    
    private(set) var isLoading = false
    
    private let url: URL?
    private var cache: ImageCache = TemporaryImageCache.shared
    private var cancellable: AnyCancellable?
    
    private let imageDownloadingQueue = DispatchQueue.global()
    
    init(url: URL?) {
        self.url = url
    }
    
    deinit {
        cancel()
    }
    
    func load() {
        guard !isLoading, let url = url else { return }
        
        if let image = cache[url] {
            self.image.value = image
            return
        }
        
        cancellable = URLSession.shared.dataTaskPublisher(for: url)
            .map { UIImage(data: $0.data) }
            .replaceError(with: nil)
            .handleEvents(receiveSubscription: { [weak self] _ in self?.onStart() },
                          receiveOutput: { [weak self] in self?.cache($0) },
                          receiveCompletion: { [weak self] _ in self?.onFinish() },
                          receiveCancel: { [weak self] in self?.onFinish() })
            .subscribe(on: imageDownloadingQueue)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.image.value = $0 }
    }
    
    func cancel() {
        cancellable?.cancel()
    }
    
    private func onStart() {
        isLoading = true
    }
    
    private func onFinish() {
        isLoading = false
    }
    
    private func cache(_ image: UIImage?) {
        guard let url = url else { return }
        image.map { cache[url] = $0 }
    }
}



protocol ImageCache {
    subscript(_ url: URL) -> UIImage? { get set }
}

struct TemporaryImageCache: ImageCache {
    
    static let shared = TemporaryImageCache()
    
    private init() {}
    
    private let cache: NSCache<NSURL, UIImage> = {
        let cache = NSCache<NSURL, UIImage>()
        cache.countLimit = 100
        cache.totalCostLimit = 1024 * 1024 * 100
        return cache
    }()
    
    subscript(_ key: URL) -> UIImage? {
        get { cache.object(forKey: key as NSURL) }
        set { newValue == nil ? cache.removeObject(forKey: key as NSURL) : cache.setObject(newValue!, forKey: key as NSURL) }
    }
}
