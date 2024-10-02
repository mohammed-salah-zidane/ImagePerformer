//
//  NetworkMonitor.swift
//  Image Performer
//
//  Created by Mohamed Salah on 02/10/2024.
//

import Foundation
import Network

actor NetworkMonitor: NetworkMonitorProtocol {
    private let monitor: NWPathMonitor
    private var continuation: CheckedContinuation<Bool, Never>?
    private var isResolved = false

    init() {
        self.monitor = NWPathMonitor()
        self.monitor.start(queue: DispatchQueue.global(qos: .background))
    }

    nonisolated var isConnected: Bool {
        monitor.currentPath.status == .satisfied
    }

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

    private func handlePathUpdate(status: NWPath.Status) async {
        if status == .satisfied && !isResolved {
            isResolved = true
            continuation?.resume(returning: true)
            continuation = nil
            monitor.pathUpdateHandler = nil
        }
    }

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
