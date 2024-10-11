//
//  ImageRepositoryProtocol.swift
//  Image Performer
//
//  Created by Mohamed Salah on 02/10/2024.
//

import Foundation
import UIKit

/// A protocol defining the requirements for an image repository.
protocol ImageRepositoryProtocol {
    /// Fetches the image from a specified source.
    ///
    /// - Returns: The fetched `UIImage`.
    /// - Throws: An error if the image cannot be fetched or decoded.
    func fetchImage() async throws -> UIImage
}
