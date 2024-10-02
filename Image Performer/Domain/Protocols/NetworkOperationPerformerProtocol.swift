//
//  NetworkOperationPerformerProtocol.swift
//  Image Performer
//
//  Created by Mohamed Salah on 02/10/2024.
//

import Foundation

protocol NetworkOperationPerformerProtocol {
    func perform<T>(
        withinSeconds timeoutDuration: TimeInterval,
        operation: @escaping () async throws -> T
    ) async throws -> T?
}
