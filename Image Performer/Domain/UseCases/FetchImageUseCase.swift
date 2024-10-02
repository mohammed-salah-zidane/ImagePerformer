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
    private let imageRepository: ImageRepositoryProtocol
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
        do {
            let image = try await networkOperationPerformer.perform(withinSeconds: 2) { [weak self] in
                guard let self = self else {
                    throw URLError(.cancelled)
                }
                return try await self.imageRepository.fetchImage()
            }

            guard let loadedImage = image else {
                return .failure(URLError(.timedOut))
            }

            return .success(loadedImage)

        } catch {
            return .failure(error)
        }
    }
}
