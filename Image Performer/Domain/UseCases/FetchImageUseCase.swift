//
//  FetchImageUseCase.swift
//  Image Performer
//
//  Created by Mohamed Salah on 02/10/2024.
//

import Foundation
import UIKit

class FetchImageUseCase: FetchImageUseCaseProtocol {
    private let imageRepository: ImageRepositoryProtocol
    private let networkOperationPerformer: NetworkOperationPerformerProtocol

    init(
        imageRepository: ImageRepositoryProtocol,
        networkOperationPerformer: NetworkOperationPerformerProtocol
    ) {
        self.imageRepository = imageRepository
        self.networkOperationPerformer = networkOperationPerformer
    }

    func execute() async -> Result<UIImage, Error> {
        do {
            let image = try await networkOperationPerformer.perform(withinSeconds: 2) {[weak self] in
                try await self?.imageRepository.fetchImage()
            }
            
            guard let loadedImage = image else {
                return .failure(URLError(.timedOut))
            }
            
            return .success(loadedImage!)
            
        } catch {
            return .failure(error)
        }
    }
}
