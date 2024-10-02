//
//  NetworkOperationPerformer.swift
//  Image Performer
//
//  Created by Mohamed Salah on 02/10/2024.
//

import Foundation

class NetworkOperationPerformer: NetworkOperationPerformerProtocol {
    private let networkMonitor: NetworkMonitorProtocol
    
    init(networkMonitor: NetworkMonitorProtocol = NetworkMonitor()) {
        self.networkMonitor = networkMonitor
    }
    
    /// Attempts to perform a network operation using the given `operation`, within the given `timeoutDuration`.
    /// If the network is not accessible within the given `timeoutDuration`, the operation is not performed.
    ///
    /// - Parameters:
    ///   - timeoutDuration: The timeout duration in seconds.
    ///   - operation: The network operation to perform.
    /// - Returns: The result of the network operation, or `nil` if the network was not accessible within the timeout.
    /// - Throws: An error if the operation throws or if the task is cancelled.
    func perform<T>(
        withinSeconds timeoutDuration: TimeInterval,
        operation: @escaping () async throws -> T
    ) async throws -> T? {
        if Task.isCancelled {
            throw CancellationError()
        }
        
        if networkMonitor.isConnected {
            return try await operation()
        }
        
        let isConnected = await networkMonitor.waitForConnection(timeout: timeoutDuration)
        
        if isConnected {
            if Task.isCancelled {
                throw CancellationError()
            }
            return try await operation()
        } else {
            return nil
        }
    }
}
