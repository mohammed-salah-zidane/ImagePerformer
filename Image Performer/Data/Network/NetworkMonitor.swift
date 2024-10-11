//
//  NetworkMonitor.swift
//  Image Performer
//
//  Created by Mohamed Salah on 02/10/2024.
//

import Foundation
import Network

/// An actor that monitors network connectivity status.
/// It allows multiple concurrent calls to `waitForConnection(timeout:)`
/// and resumes all waiting tasks when the network status changes.
actor NetworkMonitor: NetworkMonitorProtocol {
    // The NWPathMonitor instance used to monitor network changes.
    private let monitor: NWPathMonitor
    // An array to keep track of all pending continuations waiting for network availability.
    private var continuations: [CheckedContinuation<Bool, Never>] = []
    
    /// Initializes a new instance of `NetworkMonitor` and starts monitoring.
    init() {
        self.monitor = NWPathMonitor()
        // Start monitoring on a background queue.
        self.monitor.start(queue: DispatchQueue.global(qos: .background))
        // Set up a single path update handler for all waiting tasks.
        self.monitor.pathUpdateHandler = { [weak self] path in
            Task {
                await self?.handlePathUpdate(status: path.status)
            }
        }
    }
    
    /// A nonisolated computed property indicating whether the network is currently connected.
    nonisolated var isConnected: Bool {
        monitor.currentPath.status == .satisfied
    }
    
    /// Waits for the network to become accessible within the specified timeout.
    ///
    /// This method allows multiple concurrent calls. Each call will wait until
    /// the network becomes accessible or the timeout expires.
    ///
    /// - Parameter timeout: The maximum time to wait for network connectivity, in seconds.
    /// - Returns: `true` if the network became accessible within the timeout; otherwise, `false`.
    func waitForConnection(timeout: TimeInterval) async -> Bool {
        if isConnected {
            // Network is already connected; no need to wait.
            return true
        }
        
        return await withCheckedContinuation { continuation in
            // Add the continuation to the array of waiting tasks.
            self.continuations.append(continuation)
            
            // Start a timeout task to handle the case where the network
            // does not become available within the specified duration.
            Task {
                try? await Task.sleep(nanoseconds: UInt64(timeout * 1_000_000_000))
                await self.handleTimeout()
            }
        }
    }
    
    /// Handles network path updates and resumes all waiting continuations if the network becomes accessible.
    ///
    /// - Parameter status: The current network path status.
    private func handlePathUpdate(status: NWPath.Status) async {
        if status == .satisfied {
            // Network is now connected.
            // Resume all waiting continuations with `true`.
            // It's important to remove continuations after resuming them
            // to prevent resuming them multiple times and to free up resources.
            while !continuations.isEmpty {
                let continuation = continuations.removeFirst()
                continuation.resume(returning: true)
            }
        }
    }
    
    /// Handles timeout by resuming all waiting continuations with `false` if the network did not become accessible in time.
    private func handleTimeout() async {
        // Network did not become available within the timeout duration.
        // Resume all waiting continuations with `false`.
        // Again, we remove continuations after resuming them to prevent
        // resuming them multiple times and to free up resources.
        while !continuations.isEmpty {
            let continuation = continuations.removeFirst()
            continuation.resume(returning: false)
        }
    }
    
    deinit {
        // Clean up by cancelling the network monitor when the actor is deallocated.
        monitor.cancel()
    }
}
