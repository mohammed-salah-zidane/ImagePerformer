//
//  FetchImageUseCase.swift
//  Image Performer
//
//  Created by Mohamed Salah on 02/10/2024.
//

import Foundation
import UIKit

/// A use case responsible for fetching an image using the repository and network operation performer.
class FetchImageUseCase: FetchImageUseCaseProtocol {
    // The image repository used to fetch the image.
    private let imageRepository: ImageRepositoryProtocol
    // The network operation performer used to handle network checks and timeouts.
    private let networkOperationPerformer: NetworkOperationPerformerProtocol

    /// Initializes a new instance of `FetchImageUseCase`.
    ///
    /// - Parameters:
    ///   - imageRepository: The repository to fetch the image from.
    ///   - networkOperationPerformer: The network operation performer to handle network checks and timeouts.
    init(
        imageRepository: ImageRepositoryProtocol,
        networkOperationPerformer: NetworkOperationPerformerProtocol
    ) {
        self.imageRepository = imageRepository
        self.networkOperationPerformer = networkOperationPerformer
    }

    /// Executes the image fetching process.
    ///
    /// - Returns: A `Result` containing the fetched `UIImage` or an `Error`.
    func execute() async -> Result<UIImage, Error> {
        // Use the network operation performer to attempt fetching the image within 2 seconds.
        let result = await networkOperationPerformer.perform(withinSeconds: 2) { [weak self] in
            guard let self = self else {
                throw URLError(.cancelled)
            }
            // Fetch the image from the repository.
            return try await self.imageRepository.fetchImage()
        }

        return result
    }
}
