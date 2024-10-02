//
//  ImageRepository.swift
//  Image Performer
//
//  Created by Mohamed Salah on 02/10/2024.
//

import Foundation
import UIKit

class ImageRepository: ImageRepositoryProtocol {
    private let imageURL: URL
    private static let cache = NSCache<NSURL, UIImage>()

    init(imageURL: URL) {
        self.imageURL = imageURL
    }

    func fetchImage() async throws -> UIImage {
        if let cachedImage = Self.cache.object(forKey: imageURL as NSURL) {
            return cachedImage
        }

        let (data, _) = try await URLSession.shared.data(from: imageURL)
        guard let image = UIImage(data: data) else {
            throw URLError(.badServerResponse)
        }

        Self.cache.setObject(image, forKey: imageURL as NSURL)
        return image
    }
}
