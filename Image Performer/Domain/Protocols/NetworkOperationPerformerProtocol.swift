//
//  NetworkOperationPerformerProtocol.swift
//  Image Performer
//
//  Created by Mohamed Salah on 02/10/2024.
//

import Foundation

/// A protocol defining the requirements for a network operation performer.
protocol NetworkOperationPerformerProtocol {
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
    ) async -> Result<T, Error>
}
