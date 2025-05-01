//
//  NetworkMonitor.swift
//  ChatBotApp
//
//  Created by Nishant Kumar on 01/05/25.
//

import Foundation
import Network

class NetworkMonitor {
    static let shared = NetworkMonitor()

    private let monitor: NWPathMonitor
    private let monitorQueue = DispatchQueue.global()
    private let syncQueue = DispatchQueue(label: NETWORK_DISPATCH_QUEUE_LABEL)

    private var _isConnected: Bool = false
    public var isConnected: Bool {
        syncQueue.sync {
            _isConnected
        }
    }

    private init() {
        monitor = NWPathMonitor()
    }
    
    public func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            guard let self = self else { return }

            self.syncQueue.async {
                let status = path.status != .unsatisfied
                self._isConnected = status
                print("Network status changed: \(status ? "Online" : "Offline")")
                
                DispatchQueue.main.async {
                    if !SocketManager.shared.isConnected {
                        SocketManager.shared.connect()
                    }
                    NotificationCenter.default.post(name: NETWORK_STATUS_CHANGED, object: nil)
                }
            }
        }
        monitor.start(queue: monitorQueue)
    }
    
    public func stopMonitoring() {
        monitor.cancel()
    }
}
