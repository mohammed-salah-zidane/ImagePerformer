//
//  ImageRepository.swift
//  Image Performer
//
//  Created by Mohamed Salah on 02/10/2024.
//

import Foundation
import UIKit

/// A repository responsible for fetching images from a specified URL.
class ImageRepository: ImageRepositoryProtocol {
    // The URL of the image to fetch.
    private let imageURL: URL
    // A static cache to store fetched images.
    private static let cache = NSCache<NSURL, UIImage>()

    /// Initializes a new instance of `ImageRepository`.
    ///
    /// - Parameter imageURL: The URL of the image to fetch.
    init(imageURL: URL) {
        self.imageURL = imageURL
    }

    /// Fetches the image from the specified URL.
    ///
    /// - Returns: The fetched `UIImage`.
    /// - Throws: An error if the image cannot be fetched or decoded.
    func fetchImage() async throws -> UIImage {
        // Check if the image is already in the cache.
        if let cachedImage = Self.cache.object(forKey: imageURL as NSURL) {
            return cachedImage
        }

        // Fetch the image data from the URL.
        let (data, _) = try await URLSession.shared.data(from: imageURL)
        // Attempt to create a UIImage from the data.
        guard let image = UIImage(data: data) else {
            throw URLError(.badServerResponse)
        }

        // Store the image in the cache.
        Self.cache.setObject(image, forKey: imageURL as NSURL)
        return image
    }
}
