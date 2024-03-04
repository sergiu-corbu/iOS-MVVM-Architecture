//
//  NetworkMonitorHandler.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 30.03.2023.
//

import Foundation
import Network

final class NetworkMonitorHandler: ObservableObject {
    
    @Published private(set) var isConnectedToInternet = false
    
    private let nwMonitor = NWPathMonitor()
    
    func start(connectionStatusChanged: @escaping (Bool) -> Void) {
        nwMonitor.start(queue: DispatchQueue.global(qos: .utility))
        nwMonitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                let isConnected = path.status == .satisfied
                self?.isConnectedToInternet = isConnected
                connectionStatusChanged(isConnected)
            }
        }
    }
    
    deinit {
        nwMonitor.cancel()
    }
}
