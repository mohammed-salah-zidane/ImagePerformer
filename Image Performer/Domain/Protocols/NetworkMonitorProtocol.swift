//
//  NetworkMonitorProtocol.swift
//  Image Performer
//
//  Created by Mohamed Salah on 02/10/2024.
//

import Foundation

/// A protocol defining the requirements for a network monitor.
protocol NetworkMonitorProtocol {
    /// Indicates whether the network is currently connected.
    var isConnected: Bool { get }
    
    /// Waits for the network to become accessible within the specified timeout.
    ///
    /// - Parameter timeout: The maximum time to wait for network connectivity, in seconds.
    /// - Returns: `true` if the network became accessible within the timeout; otherwise, `false`.
    func waitForConnection(timeout: TimeInterval) async -> Bool
}
