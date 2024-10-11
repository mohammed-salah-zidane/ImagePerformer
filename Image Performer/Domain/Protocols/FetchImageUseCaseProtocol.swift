//
//  FetchImageUseCaseProtocol.swift
//  Image Performer
//
//  Created by Mohamed Salah on 02/10/2024.
//

import Foundation
import UIKit

/// A protocol defining the requirements for a use case that fetches an image.
protocol FetchImageUseCaseProtocol {
    /// Executes the image fetching process.
    ///
    /// - Returns: A `Result` containing the fetched `UIImage` or an `Error`.
    func execute() async -> Result<UIImage, Error>
}
