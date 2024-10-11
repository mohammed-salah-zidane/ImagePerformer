//
//  NetworkOperationPerformer.swift
//  Image Performer
//
//  Created by Mohamed Salah on 02/10/2024.
//

import Foundation

/// A class responsible for performing network operations with network availability checks and timeout handling.
class NetworkOperationPerformer: NetworkOperationPerformerProtocol {
    // The network monitor used to check network connectivity.
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
    /// - Returns: A `Result` containing the result of the network operation or an error.
    func perform<T>(
        withinSeconds timeoutDuration: TimeInterval,
        operation: @escaping () async throws -> T
    ) async -> Result<T, Error> {
        if Task.isCancelled {
            // If the task is cancelled before starting, return a cancellation error.
            return .failure(CancellationError())
        }

        if networkMonitor.isConnected {
            // If the network is connected, attempt the operation immediately.
            do {
                let result = try await operation()
                return .success(result)
            } catch {
                return .failure(error)
            }
        }

        // Wait for the network to become available within the timeout.
        let isConnected = await networkMonitor.waitForConnection(timeout: timeoutDuration)

        if isConnected {
            if Task.isCancelled {
                // Check for cancellation before proceeding.
                return .failure(CancellationError())
            }
            do {
                let result = try await operation()
                return .success(result)
            } catch {
                return .failure(error)
            }
        } else {
            // If the network did not become available within the timeout, return a timeout error.
            return .failure(URLError(.timedOut))
        }
    }
}
