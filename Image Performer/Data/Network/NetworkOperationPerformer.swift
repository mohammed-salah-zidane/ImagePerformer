//
//  NetworkOperationPerformer.swift
//  Image Performer
//
//  Created by Mohamed Salah on 02/10/2024.
//

import Foundation

/// A class responsible for performing network operations with network availability checks and timeout handling.
class NetworkOperationPerformer: NetworkOperationPerformerProtocol {
    private let networkMonitor: NetworkMonitorProtocol

    /// Initializes a new instance of `NetworkOperationPerformer`.
    ///
    /// - Parameter networkMonitor: The network monitor to use for checking network connectivity.
    init(networkMonitor: NetworkMonitorProtocol = NetworkMonitor()) {
        self.networkMonitor = networkMonitor
    }

    /// Attempts to perform a network operation within the given timeout duration.
    /// If the network is not accessible within the timeout, the operation is not performed.
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
