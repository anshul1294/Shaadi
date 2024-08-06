//
// Network Manager.swift
// Cityflo
//
// Created by Anshul Gupta on 06/08/24.
// Copyright © Cityflo. All rights reserved.
//


import Foundation
import Combine

class NetworkManager {
    static let shared = NetworkManager()
    private init() {}
    
    func fetchData(from baseURL: String, with parameters: [String: Any]? = nil) -> AnyPublisher<Data, URLError> {
        guard let url = URL(string: baseURL) else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        if let parameters  {
            guard let url = urlWithQueryParameters(baseURL: url, parameters: parameters) else {
                return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
            }
            return getData(from: url)
        }else {
            return getData(from: url)
        }
    }
    
    func getData(from url: URL) -> AnyPublisher<Data, URLError> {
        return URLSession.shared.dataTaskPublisher(for: url)
            .handleEvents(receiveSubscription: { _ in
                print("Subscription started for URL: \(url)")
            }, receiveOutput: { output in
                print("Received data from URL: \(url), data size: \(output.data.count) bytes")
            }, receiveCompletion: { completion in
                switch completion {
                case .finished:
                    print("Network request to URL: \(url) completed successfully")
                case .failure(let error):
                    print("Network request to URL: \(url) failed with error: \(error)")
                }
            }, receiveCancel: {
                print("Network request to URL: \(url) was cancelled")
            })
            .map(\.data)
            .eraseToAnyPublisher()
    }
    
    private func urlWithQueryParameters(baseURL: URL, parameters: [String: Any]) -> URL? {
        var urlComponents = URLComponents(url: baseURL, resolvingAgainstBaseURL: false)
        var queryItems: [URLQueryItem] = []
        
        for (key, value) in parameters {
            let stringValue: String
            if let boolValue = value as? Bool {
                stringValue = boolValue ? "true" : "false"
            } else if let stringVal = value as? String {
                stringValue = stringVal
            } else {
                stringValue = "\(value)"
            }
            queryItems.append(URLQueryItem(name: key, value: stringValue))
        }
        
        urlComponents?.queryItems = queryItems
        return urlComponents?.url
    }
}


public struct Endpoint {
    // TODO: Add Sync End point
    static let getProfileData = "https://randomuser.me/api/"
}

