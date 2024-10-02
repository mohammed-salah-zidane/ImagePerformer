//
//  NetworkMonitor.swift
//  Image Performer
//
//  Created by Mohamed Salah on 02/10/2024.
//

import Foundation
import Network

/// An actor that monitors network connectivity status.
actor NetworkMonitor: NetworkMonitorProtocol {
    private let monitor: NWPathMonitor
    private var continuation: CheckedContinuation<Bool, Never>?
    private var isResolved = false

    /// Initializes a new instance of `NetworkMonitor` and starts monitoring.
    init() {
        self.monitor = NWPathMonitor()
        self.monitor.start(queue: DispatchQueue.global(qos: .background))
    }

    /// A nonisolated computed property indicating whether the network is currently connected.
    nonisolated var isConnected: Bool {
        monitor.currentPath.status == .satisfied
    }

    /// Waits for the network to become accessible within the specified timeout.
    ///
    /// - Parameter timeout: The maximum time to wait for network connectivity, in seconds.
    /// - Returns: `true` if the network became accessible within the timeout; otherwise, `false`.
    func waitForConnection(timeout: TimeInterval) async -> Bool {
        if isConnected {
            return true
        }

        isResolved = false

        return await withCheckedContinuation { continuation in
            self.continuation = continuation

            monitor.pathUpdateHandler = { [weak self] path in
                Task {
                    await self?.handlePathUpdate(status: path.status)
                }
            }

            Task {
                try? await Task.sleep(nanoseconds: UInt64(timeout * 1_000_000_000))
                await self.handleTimeout()
            }
        }
    }

    /// Handles network path updates and resumes the continuation if the network becomes accessible.
    ///
    /// - Parameter status: The current network path status.
    private func handlePathUpdate(status: NWPath.Status) async {
        if status == .satisfied && !isResolved {
            isResolved = true
            continuation?.resume(returning: true)
            continuation = nil
            monitor.pathUpdateHandler = nil
        }
    }

    /// Handles timeout by resuming the continuation if the network did not become accessible within the timeout.
    private func handleTimeout() async {
        if !isResolved {
            isResolved = true
            continuation?.resume(returning: false)
            continuation = nil
            monitor.pathUpdateHandler = nil
        }
    }

    deinit {
        monitor.cancel()
    }
}
