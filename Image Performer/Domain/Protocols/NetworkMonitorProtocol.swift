//
//  NetworkMonitorProtocol.swift
//  Image Performer
//
//  Created by Mohamed Salah on 02/10/2024.
//

import Foundation

protocol NetworkMonitorProtocol {
    var isConnected: Bool { get }
    func waitForConnection(timeout: TimeInterval) async -> Bool
}
