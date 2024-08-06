//
// NetworkMonitor.swift
// Cityflo
//
// Created by Anshul Gupta on 06/08/24.
// Copyright © Cityflo. All rights reserved.
//

import Network
import Combine

class NetworkMonitor: ObservableObject {
    private var monitor: NWPathMonitor
    private var queue = DispatchQueue.global()
    
    @Published var isConnected: Bool = false
    
    static let shared = NetworkMonitor()
    
    private init() {
        self.monitor = NWPathMonitor()
        self.monitor.pathUpdateHandler = { path in
            DispatchQueue.main.async {
                self.isConnected = path.status == .satisfied
            }
        }
        self.monitor.start(queue: queue)
    }
}
